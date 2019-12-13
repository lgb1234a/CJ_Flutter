package com.youxi.chat.module.session.action

import com.netease.nim.uikit.business.session.actions.BaseAction
import com.netease.nimlib.sdk.msg.MessageBuilder
import com.netease.nimlib.sdk.msg.model.CustomMessageConfig
import com.youxi.chat.R

/**
 * Tip类型消息测试
 * Created by hzxuwen on 2016/3/9.
 */
class TipAction : BaseAction(R.drawable.message_plus_tip_selector, R.string.input_panel_tip) {
    override fun onClick() {
        val msg = MessageBuilder.createTipMessage(account, sessionType)
        msg.content = "一条Tip测试消息"
        val config = CustomMessageConfig()
        config.enablePush = false // 不推送
        msg.config = config
        sendMessage(msg)
    }
}