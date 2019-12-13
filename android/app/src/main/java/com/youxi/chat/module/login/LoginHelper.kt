package com.youxi.chat.module.login

import android.content.Context
import com.blankj.utilcode.util.ActivityUtils
import com.blankj.utilcode.util.BusUtils
import com.blankj.utilcode.util.LogUtils
import com.netease.nim.uikit.api.NimUIKit
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.StatusBarNotificationConfig
import com.youxi.chat.Router
import com.youxi.chat.config.preference.Preferences
import com.youxi.chat.config.preference.UserPreferences
import com.youxi.chat.module.main.activity.MainActivity
import com.youxi.chat.module.wallet.NimWalletClient
import com.youxi.chat.nim.NimCache


object LoginHelper {

    const val TAG_didLogin = "didLogin"
    const val TAG_didLogout = "didLogout"

    fun init() {
        registerBus()
    }

    private fun registerBus() {
        BusUtils.register(this)
    }

    private fun unregisterBus() {
        BusUtils.unregister(this)
    }

    @BusUtils.Bus(tag = TAG_didLogin)
    fun didLogin(params: Map<String, Any>) {
        LogUtils.d(TAG_didLogin)

        val account = params.get("accid") as String
        val token = params.get("token") as String

        NimCache.setAccount(account);
        saveLoginInfo(account, token);
        // 初始化消息提醒配置
        initNotificationConfig();
        Router.open(ActivityUtils.getTopActivity()!!, MainActivity::class.java)

    }

    @BusUtils.Bus(tag = TAG_didLogout)
    fun didLogout() {
        LogUtils.d(TAG_didLogout)

    }

    /**
     * 跳转登录页
     */
    fun gotoLogin(context: Context, kickOut: Boolean = false) {
        Router.open(context, "login")
    }

    /**
     * 登入操作
     */
    fun login() {

    }

    /**
     * 登出操作
     */
    fun logout() {
        // 清理缓存&注销监听&清除状态
        NimUIKit.logout();
        NimCache.clear();
        NimWalletClient.clear();
    }

    private fun initNotificationConfig() {
        // 初始化消息提醒
        NIMClient.toggleNotification(UserPreferences.noticeContentToggle)
        // 加载状态栏配置
        var statusBarNotificationConfig: StatusBarNotificationConfig? = UserPreferences.statusConfig
        if (statusBarNotificationConfig == null) {
            statusBarNotificationConfig = NimCache.getNotificationConfig()
            UserPreferences.setStatusConfig(statusBarNotificationConfig!!)
        }
        // 更新配置
        NIMClient.updateStatusBarNotificationConfig(statusBarNotificationConfig)
    }

    private fun saveLoginInfo(account: String, token: String) {
        Preferences.saveUserAccount(account)
        Preferences.saveUserToken(token)
    }
}