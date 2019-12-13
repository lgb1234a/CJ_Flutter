package com.youxi.chat.module.session.action

import android.content.Intent
import android.text.TextUtils
import com.netease.nim.avchatkit.AVChatKit
import com.netease.nim.avchatkit.AVChatProfile
import com.netease.nim.avchatkit.TeamAVChatProfile
import com.netease.nim.avchatkit.teamavchat.activity.TeamAVChatActivity
import com.netease.nim.uikit.api.NimUIKit
import com.netease.nim.uikit.api.model.SimpleCallback
import com.netease.nim.uikit.business.contact.core.item.ContactItem
import com.netease.nim.uikit.business.contact.core.item.ContactItemFilter
import com.netease.nim.uikit.business.contact.selector.activity.ContactSelectActivity
import com.netease.nim.uikit.business.team.helper.TeamHelper
import com.netease.nim.uikit.business.team.model.TeamRequestCode
import com.netease.nim.uikit.common.ToastHelper
import com.netease.nim.uikit.common.util.log.LogUtil
import com.netease.nim.uikit.common.util.string.StringUtil
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.avchat.AVChatCallback
import com.netease.nimlib.sdk.avchat.AVChatManager
import com.netease.nimlib.sdk.avchat.constant.AVChatType
import com.netease.nimlib.sdk.avchat.model.AVChatChannelInfo
import com.netease.nimlib.sdk.msg.MessageBuilder
import com.netease.nimlib.sdk.msg.MsgService
import com.netease.nimlib.sdk.msg.constant.MsgStatusEnum
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum
import com.netease.nimlib.sdk.msg.model.CustomMessageConfig
import com.netease.nimlib.sdk.msg.model.CustomNotification
import com.netease.nimlib.sdk.msg.model.CustomNotificationConfig
import com.netease.nimlib.sdk.team.model.TeamMember
import com.youxi.chat.R
import com.youxi.chat.nim.NimCache
import java.io.Serializable
import java.util.*

/**
 * Created by hzchenkang on 2017/5/3.
 */
class TeamAVChatAction(avChatType: AVChatType) : AVChatAction(avChatType) {
    // private String teamID;
    private var transaction: LaunchTransaction? = null

    override fun startAudioVideoCall(avChatType: AVChatType) {
        if (AVChatProfile.getInstance().isAVChatting) {
            ToastHelper.showToast(getActivity(), "正在进行P2P视频通话，请先退出")
            return
        }
        if (TeamAVChatProfile.sharedInstance().isTeamAVChatting) { // 视频通话界面正在运行，singleTop所以直接调起来
            val localIntent = Intent()
            localIntent.setClass(getActivity(), TeamAVChatActivity::class.java)
            localIntent.flags = Intent.FLAG_ACTIVITY_SINGLE_TOP
            getActivity().startActivity(localIntent)
            return
        }
        if (transaction != null) {
            return
        }
        val tid: String = getAccount()
        if (TextUtils.isEmpty(tid)) {
            return
        }
        transaction = LaunchTransaction()
        transaction!!.teamID = tid
        // load 一把群成员
        NimUIKit.getTeamProvider().fetchTeamMemberList(tid, object : SimpleCallback<List<TeamMember>> {
            override fun onResult(success: Boolean, result: List<TeamMember>, code: Int) { // 检查下 tid 是否相等
                if (!checkTransactionValid()) {
                    return
                }
                if (success && result != null) {
                    if (result.size < 2) {
                        transaction = null
                        ToastHelper.showToast(getActivity(), getActivity().getString(R.string.t_avchat_not_start_with_less_member))
                    } else {
                        NimUIKit.startContactSelector(getActivity(), getContactSelectOption(tid), TeamRequestCode.REQUEST_TEAM_VIDEO)
                    }
                }
            }
        })
    }

    fun onSelectedAccountFail() {
        transaction = null
    }

