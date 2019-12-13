package com.youxi.chat.module.session.action

import android.content.Intent
import com.netease.nim.uikit.business.session.actions.BaseAction
import com.netease.nim.uikit.business.session.constant.RequestCode
import com.netease.nim.uikit.common.ToastHelper
import com.netease.nim.uikit.impl.cache.TeamDataCache
import com.netease.nimlib.sdk.msg.MessageBuilder
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum
import com.youxi.chat.R
import com.youxi.chat.module.session.activity.SendAckMsgActivity

/**
 * 已读回执action
 * Created by winnie on 2018/3/14.
 */
class AckMessageAction : BaseAction(R.drawable.message_plus_ack_selector, R.string.input_panel_ack_msg) {
    override fun onClick() { // 只在小于100人的群里有效
        val team = TeamDataCache.getInstance().getTeamById(container.account)
        if (team != null && team.memberCount > 100) {
            ToastHelper.showToast(container.activity, "已读回执适用于小于100人的群")
            return
        }
        SendAckMsgActivity.startActivity(container.activity, container.account, makeRequestCode(RequestCode.SEND_ACK_MESSAGE))
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent) {
        if (requestCode == RequestCode.SEND_ACK_MESSAGE) {
            val content = data.getStringExtra(SendAckMsgActivity.EXTRA_CONTENT)
            val message = MessageBuilder.createTextMessage(container.account, SessionTypeEnum.Team, content)
            message.setMsgAck()
            sendMessage(message)
        }
    }
}