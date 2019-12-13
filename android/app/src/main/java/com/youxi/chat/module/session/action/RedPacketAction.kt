package com.youxi.chat.module.session.action

import android.app.Activity
import android.content.Intent
import com.netease.nim.uikit.business.session.actions.BaseAction
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum
import com.youxi.chat.R

class RedPacketAction : BaseAction(R.drawable.message_plus_rp_selector, R.string.app_name) {
    override fun onClick() {
        val requestCode: Int
        requestCode = if (container.sessionType == SessionTypeEnum.Team) {
            makeRequestCode(CREATE_GROUP_RED_PACKET)
        } else if (container.sessionType == SessionTypeEnum.P2P) {
            makeRequestCode(CREATE_SINGLE_RED_PACKET)
        } else {
            return
        }
//        NIMRedPacketClient.startSendRpActivity(activity, container.sessionType, account, requestCode)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent) {
        if (resultCode != Activity.RESULT_OK) {
            return
        }
        sendRpMessage(data)
    }

    private fun sendRpMessage(data: Intent) {
//        val groupRpBean: EnvelopeBean = JrmfRpClient.getEnvelopeInfo(data) ?: return
//        val attachment = RedPacketAttachment()
//        // 红包id，红包信息，红包名称
//        attachment.setRpId(groupRpBean.getEnvelopesID())
//        attachment.setRpContent(groupRpBean.getEnvelopeMessage())
//        attachment.setRpTitle(groupRpBean.getEnvelopeName())
//        val content = activity.getString(R.string.rp_push_content)
//        // 不存云消息历史记录
//        val config = CustomMessageConfig()
//        config.enableHistory = false
//        val message = MessageBuilder.createCustomMessage(account, sessionType, content, attachment, config)
//        sendMessage(message)
    }

    companion object {
        private const val CREATE_GROUP_RED_PACKET = 51
        private const val CREATE_SINGLE_RED_PACKET = 10
    }
}