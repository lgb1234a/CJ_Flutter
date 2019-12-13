package com.youxi.chat.push

import android.app.Notification
import android.app.NotificationManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.util.SparseArray
import com.netease.nim.avchatkit.AVChatKit
import com.netease.nim.uikit.common.util.log.LogUtil
import com.netease.nimlib.sdk.NimIntent
import com.netease.nimlib.sdk.StatusBarNotificationConfig
import com.netease.nimlib.sdk.msg.MessageBuilder
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum
import com.netease.nimlib.sdk.msg.model.IMMessage
import com.youxi.chat.nim.NimCache
import java.util.*

/**
 * Created by hzchenkang on 2016/11/10.
 */
class MixPushMessageHandler : com.netease.nimlib.sdk.mixpush.MixPushMessageHandler {
    // 对于华为推送，这个方法并不能保证一定会回调
    override fun onNotificationClicked(context: Context, payload: Map<String, String>): Boolean {
        LogUtil.i(MixPushMessageHandler::class.java.simpleName, "rev pushMessage payload $payload")
        val sessionId = payload[PAYLOAD_SESSION_ID]
        val type = payload[PAYLOAD_SESSION_TYPE]
        //
        return if (sessionId != null && type != null) {
            val typeValue = Integer.valueOf(type)
            val imMessages = ArrayList<IMMessage>()
            val imMessage = MessageBuilder.createEmptyMessage(sessionId, SessionTypeEnum.typeOfValue(typeValue), 0)
            imMessages.add(imMessage)
            val notifyIntent = Intent()
            notifyIntent.component = initLaunchComponent(context)
            notifyIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            notifyIntent.action = Intent.ACTION_VIEW
            notifyIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) // 必须
            notifyIntent.putExtra(NimIntent.EXTRA_NOTIFY_CONTENT, imMessages)
            context.startActivity(notifyIntent)
            true
        } else {
            false
        }
    }

    private fun initLaunchComponent(context: Context): ComponentName {
        val launchComponent: ComponentName
        val config: StatusBarNotificationConfig? = NimCache.getNotificationConfig()
        val entrance = config?.notificationEntrance
        launchComponent = entrance?.let { ComponentName(context, it) }
                ?: context.packageManager.getLaunchIntentForPackage(context.packageName).component
        return launchComponent
    }

    // 将音视频通知 Notification 缓存，清除所有通知后再次弹出 Notification，避免清除之后找不到打开正在进行音视频通话界面的入口
    override fun cleanMixPushNotifications(pushType: Int): Boolean {
        val context: Context = NimCache.getContext()
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (manager != null) {
            manager.cancelAll()
            val nos: SparseArray<Notification> = AVChatKit.getNotifications()
            if (nos != null) {
                var key = 0
                for (i in 0 until nos.size()) {
                    key = nos.keyAt(i)
                    manager.notify(key, nos[key])
                }
            }
        }
        return true
    }

    companion object {
        const val PAYLOAD_SESSION_ID = "sessionID"
        const val PAYLOAD_SESSION_TYPE = "sessionType"
    }
}