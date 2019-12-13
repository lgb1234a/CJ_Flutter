package com.youxi.chat.module.avchat

import android.content.Context
import com.netease.nim.avchatkit.AVChatKit
import com.netease.nim.avchatkit.common.log.ILogUtil
import com.netease.nim.avchatkit.config.AVChatOptions
import com.netease.nim.avchatkit.model.ITeamDataProvider
import com.netease.nim.avchatkit.model.IUserInfoProvider
import com.netease.nim.uikit.api.NimUIKit
import com.netease.nim.uikit.business.team.helper.TeamHelper
import com.netease.nim.uikit.business.uinfo.UserInfoHelper
import com.netease.nim.uikit.common.util.log.LogUtil
import com.netease.nimlib.sdk.uinfo.model.UserInfo
import com.youxi.chat.R
import com.youxi.chat.module.main.activity.MainActivity
import com.youxi.chat.module.main.activity.WelcomeActivity

object AvchatHelper {
    fun init() {
        // 初始化选项
        setOptions()
        // 初始化日志系统
        setLogUtil()
        // 初始化数据来源
        setProvider()
    }

    private fun setOptions() {
        val avChatOptions: AVChatOptions = object : AVChatOptions() {
            override fun logout(context: Context) {
                MainActivity.logout(context, true)
            }
        }
        avChatOptions.entranceActivity = WelcomeActivity::class.java
        avChatOptions.notificationIconRes = R.drawable.small_app_icon
        AVChatKit.init(avChatOptions)
    }

    private fun setLogUtil() {
        AVChatKit.setiLogUtil(object : ILogUtil {
            override fun i(tag: String?, msg: String?) {
                LogUtil.i(tag, msg)
            }

            override fun e(tag: String?, msg: String?) {
                LogUtil.e(tag, msg)
            }

            override fun d(tag: String?, msg: String?) {
                LogUtil.d(tag, msg)
            }

            override fun ui(msg: String?) {
                LogUtil.ui(msg)
            }

        })
    }

    private fun setProvider() {
        // 设置用户相关资料提供者
        AVChatKit.setUserInfoProvider(object : IUserInfoProvider() {
            override fun getUserInfo(account: String?): UserInfo? {
                return NimUIKit.getUserInfoProvider().getUserInfo(account)
            }

            override fun getUserDisplayName(account: String?): String? {
                return UserInfoHelper.getUserDisplayName(account)
            }
        })
        // 设置群组数据提供者
        AVChatKit.setTeamDataProvider(object : ITeamDataProvider() {
            override fun getDisplayNameWithoutMe(teamId: String, account: String): String {
                return TeamHelper.getDisplayNameWithoutMe(teamId, account)
            }

            override fun getTeamMemberDisplayName(teamId: String, account: String): String {
                return TeamHelper.getTeamMemberDisplayName(teamId, account)
            }
        })
    }
}