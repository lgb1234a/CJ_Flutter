package com.youxi.chat.event

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.ConnectivityManager
import com.netease.nim.uikit.api.NimUIKit
import com.netease.nim.uikit.api.model.contact.ContactChangedObserver
import com.netease.nim.uikit.common.util.log.LogUtil
import com.netease.nim.uikit.common.util.sys.NetworkUtil
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.Observer
import com.netease.nimlib.sdk.RequestCallbackWrapper
import com.netease.nimlib.sdk.ResponseCode
import com.netease.nimlib.sdk.StatusCode
import com.netease.nimlib.sdk.auth.AuthServiceObserver
import com.netease.nimlib.sdk.auth.ClientType
import com.netease.nimlib.sdk.event.EventSubscribeService
import com.netease.nimlib.sdk.event.EventSubscribeServiceObserver
import com.netease.nimlib.sdk.event.model.Event
import com.netease.nimlib.sdk.event.model.NimOnlineStateEvent
import com.netease.nimlib.sdk.msg.MsgService
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum
import com.netease.nimlib.sdk.msg.model.RecentContact
import com.youxi.chat.R
import com.youxi.chat.nim.NimCache
import java.util.*

/**
 * 在线状态事件管理
 */
object OnlineStateEventManager {
    /**
     * 发布事件有效期7天
     */
    private const val EVENT_EXPIRY = 60 * 60 * 24 * 7.toLong()
    private const val NET_TYPE_2G = "2G"
    private const val NET_TYPE_3G = "3G"
    private const val NET_TYPE_4G = "4G"
    private const val NET_TYPE_WIFI = "WiFi"
    private const val UNKNOWN = "未知"
    // 已发布的网络状态
    private var pubNetState = -1
    var isEnable = false
        private set

    fun init() {
        if (!enableOnlineStateEvent()) {
            return
        }
        registerEventObserver(true)
        registerOnlineStatusObserver()
        NimUIKit.getContactChangedObservable().registerObserver(observer, true)
        registerNetTypeChangeObserver()
    }

    private val observer: ContactChangedObserver = object : ContactChangedObserver {
        override fun onAddedOrUpdatedFriends(accounts: List<String>) {
            if (accounts == null || accounts.isEmpty()) {
                return
            }
            val subs: MutableList<String> = ArrayList()
            for (account in accounts) {
                if (!OnlineStateEventCache.hasSubscribed(account)) {
                    subs.add(account)
                }
            }
            LogUtil.ui("added or updated friends subscribe online state $subs")
            OnlineStateEventSubscribe.subscribeOnlineStateEvent(subs, OnlineStateEventSubscribe.SUBSCRIBE_EXPIRY)
        }

        override fun onDeletedFriends(accounts: MutableList<String>) { // 如果最近会话里面存在该用户，则不取消订阅
            if (accounts == null || accounts.isEmpty()) {
                return
            }
            NIMClient.getService(MsgService::class.java).queryRecentContacts().setCallback(object : RequestCallbackWrapper<List<RecentContact>?>() {
                override fun onResult(code: Int, result: List<RecentContact>?, exception: Throwable?) { // 取消订阅名单
                    var unSubs: MutableList<String> = ArrayList()
                    if (code != ResponseCode.RES_SUCCESS.toInt() || result == null) {
                        unSubs = accounts
                    } else {
                        val recentContactSet: MutableSet<String> = HashSet()
                        for (recentContact in result) {
                            if (recentContact.sessionType == SessionTypeEnum.P2P) {
                                recentContactSet.add(recentContact.contactId)
                            }
                        }
                        for (account in accounts) {
                            if (!recentContactSet.contains(account)) {
                                unSubs.add(account)
                            }
                        }
                    }
                    if (!unSubs.isEmpty()) {
                        OnlineStateEventSubscribe.unSubscribeOnlineStateEvent(unSubs)
                    }
                }
            })
        }

        override fun onAddUserToBlackList(account: List<String>) {}
        override fun onRemoveUserFromBlackList(account: List<String>) {}
    }

    /**
     * 在登陆状态变为已登录之后，发布自己的在线状态，订阅事件
     */
    private fun registerOnlineStatusObserver() {
        NIMClient.getService(AuthServiceObserver::class.java).observeOnlineStatus(Observer { statusCode ->
            if (statusCode != StatusCode.LOGINED) {
                return@Observer
            }
            LogUtil.ui("status change to login so publish state and subscribe")
            // 发布自己的在线状态
            pubNetState = -1
            publishOnlineStateEvent(false)
            // 订阅在线状态，包括好友以及最近联系人
            OnlineStateEventSubscribe.initSubscribes()
        }, true)
    }

