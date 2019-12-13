package com.youxi.chat.module.session.action

import com.netease.nim.uikit.business.session.actions.PickImageAction
import com.netease.nimlib.sdk.msg.MessageBuilder
import com.netease.nimlib.sdk.msg.model.CustomMessageConfig
import com.youxi.chat.R
import com.youxi.chat.module.session.extension.SnapChatAttachment
import java.io.File

/**
 * Created by zhoujianghua on 2015/7/31.
 */
class SnapChatAction : PickImageAction(R.drawable.message_plus_snapchat_selector, R.string.input_panel_snapchat, false) {
    override fun onPicked(file: File) {
        val snapChatAttachment = SnapChatAttachment()
        snapChatAttachment.setPath(file.path)
        snapChatAttachment.setSize(file.length())
        val config = CustomMessageConfig()
        config.enableHistory = false
        config.enableRoaming = false
        config.enableSelfSync = false
        val stickerMessage = MessageBuilder.createCustomMessage(account, sessionType, "阅后即焚消息", snapChatAttachment, config)
        sendMessage(stickerMessage)
    }
}