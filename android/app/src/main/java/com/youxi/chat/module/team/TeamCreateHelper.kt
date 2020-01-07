package com.youxi.chat.module.team

import android.content.Context
import android.os.Handler
import android.widget.Toast
import com.blankj.utilcode.util.LogUtils
import com.netease.nim.uikit.business.team.helper.TeamHelper
import com.netease.nim.uikit.common.ui.dialog.DialogMaker
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.RequestCallback
import com.netease.nimlib.sdk.RequestCallbackWrapper
import com.netease.nimlib.sdk.msg.MessageBuilder
import com.netease.nimlib.sdk.msg.MsgService
import com.netease.nimlib.sdk.msg.constant.MsgStatusEnum
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum
import com.netease.nimlib.sdk.msg.model.CustomMessageConfig
import com.netease.nimlib.sdk.team.TeamService
import com.netease.nimlib.sdk.team.constant.*
import com.netease.nimlib.sdk.team.model.CreateTeamResult
import com.netease.nimlib.sdk.team.model.TeamMember
import com.netease.nimlib.sdk.uinfo.UserService
import com.youxi.chat.R
import com.youxi.chat.base.Config.baseUrl
import com.youxi.chat.base.net.CommonApi
import com.youxi.chat.module.main.activity.MainActivity
import com.youxi.chat.module.session.SessionHelper.startTeamSession
import com.youxi.chat.nim.NimCache.getContext
import io.reactivex.schedulers.Schedulers
import java.io.Serializable
import java.util.*

/**
 * Created by ganbin on 2018/12/10
 */
object TeamCreateHelper {

    private val TAG = TeamCreateHelper::class.java.simpleName
    private const val DEFAULT_TEAM_CAPACITY = 200
    /**
     * 创建讨论组
     */
    fun createNormalTeam(context: Context, memberAccounts: List<String?>?, isNeedBack: Boolean, callback: RequestCallback<CreateTeamResult?>?) {
        val teamName = "讨论组"
        DialogMaker.showProgressDialog(context, context.getString(R.string.empty), true)
        // 创建群
        val fields = HashMap<TeamFieldEnum, Serializable>()
        fields[TeamFieldEnum.Name] = teamName
        fields[TeamFieldEnum.BeInviteMode] = TeamBeInviteModeEnum.NoAuth
        fields[TeamFieldEnum.InviteMode] = TeamInviteModeEnum.All
        fields[TeamFieldEnum.VerifyType] = VerifyTypeEnum.Free
        NIMClient.getService(TeamService::class.java).createTeam(fields, TeamTypeEnum.Normal, "",
                memberAccounts).setCallback(
                object : RequestCallback<CreateTeamResult> {
                    override fun onSuccess(result: CreateTeamResult) {
                        DialogMaker.dismissProgressDialog()
                        val failedAccounts = result.failedInviteAccounts
                        if (failedAccounts != null && !failedAccounts.isEmpty()) {
                            TeamHelper.onMemberTeamNumOverrun(failedAccounts, context)
                        } else {
                            Toast.makeText(getContext(), R.string.create_team_success, Toast.LENGTH_SHORT).show()
                        }
                        if (isNeedBack) {
                            startTeamSession(context, result.team.id, MainActivity::class.java, null) // 进入创建的群
                        } else {
                            startTeamSession(context, result.team.id)
                        }
                        callback?.onSuccess(result)
                    }

                    override fun onFailed(code: Int) {
                        DialogMaker.dismissProgressDialog()
                        if (code == 801) {
                            val tip = context.getString(R.string.over_team_member_capacity, DEFAULT_TEAM_CAPACITY)
                            Toast.makeText(getContext(), tip,
                                    Toast.LENGTH_SHORT).show()
                        } else {
                            Toast.makeText(getContext(), R.string.create_team_failed,
                                    Toast.LENGTH_SHORT).show()
                        }
                        LogUtils.e(TAG, "create team error: $code")
                    }

                    override fun onException(exception: Throwable) {
                        DialogMaker.dismissProgressDialog()
                    }
                }
        )
    }

