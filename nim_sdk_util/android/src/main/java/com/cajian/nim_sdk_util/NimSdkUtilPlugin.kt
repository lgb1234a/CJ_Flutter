package com.cajian.nim_sdk_util

import android.content.Context
import android.os.Build
import android.text.TextUtils
import com.blankj.utilcode.util.*
import com.netease.nim.uikit.api.NimUIKit
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.NIMSDK
import com.netease.nimlib.sdk.RequestCallback
import com.netease.nimlib.sdk.auth.LoginInfo
import com.netease.nimlib.sdk.msg.MessageBuilder
import com.netease.nimlib.sdk.msg.SystemMessageService
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum
import com.netease.nimlib.sdk.msg.model.RecentContact
import com.netease.nimlib.sdk.team.constant.TeamFieldEnum
import com.netease.nimlib.sdk.team.constant.TeamMessageNotifyTypeEnum
import com.netease.nimlib.sdk.team.model.TeamMember
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.File
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
        clearLoginInfo()
        // TODO 发送didLogout通知
    }

    /**
     * 清除登录信息
     */
    private fun clearLoginInfo() {
        SPUtils.getInstance().remove("flutter.accid")
        SPUtils.getInstance().remove("flutter.token")
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

    /**
     * 判断用户是否被拉黑
     */
    private fun isUserBlocked(params: Map<*, *>, result: MethodChannel.Result) {
        val userId = params["userId"] as String
        val isBlocked = NIMSDK.getFriendService().isInBlackList(userId)
        result.success(isBlocked)
    }

    /**
     * 把用户加入黑名单
     */
    private fun blockUser(params: Map<*, *>, result: MethodChannel.Result) {
        val userId = params["userId"] as String
        NIMSDK.getFriendService().addToBlackList(userId)
                .setCallback(object : RequestCallback<Void> {
                    override fun onSuccess(param: Void?) {
                        ToastUtils.showShort("加入黑名单成功")
                        result.success(true)
                    }

                    override fun onFailed(code: Int) {
                        ToastUtils.showShort("加入黑名单失败")
                        result.success(false)
                    }

                    override fun onException(exception: Throwable?) {
                        ToastUtils.showShort("加入黑名单失败")
                        result.success(false)
                    }
                })
    }

    /**
     * 移出黑名单
     */
    private fun cancelBlockUser(params: Map<*, *>, result: MethodChannel.Result) {
        val userId = params["userId"] as String
        NIMSDK.getFriendService().removeFromBlackList(userId)
                .setCallback(object : RequestCallback<Void> {
                    override fun onSuccess(param: Void?) {
                        ToastUtils.showShort("移出黑名单成功")
                        result.success(true)
                    }

                    override fun onFailed(code: Int) {
                        ToastUtils.showShort("移出黑名单失败")
                        result.success(false)
                    }

                    override fun onException(exception: Throwable?) {
                        ToastUtils.showShort("移出黑名单失败")
                        result.success(false)
                    }
                })
    }

    /**
     * 返回黑名单列表
     */
    private fun blockUserList(params: Map<*, *>, result: MethodChannel.Result) {
        val blackList = NIMSDK.getFriendService().blackList
        result.success(blackList)
    }

    /**
     * 修改成员群昵称
     */
    private fun updateUserNickName(params: Map<*, *>, result: MethodChannel.Result) {
        val userId = params["userId"] as String
        val nickName = params["nickName"] as String
        val teamId = params["teamId"] as String

        NIMSDK.getTeamService().updateMemberNick(teamId, userId, nickName)
                .setCallback(object : RequestCallback<Void> {
                    override fun onSuccess(param: Void?) {
                        ToastUtils.showShort("修改昵称成功")
                        result.success(true)
                    }

                    override fun onFailed(code: Int) {
                        ToastUtils.showShort("修改昵称失败")
                        result.success(false)
                    }

                    override fun onException(exception: Throwable?) {
                        ToastUtils.showShort("修改昵称失败")
                        result.success(false)
                    }
                })
    }

    /**
     * 修改群名称
     */
    private fun updateTeamName(params: Map<*, *>, result: MethodChannel.Result) {
        val teamName = params["teamName"] as String
        val teamId = params["teamId"] as String

        NIMSDK.getTeamService().updateMyTeamNick(teamId, teamName)
                .setCallback(object : RequestCallback<Void> {
                    override fun onSuccess(param: Void?) {
                        ToastUtils.showShort("修改群名称成功")
                        result.success(true)
                    }

                    override fun onFailed(code: Int) {
                        ToastUtils.showShort("修改群名称失败")
                        result.success(false)
                    }

                    override fun onException(exception: Throwable?) {
                        ToastUtils.showShort("修改群名称失败")
                        result.success(false)
                    }
                })
    }

    /**
     * 修改群公告
     */
    private fun updateAnnouncement(params: Map<*, *>, result: MethodChannel.Result) {
        val teamId = params["teamId"] as String
        val announcement = params["announcement"] as String
        NIMSDK.getTeamService().updateTeam(teamId, TeamFieldEnum.Announcement, announcement)
                .setCallback(object : RequestCallback<Void> {
                    override fun onSuccess(param: Void?) {
                        ToastUtils.showShort("修改群公告成功")
                        result.success(true)
                    }

                    override fun onFailed(code: Int) {
                        ToastUtils.showShort("修改群公告失败")
                        result.success(false)
                    }

                    override fun onException(exception: Throwable?) {
                        ToastUtils.showShort("修改群公告失败")
                        result.success(false)
                    }
                })
    }

    /**
     * 添加管理员
     */
    private fun addTeamManagers(params: Map<*, *>, result: MethodChannel.Result) {
        val teamId = params["teamId"] as String
        val userIds = params["userIds"] as List<String>
        NIMSDK.getTeamService().addManagers(teamId, userIds)
                .setCallback(object : RequestCallback<List<TeamMember>> {
                    override fun onSuccess(param: List<TeamMember>?) {
                        ToastUtils.showShort("添加成功")
                        result.success(true)
                    }

                    override fun onFailed(code: Int) {
                        ToastUtils.showShort("添加失败")
                        result.success(false)
                    }

                    override fun onException(exception: Throwable?) {
                        ToastUtils.showShort("添加失败")
                        result.success(false)
                    }
                })
    }

    /**
     * 移除管理员
     */
    private fun removeTeamManagers(params: Map<*, *>, result: MethodChannel.Result) {
        val teamId = params["teamId"] as String
        val userIds = params["userIds"] as List<String>
        NIMSDK.getTeamService().removeManagers(teamId, userIds)
                .setCallback(object : RequestCallback<List<TeamMember>> {
                    override fun onSuccess(param: List<TeamMember>?) {
                        ToastUtils.showShort("移除成功")
                        result.success(true)
                    }

                    override fun onFailed(code: Int) {
                        ToastUtils.showShort("移除失败")
                        result.success(false)
                    }

                    override fun onException(exception: Throwable?) {
                        ToastUtils.showShort("移除失败")
                        result.success(false)
                    }
                })
    }

    /**
     * 移交群
     */
    private fun transformTeam(params: Map<*, *>, result: MethodChannel.Result) {
        val teamId = params["teamId"] as String
        val owner = params["owner"] as String
        NIMSDK.getTeamService().transferTeam(teamId, owner, false)
                .setCallback(object : RequestCallback<List<TeamMember>> {
                    override fun onSuccess(param: List<TeamMember>?) {
                        ToastUtils.showShort("移交成功")
                        result.success(true)
                    }

                    override fun onFailed(code: Int) {
                        ToastUtils.showShort("移交失败")
                        result.success(false)
                    }

                    override fun onException(exception: Throwable?) {
                        ToastUtils.showShort("移交失败")
                        result.success(false)
                    }
                })
    }

    /**
     * 更新群头像
     */
    private fun updateTeamAvatar(params: Map<*, *>, result: MethodChannel.Result) {
        val avatarUrl = params["avatarUrl"] as String
        val teamId = params["teamId"] as String
        NIMSDK.getTeamService().updateTeam(teamId, TeamFieldEnum.ICON, avatarUrl)
                .setCallback(object : RequestCallback<Void> {
                    override fun onSuccess(param: Void?) {
                        ToastUtils.showShort("更新头像成功")
                        result.success(true)
                    }

                    override fun onFailed(code: Int) {
                        ToastUtils.showShort("更新头像失败")
                        result.success(false)
                    }

                    override fun onException(exception: Throwable?) {
                        ToastUtils.showShort("更新头像失败")
                        result.success(false)
                    }
                })
    }

    /**
     * 上传文件到云信
     */
    private fun uploadFileToNim(params: Map<*, *>, result: MethodChannel.Result) {
        // TODO 云信文件上传
        val filePath = params["filePath"] as String
        NIMSDK.getNosService().upload(File(filePath), "")
                .setCallback(object : RequestCallback<String> {
                    override fun onSuccess(param: String?) {
                        ToastUtils.showShort("上传成功")
                        result.success(param)
                    }

                    override fun onFailed(code: Int) {
                        ToastUtils.showShort("上传失败")
                        result.success("")
                    }

                    override fun onException(exception: Throwable?) {
                        ToastUtils.showShort("上传失败")
                        result.success("")
                    }

                })
    }

    /**
     * 删除好友
     */
    private fun deleteContact(params: Map<*, *>, result: MethodChannel.Result) {
        val userId = params["userId"] as String
        NIMSDK.getFriendService().deleteFriend(userId, true)
                .setCallback(object : RequestCallback<Void> {
                    override fun onSuccess(param: Void?) {
                        ToastUtils.showShort("删除成功")
                        result.success(true)
                    }

                    override fun onFailed(code: Int) {
                        ToastUtils.showShort("删除失败")
                        result.success(false)
                    }

                    override fun onException(exception: Throwable?) {
                        ToastUtils.showShort("删除失败")
                        result.success(false)
                    }

                })
    }

    /**
     * 允许用户新消息通知
     */
    private fun allowUserMsgNotify(params: Map<*, *>, result: MethodChannel.Result) {
        val userId = params["userId"] as String
        val notify = params["allowNotify"] as Boolean
        NIMSDK.getFriendService().setMessageNotify(userId, notify)
                .setCallback(object : RequestCallback<Void> {
                    override fun onSuccess(param: Void?) {
                        ToastUtils.showShort("修改成功")
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

                })
    }

    /**
     * 获取系统通知
     */
    private fun fetchSystemNotifications(params: Map<*, *>, result: MethodChannel.Result) {
        val messageList = NIMClient.getService(SystemMessageService::class.java)
                .querySystemMessagesBlock(0, Int.MAX_VALUE)

        val notis = mutableListOf<Map<String, Any?>>()
        messageList.forEach{ message ->
            // TODO NIMUserAddAttachment

            notis.add(mapOf(
                    "notificationId" to message.messageId,
                    "type" to message.type,
                    "timestamp" to message.time,
                    "sourceID" to message.fromAccount,
                    "targetID" to message.targetId,
                    "postscript" to null, // TODO ???
                    "read" to message.isUnread,
                    "handleStatus" to message.status,
                    "notifyExt" to null, // TODO ???
                    "attachment" to message.attach
            ))
        }
        result.success(notis)
    }

    /**
     * 删除所有通知
     */
    private fun deleteAllNotifications(params: Map<*, *>, result: MethodChannel.Result) {
        NIMClient.getService(SystemMessageService::class.java).clearSystemMessages()
    }

    /**
     * 同意入群申请
     */
    private fun passApplyToTeam(params: Map<*, *>, result: MethodChannel.Result) {
        val targetId = params["targetID"] as String
        val sourceId = params["sourceID"] as String
        NIMSDK.getTeamService().passApply(targetId, sourceId)
                .setCallback(object : RequestCallback<Void> {
                    override fun onSuccess(param: Void?) {
                        ToastUtils.showShort("同意成功")
                        result.success(1)
                    }

                    override fun onFailed(code: Int) {
                        if (code == 408) {
                            ToastUtils.showShort("网络问题，请重试")
                            result.success(0)
                        } else {
                            ToastUtils.showShort("请求已失效")
                            result.success(3)
                        }
                    }

                    override fun onException(exception: Throwable?) {
                        ToastUtils.showShort("请求已失效")
                        result.success(3)
                    }
                })
    }

    /**
     * 拒绝入群申请
     */
    private fun rejectApplyToTeam(params: Map<*, *>, result: MethodChannel.Result) {
        val targetId = params["targetID"] as String
        val sourceId = params["sourceID"] as String
        NIMSDK.getTeamService().rejectApply(targetId, sourceId, "")
                .setCallback(object : RequestCallback<Void> {
                    override fun onSuccess(param: Void?) {
                        ToastUtils.showShort("拒绝成功")
                        result.success(2)
                    }

                    override fun onFailed(code: Int) {
                        if (code == 408) {
                            ToastUtils.showShort("网络问题，请重试")
                            result.success(0)
                        } else {
                            ToastUtils.showShort("请求已失效")
                            result.success(3)
                        }
                    }

                    override fun onException(exception: Throwable?) {
                        ToastUtils.showShort("请求已失效")
                        result.success(3)
                    }
                })
    }

    /**
     * 接受入群邀请
     */
    private fun acceptInviteWithTeam(params: Map<*, *>, result: MethodChannel.Result) {
        val targetId = params["targetID"] as String
        val sourceId = params["sourceID"] as String
        NIMSDK.getTeamService().acceptInvite(targetId, sourceId)
                .setCallback(object : RequestCallback<Void> {
                    override fun onSuccess(param: Void?) {
                        ToastUtils.showShort("接受成功")
                        result.success(1)
                    }

                    override fun onFailed(code: Int) {
                        if (code == 408) {
                            ToastUtils.showShort("网络问题，请重试")
                            result.success(0)
                        } else if (code == 803) {
                            ToastUtils.showShort("群不存在")
                            result.success(3)
                        } else {
                            ToastUtils.showShort("请求已失效")
                            result.success(3)
                        }
                    }

                    override fun onException(exception: Throwable?) {
                        ToastUtils.showShort("请求已失效")
                        result.success(3)
                    }
                })
    }

    /**
     * 拒绝入群邀请
     */
    private fun rejectInviteWithTeam(params: Map<*, *>, result: MethodChannel.Result) {
        val targetId = params["targetID"] as String
        val sourceId = params["sourceID"] as String
        NIMSDK.getTeamService().declineInvite(targetId, sourceId, "")
                .setCallback(object : RequestCallback<Void> {
                    override fun onSuccess(param: Void?) {
                        ToastUtils.showShort("拒绝成功")
                        result.success(2)
                    }

                    override fun onFailed(code: Int) {
                        if (code == 408) {
                            ToastUtils.showShort("网络问题，请重试")
                            result.success(0)
                        } else if (code == 803) {
                            ToastUtils.showShort("群不存在")
                            result.success(3)
                        } else {
                            ToastUtils.showShort("请求已失效")
                            result.success(3)
                        }
                    }

                    override fun onException(exception: Throwable?) {
                        ToastUtils.showShort("请求已失效")
                        result.success(3)
                    }
                })
    }

    /**
     * 通过添加好友请求
     */
    private fun requestFriend(params: Map<*, *>, result: MethodChannel.Result) {
        val sourceId = params["sourceID"] as String
        NIMSDK.getFriendService().ackAddFriendRequest(sourceId, true)
                .setCallback(object : RequestCallback<Void> {
                    override fun onSuccess(param: Void?) {
                        val message = MessageBuilder.createTextMessage(sourceId, SessionTypeEnum.P2P, "你好，我们已加为好友!")
                        NIMSDK.getMsgService().sendMessage(message, false)
                        ToastUtils.showShort("验证成功")
                        result.success(1)
                    }

                    override fun onFailed(code: Int) {
                        ToastUtils.showShort("验证失败,请重试")
                        result.success(0)
                    }

                    override fun onException(exception: Throwable?) {
                        ToastUtils.showShort("验证失败,请重试")
                        result.success(0)
                    }
                })
    }

    /**
     * 拒绝好友添加申请
     */
    private fun rejectFriendRequest(params: Map<*, *>, result: MethodChannel.Result) {
        val sourceId = params["sourceID"] as String
        NIMSDK.getFriendService().ackAddFriendRequest(sourceId, false)
                .setCallback(object : RequestCallback<Void> {
                    override fun onSuccess(param: Void?) {
                        ToastUtils.showShort("拒绝成功")
                        result.success(2)
                    }

                    override fun onFailed(code: Int) {
                        ToastUtils.showShort("验证失败,请重试")
                        result.success(0)
                    }

                    override fun onException(exception: Throwable?) {
                        ToastUtils.showShort("验证失败,请重试")
                        result.success(0)
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

    private fun recentSessionIsMark(recent: RecentContact, type: Int): Boolean {
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