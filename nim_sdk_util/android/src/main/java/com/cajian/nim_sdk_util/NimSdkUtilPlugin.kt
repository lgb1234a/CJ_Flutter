package com.cajian.nim_sdk_util

import android.content.Context
import android.os.Build
import android.text.TextUtils
import com.blankj.utilcode.util.*
import com.netease.nim.uikit.api.NimUIKit
import com.netease.nimlib.sdk.NIMSDK
import com.netease.nimlib.sdk.RequestCallback
import com.netease.nimlib.sdk.auth.LoginInfo
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum
import com.netease.nimlib.sdk.msg.model.RecentContact
import com.netease.nimlib.sdk.team.constant.TeamMessageNotifyTypeEnum
import com.netease.nimlib.sdk.team.model.TeamMember
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.lang.reflect.InvocationTargetException

/** NimSdkUtilPlugin  */
class NimSdkUtilPlugin private constructor(private val mRegistrar: Registrar) : MethodCallHandler {

    private val mContext: Context

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        // 适配iOS方法名,iOS中有参数的方法名带有冒号,Android中需要去掉
        val methodName = call.method.replace(":", "")
        if ("getPlatformVersion" == methodName) {
            result.success("Android " + Build.VERSION.RELEASE)
            return
        }
        try {
            val params = if (call.arguments == null) mapOf<Any, Any?>() else call.arguments
            val method = javaClass.getDeclaredMethod(methodName, Map::class.java, MethodChannel.Result::class.java)
            method.isAccessible = true
            method.invoke(this, params, result)
            return
        } catch (e: NoSuchMethodException) {
            e.printStackTrace()
        } catch (e: IllegalAccessException) {
            e.printStackTrace()
        } catch (e: InvocationTargetException) {
            e.printStackTrace()
        } catch (e: Exception) {
            e.printStackTrace()
        }

