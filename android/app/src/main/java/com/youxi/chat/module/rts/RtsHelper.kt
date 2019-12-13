package com.youxi.chat.module.rts

import android.content.Context
import com.netease.nim.rtskit.RTSKit
import com.netease.nim.rtskit.api.IUserInfoProvider
import com.netease.nim.rtskit.api.config.RTSOptions
import com.netease.nim.rtskit.api.listener.RTSEventListener
import com.netease.nim.rtskit.common.log.ILogUtil
import com.netease.nim.uikit.api.NimUIKit
import com.netease.nim.uikit.business.session.helper.MessageListPanelHelper
import com.netease.nim.uikit.business.uinfo.UserInfoHelper
import com.netease.nim.uikit.common.util.log.LogUtil
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.msg.MessageBuilder
import com.netease.nimlib.sdk.msg.MsgService
import com.netease.nimlib.sdk.msg.constant.MsgDirectionEnum
import com.netease.nimlib.sdk.msg.constant.MsgStatusEnum
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum
import com.netease.nimlib.sdk.uinfo.model.UserInfo
import com.youxi.chat.module.main.activity.MainActivity
import com.youxi.chat.module.session.extension.RTSAttachment

/**
 * Created by winnie on 2018/3/26.
 */
object RtsHelper {
    fun init() {
        setOptions()
        setRtsEventListener()
        setLogUtil()
        setUserInfoProvider()
    }

    private fun setOptions() {
        val rtsOptions: RTSOptions = object : RTSOptions() {
            override fun logout(context: Context?) {
                MainActivity.logout(context!!, true)
            }
        }
        RTSKit.init(rtsOptions)
    }

    // 设置rts事件监听器
    private fun setRtsEventListener() {
        RTSKit.setRTSEventListener(object : RTSEventListener {
            override fun onRTSStartSuccess(account: String) {
                val attachment = RTSAttachment(0.toByte())
                val msg = MessageBuilder.createCustomMessage(account, SessionTypeEnum.P2P,
                        attachment.content, attachment)
                MessageListPanelHelper.getInstance().notifyAddMessage(msg) // 界面上add一条
                NIMClient.getService(MsgService::class.java).sendMessage(msg, false) // 发送给对方
            }

            override fun onRTSFinish(account: String, selfFinish: Boolean) {
                val attachment = RTSAttachment(1.toByte())
                val msg = MessageBuilder.createCustomMessage(account, SessionTypeEnum.P2P,
                        attachment.content, attachment)
                if (!selfFinish) { // 被结束会话，在这里模拟一条接收的消息
                    msg.fromAccount = account
                    msg.direct = MsgDirectionEnum.In
                }
                msg.status = MsgStatusEnum.success
                NIMClient.getService(MsgService::class.java).saveMessageToLocal(msg, true)
            }
        })
    }

    // 设置日志系统
    private fun setLogUtil() {
        RTSKit.setiLogUtil(object : ILogUtil {
            override fun ui(msg: String) {
                LogUtil.ui(msg)
            }

            override fun e(tag: String, msg: String) {
                LogUtil.e(tag, msg)
            }

            override fun i(tag: String, msg: String) {
                LogUtil.i(tag, msg)
            }

            override fun d(tag: String, msg: String) {
                LogUtil.d(tag, msg)
            }
        })
    }

    // 设置用户相关资料提供者
    private fun setUserInfoProvider() {
        RTSKit.setUserInfoProvider(object : IUserInfoProvider() {
            override fun getUserInfo(account: String): UserInfo {
                return NimUIKit.getUserInfoProvider().getUserInfo(account)
            }

            override fun getUserDisplayName(account: String): String {
                return UserInfoHelper.getUserDisplayName(account)
            }
        })
    }
}