    /**
     * 创建高级群
     */
    fun createAdvancedTeam(context: Context, memberAccounts: List<String?>?, callback: RequestCallback<CreateTeamResult?>?) {
        var teamName = ""
        val userInfos = NIMClient.getService(UserService::class.java).getUserInfoList(memberAccounts)
        if (userInfos != null && userInfos.size < 3) {
            for (i in userInfos.indices) {
                teamName += userInfos[i].name
                teamName += "、"
            }
        } else {
            for (i in 0..2) {
                teamName += userInfos!![i].name
                teamName += "、"
            }
        }
        if (teamName.length > 10) {
            teamName = teamName.substring(0, 10)
            teamName += "..."
        }
        DialogMaker.showProgressDialog(context, context.getString(R.string.empty), true)
        // 创建群
        val type = TeamTypeEnum.Advanced
        val fields = HashMap<TeamFieldEnum, Serializable>()
        fields[TeamFieldEnum.Name] = teamName
        fields[TeamFieldEnum.BeInviteMode] = TeamBeInviteModeEnum.NoAuth
        fields[TeamFieldEnum.InviteMode] = TeamInviteModeEnum.All
        fields[TeamFieldEnum.VerifyType] = VerifyTypeEnum.Free
        NIMClient.getService(TeamService::class.java).createTeam(fields, type, "",
                memberAccounts).setCallback(
                object : RequestCallback<CreateTeamResult> {
                    override fun onSuccess(result: CreateTeamResult) {
                        LogUtils.i(TAG,
                                "create team success, team id =" + result.team.id + ", now begin to update property...")
                        callback?.onSuccess(result)
                        onCreateSuccess(context, result)
                    }

                    override fun onFailed(code: Int) {
                        DialogMaker.dismissProgressDialog()
                        val tip = if (code == 801) {
                            context.getString(R.string.over_team_member_capacity,
                                    DEFAULT_TEAM_CAPACITY)
                        } else if (code == 806) {
                            context.getString(R.string.over_team_capacity)
                        } else {
                            context.getString(R.string.create_team_failed) + ", code=" + code
                        }
                        Toast.makeText(context, tip, Toast.LENGTH_SHORT).show()
                        LogUtils.e(TAG, "create team error: $code")
                    }

                    override fun onException(exception: Throwable) {
                        DialogMaker.dismissProgressDialog()
                    }
                }
        )
    }

    /**
     * 群创建成功回调
     */
    private fun onCreateSuccess(context: Context, result: CreateTeamResult?) {
        if (result == null) {
            LogUtils.e(TAG, "onCreateSuccess exception: team is null")
            return
        }
        val team = result.team
        if (team == null) {
            LogUtils.e(TAG, "onCreateSuccess exception: team is null")
            return
        }
        LogUtils.i(TAG, "create and update team success")
        DialogMaker.dismissProgressDialog()
        // 检查有没有邀请失败的成员
        val failedAccounts = result.failedInviteAccounts
        if (failedAccounts != null && !failedAccounts.isEmpty()) {
            TeamHelper.onMemberTeamNumOverrun(failedAccounts, context)
        } else {
            Toast.makeText(getContext(), R.string.create_team_success, Toast.LENGTH_SHORT).show()
        }
        // 演示：向群里插入一条Tip消息，使得该群能立即出现在最近联系人列表（会话列表）中，满足部分开发者需求
        val content: MutableMap<String, Any> = HashMap(1)
        content["content"] = "成功创建高级群"
        val msg = MessageBuilder.createTipMessage(team.id, SessionTypeEnum.Team)
        msg.remoteExtension = content
        val config = CustomMessageConfig()
        config.enableUnreadCount = false
        msg.config = config
        msg.status = MsgStatusEnum.success
        NIMClient.getService(MsgService::class.java).saveMessageToLocal(msg, true)
        groupCreateLog(team.id, team.creator)
        NIMClient.getService(TeamService::class.java).queryMemberList(team.id)
                .setCallback(object : RequestCallbackWrapper<List<TeamMember>?>() {
                    override fun onResult(code: Int, members: List<TeamMember>?, exception: Throwable?) {
                        if (members != null) {
                            groupMemberChange(members.map { it.account }.toList(), team.id, team.creator, "in")
                        }
                    }
                })
        // 发送后，稍作延时后跳转
        Handler(context.mainLooper).postDelayed({
            startTeamSession(context, team.id) // 进入创建的群
        }, 50)
    }

    fun groupCreateLog(teamId: String, creator: String) {
        val json = mapOf(
                "group_id" to teamId,
                "owner_accid" to creator,
                "mode" to "create"
        )
        val url = "$baseUrl/g2/group/create/log"
        CommonApi.getApi().postJson(url, json = json)
                .subscribeOn(Schedulers.io())
                .subscribe()
    }

    fun groupMemberChange(members: List<String>, teamId: String, operator: String, mode: String) {
        val json = mapOf(
                "group_id" to teamId,
                "ch_users" to members,
                "op_user" to operator,
                "mode" to mode
        )
        val url = "$baseUrl/g2/group/user/change"
        CommonApi.getApi().postJson(url, json = json)
                .subscribeOn(Schedulers.io())
                .subscribe()
    }
}