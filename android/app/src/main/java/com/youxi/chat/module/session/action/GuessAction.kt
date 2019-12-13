package com.youxi.chat.module.session.action

import com.netease.nim.uikit.business.session.actions.BaseAction
import com.netease.nimlib.sdk.chatroom.ChatRoomMessageBuilder
import com.netease.nimlib.sdk.msg.MessageBuilder
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum
import com.netease.nimlib.sdk.msg.model.IMMessage
import com.youxi.chat.R
import com.youxi.chat.module.session.extension.GuessAttachment

/**
 * Created by hzxuwen on 2015/6/11.
 */
class GuessAction : BaseAction(R.drawable.message_plus_guess_selector, R.string.input_panel_guess) {
    override fun onClick() {
        val attachment = GuessAttachment()
        val message: IMMessage
        message = if (container != null && container.sessionType == SessionTypeEnum.ChatRoom) {
            ChatRoomMessageBuilder.createChatRoomCustomMessage(account, attachment)
        } else {
            MessageBuilder.createCustomMessage(account, sessionType, attachment.value?.desc,
                    attachment)
        }
        sendMessage(message)
    }
}