    private val receiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            val action = intent.action
            if (action == ConnectivityManager.CONNECTIVITY_ACTION) {
                val info = cm.activeNetworkInfo
                if (info == null || !info.isAvailable) {
                    return
                }
                LogUtil.ui("BroadcastReceiver CONNECTIVITY_ACTION " + info.type + info.typeName + info.extraInfo)
                if (NIMClient.getStatus() == StatusCode.LOGINED) {
                    publishOnlineStateEvent(false)
                }
            }
        }
    }

    private fun registerNetTypeChangeObserver() {
        val filter = IntentFilter()
        filter.addAction(ConnectivityManager.CONNECTIVITY_ACTION)
        NimCache.getContext().registerReceiver(receiver, filter)
    }

    /**
     * 注册事件观察者
     *
     * @param register
     */
    private fun registerEventObserver(register: Boolean) {
        NIMClient.getService(EventSubscribeServiceObserver::class.java).observeEventChanged(Observer { events ->
            // 过滤掉旧的事件
            var events = events
            events = EventFilter.getInstance().filterOlderEvent(events)
            if (events == null) {
                return@Observer
            }
            // 筛选出在线状态事件
            val onlineStateEvents: MutableList<Event> = ArrayList()
            for (i in events.indices) {
                val e = events[i]
                if (NimOnlineStateEvent.isOnlineStateEvent(e)) {
                    onlineStateEvents.add(e)
                }
            }
            // 处理在线状态事件
            receivedOnlineStateEvents(onlineStateEvents)
        }, register)
    }

    /**
     * 从事件中获取该账户的多端在线状态信息
     *
     * @param event
     * @return
     */
    private fun getOnlineStateFromEvent(event: Event): Map<Int, OnlineState>? {
        if (!NimOnlineStateEvent.isOnlineStateEvent(event)) {
            return null
        }
        // 解析
        val clients = NimOnlineStateEvent.getOnlineClients(event) ?: return null
        val onlineStates: MutableMap<Int, OnlineState> = HashMap<Int, OnlineState>()
        for (i in clients.indices) {
            val clientType = clients[i]
            var state: OnlineState? = OnlineStateEventConfig.parseConfig(event.getConfigByClient(clientType), clientType)
            if (state == null) {
                state = OnlineState(clientType, NetStateCode.Unkown, OnlineStateCode.Online)
            }
            onlineStates[clientType] = state
        }
        return onlineStates
    }

    /**
     * 构建一个在线状态事件
     *
     * @param netState            当前在线网络状态
     * @param syncSelfEnable      是否多端同步
     * @param broadcastOnlineOnly 是否只广播给在线用户
     * @param expiry              事件有效期，单位秒
     * @return event
     */
    fun buildOnlineStateEvent(netState: Int, onlineState: Int, syncSelfEnable: Boolean, broadcastOnlineOnly: Boolean, expiry: Long): Event {
        val event = Event(NimOnlineStateEvent.EVENT_TYPE, NimOnlineStateEvent.MODIFY_EVENT_CONFIG, expiry)
        event.isSyncSelfEnable = syncSelfEnable
        event.isBroadcastOnlineOnly = broadcastOnlineOnly
        event.config = OnlineStateEventConfig.buildConfig(netState, onlineState)
        return event
    }

    /**
     * 接收到在线状态事件
     *
     * @param events
     */
    private fun receivedOnlineStateEvents(events: List<Event>) {
        val changed: MutableSet<String> = HashSet()
        for (event in events) {
            if (NimOnlineStateEvent.isOnlineStateEvent(event)) { // 获取优先级最高的在线客户端的状态
                val state: OnlineState? = getDisplayOnlineState(event)
                changed.add(event.publisherAccount)
                // 将事件缓存
                OnlineStateEventCache.cacheOnlineState(event.publisherAccount, state)
                LogUtil.ui("received and cached onlineState of account " + event.publisherAccount)
            }
        }
        // 如果 UIKit 使用在线状态功能，则通知在线状态变化
        if (NimUIKit.enableOnlineState()) {
            NimUIKit.getOnlineStateChangeObservable().notifyOnlineStateChange(changed)
        }
    }

    /**
     * 发布自己在线状态
     */
    fun publishOnlineStateEvent(force: Boolean) {
        if (!isEnable) {
            return
        }
        val netState = getNetWorkTypeName(NimCache.getContext())
        if (!force && netState == pubNetState) {
            return
        }
        pubNetState = netState
        val event = buildOnlineStateEvent(netState, OnlineStateCode.Online.value, true, false, EVENT_EXPIRY)
        LogUtil.ui("publish online event value = " + event.eventValue + " config = " + event.config)
        NIMClient.getService(EventSubscribeService::class.java).publishEvent(event)
    }

    // 获取网络类型
    private fun getNetWorkTypeName(context: Context): Int {
        return NetworkUtil.getNetworkTypeForLink(context)
    }

    /**
     * 多端在线时展示规则 PC > Mac > IOS/Android > Web
     */
    fun getDisplayOnlineState(event: Event): OnlineState? { // 获取多端的在线信息
        val multiClientStates: Map<Int, OnlineState>? = getOnlineStateFromEvent(event)
        // 取优先级最高的展示
        if (multiClientStates == null || multiClientStates.isEmpty()) {
            return null
        }
        var result: OnlineState? = null
        if (isOnline(multiClientStates[ClientType.Windows].also({ result = it }))) {
            return result
        } else if (isOnline(multiClientStates[ClientType.MAC].also({ result = it }))) {
            return result
        } else if (isOnline(multiClientStates[ClientType.iOS].also({ result = it }))) {
            return result
        } else if (isOnline(multiClientStates[ClientType.Android].also({ result = it }))) {
            return result
        } else if (isOnline(multiClientStates[ClientType.Web].also({ result = it }))) {
            return result
        }
        return null
    }

    private fun isOnline(state: OnlineState?): Boolean {
        return state != null && state.getOnlineState() !== OnlineStateCode.Offline
    }

    private fun validNetType(state: OnlineState?): Boolean {
        if (state == null) {
            return false
        }
        val netState: NetStateCode? = state.getNetState()
        return netState != null && netState !== NetStateCode.Unkown
    }

    /**
     * 在线状态显示文案
     *
     * @param context
     * @param state
     * @param simple
     * @return
     */
    fun getOnlineClientContent(context: Context, state: OnlineState?, simple: Boolean): String? {
        if (!isEnable) {
            return null
        }
        // 离线
        if (!isOnline(state)) {
            return context.getString(R.string.off_line)
        }
        // 忙碌
        if (state!!.getOnlineState() === OnlineStateCode.Busy) {
            return context.getString(R.string.on_line_busy)
        }
        val type: Int = state!!.onlineClient
        var result: String? = null
        when (type) {
            ClientType.Windows -> result = context.getString(R.string.on_line_pc)
            ClientType.MAC -> result = context.getString(R.string.on_line_mac)
            ClientType.Web -> result = context.getString(R.string.on_line_web)
            ClientType.Android -> result = getMobileOnlineClientString(context, state, false, simple)
            ClientType.iOS -> result = getMobileOnlineClientString(context, state, true, simple)
            else -> {
            }
        }
        return result
    }

    private fun getMobileOnlineClientString(context: Context, state: OnlineState?, ios: Boolean, simple: Boolean): String {
        val result: String
        val client = if (ios) context.getString(R.string.client_ios) else context.getString(R.string.client_aos)
        result = if (!validNetType(state)) {
            client + context.getString(R.string.on_line)
        } else {
            if (simple) { // 简单展示
                getDisplayNetState(state!!.getNetState()) + context.getString(R.string.on_line)
            } else { // 详细展示
                client + " - " + getDisplayNetState(state!!.getNetState()) + context.getString(R.string.on_line)
            }
        }
        return result
    }

    private fun getDisplayNetState(netStateCode: NetStateCode?): String {
        if (netStateCode == null || netStateCode === NetStateCode.Unkown) {
            return UNKNOWN
        }
        return if (netStateCode === NetStateCode._2G) {
            NET_TYPE_2G
        } else if (netStateCode === NetStateCode._3G) {
            NET_TYPE_3G
        } else if (netStateCode === NetStateCode._4G) {
            NET_TYPE_4G
        } else {
            NET_TYPE_WIFI
        }
    }

    /**
     * 检查是否已经订阅过
     *
     * @param account
     */
    fun checkSubscribe(account: String) {
        if (!isEnable) {
            return
        }
        if (OnlineStateEventSubscribe.subscribeFilter(account)) {
            return
        }
        // 未曾订阅过
        if (!OnlineStateEventCache.hasSubscribed(account)) {
            val accounts: MutableList<String> = ArrayList(1)
            accounts.add(account)
            LogUtil.ui("display online state but not subscribe $account")
            OnlineStateEventSubscribe.subscribeOnlineStateEvent(accounts, OnlineStateEventSubscribe.SUBSCRIBE_EXPIRY)
        }
    }

    /**
     * 允许在线状态事件,开发者开通在线状态后修改此处直接返回true
     */
    private fun enableOnlineStateEvent(): Boolean {
        val packageName: String = NimCache.getContext().getPackageName()
        return (packageName != null && packageName == "com.youxi.chat").also { isEnable = it }
    }
}