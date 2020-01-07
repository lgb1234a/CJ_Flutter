package com.youxi.chat.module.session

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.view.View
import com.netease.nim.uikit.api.NimUIKit
import com.netease.nim.uikit.api.model.session.SessionCustomization
import com.netease.nim.uikit.business.contact.selector.activity.ContactSelectActivity
import com.netease.nim.uikit.business.team.model.TeamExtras
import com.netease.nim.uikit.business.team.model.TeamRequestCode
import com.netease.nim.uikit.common.ToastHelper
import com.netease.nimlib.sdk.msg.attachment.MsgAttachment
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum
import com.youxi.chat.R
import com.youxi.chat.Router
import com.youxi.chat.hybird.FlutterRouter
import com.youxi.chat.module.session.extension.StickerAttachment
import java.io.Serializable
import java.util.*

/**
 * 抽象出来的，群组更多定制化选项，普通群和高级群同样功能的抽象
 * Created by winnie on 2018/3/19.
 */
open class SessionTeamCustomization(private val sessionTeamCustomListener: SessionTeamCustomListener) : SessionCustomization() {
    interface SessionTeamCustomListener : Serializable {
        fun initPopupWindow(context: Context, view: View, sessionId: String, sessionTypeEnum: SessionTypeEnum)
        fun onSelectedAccountsResult(selectedAccounts: ArrayList<String>)
        fun onSelectedAccountFail()
    }

    override fun onActivityResult(activity: Activity, requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == TeamRequestCode.REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                val reason = data!!.getStringExtra(TeamExtras.RESULT_EXTRA_REASON)
                val finish = reason != null && (reason == TeamExtras.RESULT_EXTRA_REASON_DISMISS || reason == TeamExtras.RESULT_EXTRA_REASON_QUIT)
                if (finish) {
                    activity.finish() // 退出or解散群直接退出多人会话
                }
            }
        } else if (requestCode == TeamRequestCode.REQUEST_TEAM_VIDEO) {
            if (resultCode == Activity.RESULT_OK) {
                val selectedAccounts = data!!.getStringArrayListExtra(ContactSelectActivity
                        .RESULT_DATA)
                sessionTeamCustomListener.onSelectedAccountsResult(selectedAccounts)
            } else {
                sessionTeamCustomListener.onSelectedAccountFail()
            }
        }
    }

    override fun createStickerAttachment(category: String, item: String): MsgAttachment {
        return StickerAttachment(category, item)
    }

    init {
        // 定制ActionBar右边的按钮，可以加多个
        val optionsButtons = ArrayList<OptionsButton>()
        val cloudMsgButton: OptionsButton = object : OptionsButton() {
            override fun onClick(context: Context, view: View, sessionId: String) {
                sessionTeamCustomListener.initPopupWindow(context, view, sessionId, SessionTypeEnum.Team)
            }
        }
        cloudMsgButton.iconId = R.drawable.nim_ic_messge_history
        val infoButton: OptionsButton = object : OptionsButton() {
            override fun onClick(context: Context, view: View, sessionId: String) {
                val team = NimUIKit.getTeamProvider().getTeamById(sessionId)
                if (team != null && team.isMyTeam) {
                    Router.open(context, FlutterRouter.sessionInfo, params = mapOf(
                            "type" to 1,
                            "id" to sessionId
                    ))
//                    NimUIKit.startTeamInfo(context, sessionId)
                } else {
                    ToastHelper.showToast(context, R.string.team_invalid_tip)
                }
            }
        }
        infoButton.iconId = R.drawable.ic_message_actionbar_more
//        optionsButtons.add(cloudMsgButton)
        optionsButtons.add(infoButton)
        buttons = optionsButtons
        withSticker = true
    }
}