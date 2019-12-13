package com.youxi.chat.nim

import android.content.Context
import com.netease.nim.avchatkit.AVChatKit
import com.netease.nim.rtskit.RTSKit
import com.netease.nim.uikit.api.NimUIKit
import com.netease.nimlib.sdk.StatusBarNotificationConfig


/**
 * Created by jezhee on 2/20/15.
 */
object NimCache {
    private lateinit var context: Context
    private var account: String? = null
    private var notificationConfig: StatusBarNotificationConfig? = null

    fun clear() {
        account = null
    }

    fun getAccount(): String? {
        return account
    }

    var mainTaskLaunching = false
        set(mainTaskLaunching) {
            field = mainTaskLaunching
            AVChatKit.setMainTaskLaunching(mainTaskLaunching)
        }

    fun setAccount(account: String?) {
        NimCache.account = account
        NimUIKit.setAccount(account)
        AVChatKit.setAccount(account)
        RTSKit.setAccount(account)
    }

    fun setContext(context: Context) {
        NimCache.context = context.applicationContext
        AVChatKit.setContext(context)
        RTSKit.setContext(context)
    }

    fun getContext(): Context {
        return NimCache.context
    }

    fun setNotificationConfig(notificationConfig: StatusBarNotificationConfig?) {
        NimCache.notificationConfig = notificationConfig
    }

    fun getNotificationConfig(): StatusBarNotificationConfig? {
        return notificationConfig
    }
}