        ToastUtils.showLong("method ${call.method} notImplemented")
        result.notImplemented()
    }

    /**
     * 注册云信sdk
     */
    private fun registerSDK(params: Map<*, *>, result: MethodChannel.Result) {
        // 仅iOS需要,此处Android什么也不做,Android的初始化代码放在原生代码里面
        result.success(null)
    }

    /**
     * 云信登录
     *
     * @param params
     * @param result
     */
    private fun doLogin(params: Map<*, *>, result: MethodChannel.Result) {
        val accid = params["accid"] as String
        val token = params["token"] as String

        val loginInfo = LoginInfo(accid, token)
        NIMSDK.getAuthService()
                .login(loginInfo)
                .setCallback(object : RequestCallback<Any?> {
                    override fun onSuccess(param: Any?) {
                        LogUtils.d("云信登录成功")
                        BusUtils.post("didLogin", mapOf("accid" to accid, "token" to token))
                        result.success(true)
                    }

                    override fun onFailed(code: Int) {
                        LogUtils.d("云信登录失败, 错误码=$code")
                        result.success(false)
                    }

                    override fun onException(exception: Throwable?) {
                        LogUtils.e("云信登录异常, 异常原因=${exception?.message}")
                        result.success(false)
                    }
                })
    }

    /**
     * 自动登录
     *
     * @param params
     * @param result
     */
    private fun autoLogin(params: Map<*, *>, result: MethodChannel.Result) {
        // 仅iOS需要,此处Android什么也不做,Android的初始化代码放在原生代码里面
//        val accid = params["accid"] as String
//        val token = params["token"] as String
//
//        val loginInfo = LoginInfo(accid, token)
//        NIMSDK.getAuthService()
//                .login(loginInfo)
//                .setCallback(object : RequestCallback<Any?> {
//                    override fun onSuccess(param: Any?) {
//                        LogUtils.d("云信登录成功")
//                        result.success(true)
//                    }
//
//                    override fun onFailed(code: Int) {
//                        LogUtils.d("云信登录失败, 错误码=$code")
//                        result.success(false)
//                    }
//
//                    override fun onException(exception: Throwable?) {
//                        LogUtils.e("云信登录异常, 异常原因=${exception?.message}")
//                        result.success(false)
//                    }
//                })
    }

    /**
     * 自动登录
     *
     * @param accid
     * @param token
     */
    private fun autoLogin(accid: String, token: String) {
        // 仅iOS需要,此处Android什么也不做,Android的初始化代码放在原生代码里面
//        val loginInfo = LoginInfo(accid, token)
//        NIMSDK.getAuthService()
//                .login(loginInfo)
//                .setCallback(object : RequestCallback<Any?> {
//                    override fun onSuccess(param: Any?) {
//                        LogUtils.d("云信登录成功")
//                    }
//
//                    override fun onFailed(code: Int) {
//                        LogUtils.d("云信登录失败, 错误码=$code")
//                    }
//
//                    override fun onException(exception: Throwable?) {
//                        LogUtils.e("云信登录异常, 异常原因=${exception?.message}")
//                    }
//                })
    }

    /**
     * 登出
     *
     * @param params
     */
    private fun logout(params: Map<*, *>, result: MethodChannel.Result) {
        NIMSDK.getAuthService().logout()
        SPUtils.getInstance().remove("flutter.accid")
        SPUtils.getInstance().remove("flutter.token")
        // TODO 发送didLogout通知
    }

    /**
     * 返回用户信息
     */
    private fun userInfo(params: Map<*, *>, result: MethodChannel.Result) {
        var accid = params["userId"] as String?
        if (StringUtils.isEmpty(accid)) {
            accid = NimUIKit.getAccount()
        }
        val userInfo = NIMSDK.getUserService().getUserInfo(accid)
        val alias = NIMSDK.getFriendService().getFriendByAccount(accid)?.alias
        result.success(mapOf(
                "showName" to userInfo.name,
                "avatarUrlString" to userInfo.avatar,
                "thumbAvatarUrl" to userInfo.avatar,
                "sign" to userInfo.signature,
                "gender" to userInfo.genderEnum.value,
                "email" to userInfo.email,
                "birth" to userInfo.birthday,
                "mobile" to userInfo.mobile,
                "cajianNo" to userInfo.extensionMap["cajian_id"],
                "alias" to alias,
                "userId" to userInfo.account
        ))
    }

    /**
     * 返回群信息
     */
    private fun teamInfo(params: Map<*, *>, result: MethodChannel.Result) {
        val teamId = params["teamId"] as String
        val info = NimUIKit.getTeamProvider().getTeamById(teamId)
        val team = NIMSDK.getTeamService().queryTeamBlock(teamId)

        result.success(mapOf(
                "showName" to info.name,
                "avatarUrlString" to info.icon,
                "avatarImage" to null,
                "teamId" to team.id,
                "teamName" to team.name,
                "thumbAvatarUrl" to team.icon,
                "type" to team.type,
                "owner" to team.creator,
                "intro" to team.introduce,
                "announcement" to team.announcement,
                "memberNumber" to team.memberCount,
                "level" to team.memberLimit,
                "createTime" to team.createTime,
                "joinMode" to team.verifyType,
                "inviteMode" to team.teamInviteMode,
                "beInviteMode" to team.teamBeInviteMode,
                "updateInfoMode" to team.teamUpdateMode.value,
                "updateClientCustomMode" to team.teamExtensionUpdateMode.value,
                "serverCustomInfo" to team.extServer,
                "clientCustomInfo" to team.extension,
                "notifyStateForNewMsg" to team.messageNotifyType.value
        ))
    }

    /**
     * 获取好友列表
     */
    private fun friends(params: Map<*, *>, result: MethodChannel.Result) {
        val friends = mutableListOf<Map<*, *>>()
        NIMSDK.getFriendService().friends.forEach { friend ->
            val userInfo = NIMSDK.getUserService().getUserInfo(friend.account)
            friends.add(mapOf(
                    "infoId" to friend.account,
                    "showName" to if (TextUtils.isEmpty(friend.alias)) userInfo.name else friend.alias,
                    "avatarUrlString" to userInfo.avatar
            ))
        }
        result.success(friends)
    }

    /**
     * 群聊列表
     */
    private fun allMyTeams(params: Map<*, *>, result: MethodChannel.Result) {
        val teams = mutableListOf<Map<*, *>>()
        NIMSDK.getTeamService().queryTeamListBlock().forEach { team ->
            teams.add(mapOf(
                    "teamId" to team.id,
                    "teamName" to team.name,
                    "teamAvatar" to team.icon
            ))
        }
        result.success(teams)
    }

    /**
     * 群成员信息
     */
    private fun teamMemberInfos(params: Map<*, *>, result: MethodChannel.Result) {
        val teamId = params["teamId"] as String
        val teamMemberInfos = mutableListOf<Map<*, *>>()
        NIMSDK.getTeamService().queryMemberList(teamId)
                .setCallback(object : RequestCallback<MutableList<TeamMember>> {
                    override fun onSuccess(param: MutableList<TeamMember>?) {
                        param?.forEach { member ->
                            teamMemberInfos.add(mapOf(
                                    "teamId" to member.tid,
                                    "userId" to member.account,
                                    "invitor" to member.invitorAccid, // TODO ???
                                    "inviterAccid" to member.invitorAccid,
                                    "type" to member.type,
                                    "nickname" to member.teamNick,
                                    "isMuted" to member.isMute,
                                    "createTime" to member.joinTime,
                                    "customInfo" to member.extension
                            ))
                        }
                        result.success(teamMemberInfos)
                    }

                    override fun onFailed(code: Int) {
                        LogUtils.d("获取群成员列表失败, 错误码=$code")
                        result.success(teamMemberInfos)
                    }

                    override fun onException(exception: Throwable?) {
                        LogUtils.d("获取群成员列表异常, 异常原因=${exception?.message}")
                        result.success(teamMemberInfos)
                    }
                })
    }

    /**
     * 获取单个群成员信息
     *
     * @param params
     * @param result
     */
    private fun teamMemberInfo(params: Map<*, *>, result: MethodChannel.Result) {
        val teamId = params["teamId"] as String
        val userId = params["userId"] as String

        val member = NIMSDK.getTeamService().queryTeamMemberBlock(teamId, userId)
        result.success(mapOf(
                "teamId" to member.tid,
                "userId" to member.account,
                "invitor" to member.invitorAccid, // TODO ???
                "inviterAccid" to member.invitorAccid,
                "type" to member.type,
                "nickname" to member.teamNick,
                "isMuted" to member.isMute,
                "createTime" to member.joinTime,
                "customInfo" to member.extension
        ))
    }

    /**
     * 获取会话置顶状态
     *
     * @param params
     * @param result
     */
    private fun isStickedOnTop(params: Map<*, *>, result: MethodChannel.Result) {
        val sessionId = params["id"] as String
        val type = params["type"] as Int
        val recent = NIMSDK.getMsgService().queryRecentContact(sessionId, SessionTypeEnum.typeOfValue(type))
        val isTop = recentSessionIsMark(recent, 1)
        result.success(isTop)
    }

    /**
     * 获取会话是否开启消息提醒
     *
     * @param params
     * @param result
     */
    private fun isNotifyForNewMsg(params: Map<*, *>, result: MethodChannel.Result) {
        val sessionId = params["id"] as String
        val type = params["type"] as Int
        var notifyForNewMsg = false
        if (SessionTypeEnum.typeOfValue(type) == SessionTypeEnum.P2P) {
            notifyForNewMsg = NIMSDK.getFriendService().isNeedMessageNotify(sessionId)
        } else {
            notifyForNewMsg = NIMSDK.getTeamService().queryTeamBlock(sessionId).messageNotifyType == TeamMessageNotifyTypeEnum.All
        }
        result.success(notifyForNewMsg)
    }

    /**
     * 清空聊天记录
     *
     * @param params
     * @param result
     */
    private fun clearChatHistory(params: Map<*, *>, result: MethodChannel.Result) {
        val sessionId = params["id"] as String
        val type = params["type"] as Int

        NIMSDK.getMsgService().clearChattingHistory(sessionId, SessionTypeEnum.typeOfValue(type))
    }

    /**
     * 置顶聊天
     *
     * @param params
     * @param result
     */
    private fun stickSessinOnTop(params: Map<*, *>, result: MethodChannel.Result) {
        val sessionId = params["id"] as String
        val type = params["type"] as Int
        val isTop = params["isTop"] as Boolean
        if (isTop) {
            addRecentSessionMark(sessionId, type, 1)
        } else {
            removeRecentSessionMark(sessionId, type, 1)
        }
    }

    /**
     * 开关消息通知
     *
     * @param params
     * @param result
     */
    private fun changeNotifyStatus(params: Map<*, *>, result: MethodChannel.Result) {
        val sessionId = params["id"] as String
        val type = params["type"] as Int
        val needNotify = params["needNotify"] as Boolean

        val callback = object : RequestCallback<Void> {
            override fun onSuccess(param: Void?) {
                result.success(true)
            }

            override fun onFailed(code: Int) {
                ToastUtils.showShort("修改失败")
                result.success(false)
            }

            override fun onException(exception: Throwable?) {
                ToastUtils.showShort("修改失败")
                result.success(false)
            }
        }

        if (SessionTypeEnum.typeOfValue(type) == SessionTypeEnum.P2P) {
            NIMSDK.getFriendService().setMessageNotify(sessionId, needNotify).setCallback(callback)
        } else {
            if (needNotify) {
                NIMSDK.getTeamService().muteTeam(sessionId, TeamMessageNotifyTypeEnum.All)
            } else {
                NIMSDK.getTeamService().muteTeam(sessionId, TeamMessageNotifyTypeEnum.Mute)
            }
        }
    }

    /**
     * 退出群聊
     *
     * @param params
     * @param result
     */
    private fun quitTeam(params: Map<*, *>, result: MethodChannel.Result) {
        val teamId = params["teamId"] as String
        NIMSDK.getTeamService().quitTeam(teamId)
                .setCallback(object : RequestCallback<Void> {
                    override fun onSuccess(param: Void?) {
                        result.success(true)
                    }

                    override fun onFailed(code: Int) {
                        ToastUtils.showShort("退出群聊失败，请重试")
                        result.success(false)
                    }

                    override fun onException(exception: Throwable?) {
                        ToastUtils.showShort("退出群聊失败，请重试")
                        result.success(false)
                    }
                })
    }

    /**
     * 解散群聊
     *
     * @param params
     * @param result
     */
    private fun dismissTeam(params: Map<*, *>, result: MethodChannel.Result) {
        val teamId = params["teamId"] as String
        NIMSDK.getTeamService().dismissTeam(teamId)
                .setCallback(object : RequestCallback<Void> {
                    override fun onSuccess(param: Void?) {
                        result.success(true)
                    }

                    override fun onFailed(code: Int) {
                        ToastUtils.showShort("解散群聊失败，请重试")
                        result.success(false)
                    }

                    override fun onException(exception: Throwable?) {
                        ToastUtils.showShort("解散群聊失败，请重试")
                        result.success(false)
                    }
                })
    }

    private fun addRecentSessionMark(sessionId: String, sessionType: Int, type: Int) {
        val recent = NIMSDK.getMsgService().queryRecentContact(sessionId, SessionTypeEnum.typeOfValue(sessionType))
        recent?.let {
            recent.extension.put(keyForMarkType(type), true)
            NIMSDK.getMsgService().updateRecent(recent)
        }
    }

    private fun removeRecentSessionMark(sessionId: String, sessionType: Int, type: Int) {
        val recent = NIMSDK.getMsgService().queryRecentContact(sessionId, SessionTypeEnum.typeOfValue(sessionType))
        recent?.let {
            recent.extension.remove(keyForMarkType(type))
            NIMSDK.getMsgService().updateRecent(recent)
        }
    }

    private fun recentSessionIsMark(recent: RecentContact, type: Int) : Boolean{
        return recent.extension.get(keyForMarkType(type)) as Boolean
    }

    private fun keyForMarkType(type: Int): String? {
        val map = mapOf(
                0 to "NTESRecentSessionAtMark",
                1 to "NTESRecentSessionTopMark"
        )
        return map.get(type)
    }

    companion object {
        /** Plugin registration.  */
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "nim_sdk_util")
            channel.setMethodCallHandler(NimSdkUtilPlugin(registrar))
        }
    }

    init {
        mContext = mRegistrar.context()
    }
}