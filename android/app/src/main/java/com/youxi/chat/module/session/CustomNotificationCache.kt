package com.youxi.chat.module.session

import com.netease.nimlib.sdk.msg.model.CustomNotification
import java.util.*

/**
 * 自定义通知缓存
 *
 *
 * Created by huangjun on 2015/5/29.
 */
class CustomNotificationCache {
    val customNotification: MutableList<CustomNotification> = LinkedList()
    fun addCustomNotification(notification: CustomNotification?) {
        if (notification == null) {
            return
        }
        if (!customNotification.contains(notification)) {
            customNotification.add(0, notification)
        }
    }

    object InstanceHolder {
        val instance = CustomNotificationCache()
    }

    companion object {
        val instance: CustomNotificationCache
            get() = InstanceHolder.instance
    }
}