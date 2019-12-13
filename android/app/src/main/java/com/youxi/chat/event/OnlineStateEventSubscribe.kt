package com.youxi.chat.event

import com.netease.nim.uikit.api.NimUIKit
import com.netease.nim.uikit.common.framework.infra.Handlers
import com.netease.nim.uikit.common.util.log.LogUtil
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.RequestCallbackWrapper
import com.netease.nimlib.sdk.ResponseCode
import com.netease.nimlib.sdk.event.EventSubscribeService
import com.netease.nimlib.sdk.event.model.EventSubscribeRequest
import com.netease.nimlib.sdk.event.model.NimOnlineStateEvent
import com.netease.nimlib.sdk.msg.MsgService
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum
import com.netease.nimlib.sdk.msg.model.RecentContact
import com.youxi.chat.config.preference.UserPreferences
import com.youxi.chat.nim.NimCache

/**
 * Created by chenkang on 2017/4/26.
 */
object OnlineStateEventSubscribe {
    // 订阅好友并同步当前在线状态的频率控制30 s，对同一账号连续2次订阅时间间隔在30s 以上
    private const val SUBS_FREQ = 30 * 1000.toLong()
    private var lastSubsTime: Long = -1
    private var initSubsFinished = true
    private var waitInitSubs = false
    // 订阅有效期 1天，单位秒
    const val SUBSCRIBE_EXPIRY = 60 * 60 * 24.toLong()

    fun initSubscribes() { // 正在进行
        if (waitInitSubs || !initSubsFinished) {
            return
        }
        val timeInterval = subsTimeInterval
        if (timeInterval <= SUBS_FREQ) {
            waitInitSubs = true
            val delay = SUBS_FREQ - timeInterval + 1000
            LogUtil.ui("time interval short than 30 and init subscribe delay $delay")
            val handler = Handlers.sharedHandler(NimCache.getContext())
            handler.postDelayed({
                // 延迟订阅
                waitInitSubs = false
                initSubscribes()
            }, delay)
            return
        }
        initSubsFinished = false
        // 重置事件、订阅关系缓存
        OnlineStateEventCache.resetCache()
        // 重置订阅有效期管理
        SubscribeExpiryManager.reset()
        // 订阅好友、最近联系人中非好友的在线状态事件
        subscribeAllOnlineStateEvent()
    }

    private val subsTimeInterval: Long
        private get() {
            if (lastSubsTime < 0) {
                lastSubsTime = UserPreferences.onlineStateSubsTime
            }
            return System.currentTimeMillis() - lastSubsTime
        }

    private fun updateLastSubsTime() {
        lastSubsTime = System.currentTimeMillis()
        UserPreferences.onlineStateSubsTime = lastSubsTime
    }

    /**
     * 订阅好友、最近联系人的在线状态事件
     */
    fun subscribeAllOnlineStateEvent() {
        val accounts = NimUIKit.getContactProvider().userInfoOfMyFriends
        filter(accounts)
        NIMClient.getService(MsgService::class.java).queryRecentContacts().setCallback(object : RequestCallbackWrapper<List<RecentContact>?>() {
            override fun onResult(code: Int, result: List<RecentContact>?, exception: Throwable?) {
                if (result != null && !result.isEmpty()) {
                    for (recentContact in result) {
                        if (recentContact.sessionType == SessionTypeEnum.Team) {
                            continue
                        }
                        val id = recentContact.contactId
                        if (!NimUIKit.getContactProvider().isMyFriend(id)) {
                            accounts.add(id)
                        }
                    }
                }
                initSubsFinished = true
                if (accounts.isEmpty()) {
                    return
                }
                LogUtil.ui("subscribe friends and recentContact $accounts")
                subscribeOnlineStateEvent(accounts, SUBSCRIBE_EXPIRY)
            }
        })
    }

    /**
     * 订阅指定账号的在线状态事件
     *
     * @param accounts 目标账号
     */
    fun subscribeOnlineStateEvent(accounts: MutableList<String>?, expiry: Long) {
        if (waitInitSubs || !initSubsFinished || accounts == null || accounts.isEmpty()) {
            return
        }
        filter(accounts)
        LogUtil.ui("do subscribe onlineStateEvent accounts = $accounts")
        val eventSubscribeRequest = EventSubscribeRequest()
        eventSubscribeRequest.eventType = NimOnlineStateEvent.EVENT_TYPE
        eventSubscribeRequest.publishers = accounts
        eventSubscribeRequest.expiry = expiry
        eventSubscribeRequest.isSyncCurrentValue = true
        OnlineStateEventCache.addSubsAccounts(accounts)
        updateLastSubsTime()
        NIMClient.getService(EventSubscribeService::class.java).subscribeEvent(eventSubscribeRequest).setCallback(object : RequestCallbackWrapper<List<String>?>() {
            override fun onResult(code: Int, result: List<String>?, exception: Throwable?) {
                if (code == ResponseCode.RES_SUCCESS.toInt()) { // 可能网络比较慢，所以再更新一把时间
                    updateLastSubsTime()
                    SubscribeExpiryManager.subscribeSuccess()
                    if (result != null) { // 部分订阅失败的账号。。。
                        OnlineStateEventCache.removeSubsAccounts(result)
                    }
                } else {
                    OnlineStateEventCache.removeSubsAccounts(accounts)
                }
            }
        })
    }

    private fun filter(accounts: MutableList<String>) {
        val iterator = accounts.iterator()
        while (iterator.hasNext()) {
            val s = iterator.next()
            if (subscribeFilter(s)) {
                iterator.remove()
            }
        }
    }

    // 机器人账号不订阅
    fun subscribeFilter(account: String?): Boolean {
        return NimUIKit.getRobotInfoProvider().getRobotByAccount(account) != null
    }

    /**
     * 取消订阅指定账号的在线状态事件
     *
     * @param accounts 目标账号
     */
    fun unSubscribeOnlineStateEvent(accounts: List<String>?) {
        if (accounts == null || accounts.isEmpty()) {
            return
        }
        LogUtil.ui("unSubscribe OnlineStateEvent $accounts")
        OnlineStateEventCache.removeSubsAccounts(accounts)
        OnlineStateEventCache.removeOnlineState(accounts)
        val eventSubscribeRequest = EventSubscribeRequest()
        eventSubscribeRequest.eventType = NimOnlineStateEvent.EVENT_TYPE
        eventSubscribeRequest.publishers = accounts
        NIMClient.getService(EventSubscribeService::class.java).unSubscribeEvent(eventSubscribeRequest)
    }

    /**
     * 订阅有效期管理，快到期时重新订阅
     */
    private object SubscribeExpiryManager {
        private var firstSubs = true
        fun reset() {
            LogUtil.ui("time task reset")
            val handler = Handlers.sharedHandler(NimCache.getContext())
            handler.removeCallbacks(runnable)
            firstSubs = true
        }

        private val runnable = Runnable {
            // 如果不是好友并且不在最近联系人里面，则不会续订
            LogUtil.ui("time task subscribe again")
            initSubscribes()
        }

        private fun startTimeTask() {
            LogUtil.ui("time task start")
            val handler = Handlers.sharedHandler(NimCache.getContext())
            handler.removeCallbacks(runnable)
            handler.postDelayed(runnable, SUBSCRIBE_EXPIRY * 1000)
        }

        fun subscribeSuccess() {
            if (firstSubs) {
                firstSubs = false
                startTimeTask()
            }
        }
    }
}