    fun onSelectedAccountsResult(accounts: ArrayList<String>) {
        LogUtil.ui("start teamVideo " + getAccount().toString() + " accounts = " + accounts)
        if (!checkTransactionValid()) {
            return
        }
        val roomName = StringUtil.get32UUID()
        LogUtil.ui("create room $roomName")
        // 创建房间
        AVChatManager.getInstance().createRoom(roomName, null, object : AVChatCallback<AVChatChannelInfo> {
            override fun onSuccess(avChatChannelInfo: AVChatChannelInfo) {
                LogUtil.ui("create room $roomName success !")
                if (!checkTransactionValid()) {
                    return
                }
                onCreateRoomSuccess(roomName, accounts)
                transaction!!.roomName = roomName
                val teamName = TeamHelper.getTeamName(transaction!!.teamID)
                TeamAVChatProfile.sharedInstance().isTeamAVChatting = true
                AVChatKit.outgoingTeamCall(getActivity(), false, transaction!!.teamID, roomName, accounts, teamName)
                transaction = null
            }

            override fun onFailed(code: Int) {
                if (!checkTransactionValid()) {
                    return
                }
                onCreateRoomFail()
            }

            override fun onException(exception: Throwable?) {
                if (!checkTransactionValid()) {
                    return
                }
                onCreateRoomFail()
            }
        })
    }

    private fun checkTransactionValid(): Boolean {
        if (transaction == null) {
            return false
        }
        if (transaction!!.teamID == null || transaction!!.teamID != getAccount()) {
            transaction = null
            return false
        }
        return true
    }

    //
    private fun getContactSelectOption(teamId: String): ContactSelectActivity.Option {
        val option = ContactSelectActivity.Option()
        option.type = ContactSelectActivity.ContactSelectType.TEAM_MEMBER
        option.teamId = teamId
        option.maxSelectNum = MAX_INVITE_NUM
        option.maxSelectNumVisible = true
        option.title = NimUIKit.getContext().getString(R.string.invite_member)
        option.maxSelectedTip = NimUIKit.getContext().getString(R.string.reach_capacity)
        option.itemFilter = ContactItemFilter { item ->
            val contact = (item as ContactItem).contact
            // 过滤掉自己
            contact.contactId == NimCache.getAccount()
        }
        return option
    }

    private fun onCreateRoomSuccess(roomName: String, accounts: List<String>) {
        val teamID = transaction!!.teamID
        // 在群里发送tip消息
        val message = MessageBuilder.createTipMessage(teamID, SessionTypeEnum.Team)
        val tipConfig = CustomMessageConfig()
        tipConfig.enableHistory = false
        tipConfig.enableRoaming = false
        tipConfig.enablePush = false
        val teamNick = TeamHelper.getDisplayNameWithoutMe(teamID, NimCache.getAccount())
        message.content = teamNick + getActivity().getString(R.string.t_avchat_start)
        message.config = tipConfig
        sendMessage(message)
        // 对各个成员发送点对点自定义通知
        val teamName = TeamHelper.getTeamName(transaction!!.teamID)
        val content = TeamAVChatProfile.sharedInstance().buildContent(roomName, teamID, accounts, teamName)
        val config = CustomNotificationConfig()
        config.enablePush = true
        config.enablePushNick = false
        config.enableUnreadCount = true
        for (account in accounts) {
            val command = CustomNotification()
            command.sessionId = account
            command.sessionType = SessionTypeEnum.P2P
            command.config = config
            command.content = content
            command.apnsText = teamNick + getActivity().getString(R.string.t_avchat_push_content)
            command.isSendToOnlineUserOnly = false
            NIMClient.getService(MsgService::class.java).sendCustomNotification(command)
        }
    }

    private fun onCreateRoomFail() { // 本地插一条tip消息
        val message = MessageBuilder.createTipMessage(transaction!!.teamID, SessionTypeEnum.Team)
        message.content = getActivity().getString(R.string.t_avchat_create_room_fail)
        LogUtil.i("status", "team action set:" + MsgStatusEnum.success)
        message.status = MsgStatusEnum.success
        NIMClient.getService(MsgService::class.java).saveMessageToLocal(message, true)
    }

    private inner class LaunchTransaction : Serializable {
        var teamID: String? = null
        var roomName: String? = null

    }

    companion object {
        private const val MAX_INVITE_NUM = 8
    }
}