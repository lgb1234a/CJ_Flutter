package com.youxi.chat.config.preference

import android.app.Activity
import android.content.Context
import android.content.SharedPreferences
import com.netease.nimlib.sdk.StatusBarNotificationConfig
import com.youxi.chat.nim.NimCache


/**
 * Created by hzxuwen on 2015/4/13.
 */
object UserPreferences {
    private const val KEY_DOWNTIME_TOGGLE = "down_time_toggle"
    private const val KEY_SB_NOTIFY_TOGGLE = "sb_notify_toggle"
    private const val KEY_TEAM_ANNOUNCE_CLOSED = "team_announce_closed"
    private const val KEY_STATUS_BAR_NOTIFICATION_CONFIG = "KEY_STATUS_BAR_NOTIFICATION_CONFIG"
    // 测试过滤通知
    private const val KEY_MSG_IGNORE = "KEY_MSG_IGNORE"
    // 响铃配置
    private const val KEY_RING_TOGGLE = "KEY_RING_TOGGLE"
    // 震动配置
    private const val KEY_VIBRATE_TOGGLE = "KEY_VIBRATE_TOGGLE"
    // 呼吸灯配置
    private const val KEY_LED_TOGGLE = "KEY_LED_TOGGLE"
    // 通知栏标题配置
    private const val KEY_NOTICE_CONTENT_TOGGLE = "KEY_NOTICE_CONTENT_TOGGLE"
    // 删除好友同时删除备注
    private const val KEY_DELETE_FRIEND_AND_DELETE_ALIAS = "KEY_DELETE_FRIEND_AND_DELETE_ALIAS"
    // 通知栏样式（展开、折叠）配置
    private const val KEY_NOTIFICATION_FOLDED_TOGGLE = "KEY_NOTIFICATION_FOLDED"
    // 保存在线状态订阅时间
    private const val KEY_SUBSCRIBE_TIME = "KEY_SUBSCRIBE_TIME"
    /*************************no disturb begin */
    const val DOWN_TIME_BEGIN = "downTimeBegin"
    const val DOWN_TIME_END = "downTimeEnd"
    const val DOWN_TIME_TOGGLE = "downTimeToggle"
    const val DOWN_TIME_ENABLE_NOTIFICATION = "downTimeEnableNotification"
    const val RING = "ring"
    const val VIBRATE = "vibrate"
    const val NOTIFICATION_SMALL_ICON_ID = "notificationSmallIconId"
    const val NOTIFICATION_SOUND = "notificationSound"
    const val HIDE_CONTENT = "hideContent"
    const val LEDARGB = "ledargb"
    const val LEDONMS = "ledonms"
    const val LEDOFFMS = "ledoffms"
    const val TITLE_ONLY_SHOW_APP_NAME = "titleOnlyShowAppName"
    const val NOTIFICATION_FOLDED = "notificationFolded"
    const val NOTIFICATION_ENTRANCE = "notificationEntrance"
    const val NOTIFICATION_COLOR = "notificationColor"

    /**************************no disturb end */
    var msgIgnore: Boolean
        get() = getBoolean(KEY_MSG_IGNORE, false)
        set(enable) {
            saveBoolean(KEY_MSG_IGNORE, enable)
        }

    var notificationToggle: Boolean
        get() = getBoolean(KEY_SB_NOTIFY_TOGGLE, true)
        set(on) {
            saveBoolean(KEY_SB_NOTIFY_TOGGLE, on)
        }

    var ringToggle: Boolean
        get() = getBoolean(KEY_RING_TOGGLE, true)
        set(on) {
            saveBoolean(KEY_RING_TOGGLE, on)
        }

    var vibrateToggle: Boolean
        get() = getBoolean(KEY_VIBRATE_TOGGLE, true)
        set(on) {
            saveBoolean(KEY_VIBRATE_TOGGLE, on)
        }

    var ledToggle: Boolean
        get() = getBoolean(KEY_LED_TOGGLE, true)
        set(on) {
            saveBoolean(KEY_LED_TOGGLE, on)
        }

    var noticeContentToggle: Boolean
        get() = getBoolean(KEY_NOTICE_CONTENT_TOGGLE, false)
        set(on) {
            saveBoolean(KEY_NOTICE_CONTENT_TOGGLE, on)
        }

    var isDeleteFriendAndDeleteAlias: Boolean
        get() = getBoolean(KEY_DELETE_FRIEND_AND_DELETE_ALIAS, false)
        set(on) {
            saveBoolean(KEY_DELETE_FRIEND_AND_DELETE_ALIAS, on)
        }

    var downTimeToggle: Boolean
        get() = getBoolean(KEY_DOWNTIME_TOGGLE, false)
        set(on) {
            saveBoolean(KEY_DOWNTIME_TOGGLE, on)
        }

    var notificationFoldedToggle: Boolean
        get() = getBoolean(KEY_NOTIFICATION_FOLDED_TOGGLE, true)
        set(folded) {
            saveBoolean(KEY_NOTIFICATION_FOLDED_TOGGLE, folded)
        }

    fun setStatusConfig(config: StatusBarNotificationConfig) {
        saveStatusBarNotificationConfig(KEY_STATUS_BAR_NOTIFICATION_CONFIG, config)
    }

    val statusConfig: StatusBarNotificationConfig?
        get() = getConfig(KEY_STATUS_BAR_NOTIFICATION_CONFIG)

    fun setTeamAnnounceClosed(teamId: String, closed: Boolean) {
        saveBoolean(KEY_TEAM_ANNOUNCE_CLOSED + teamId, closed)
    }

    fun getTeamAnnounceClosed(teamId: String): Boolean {
        return getBoolean(KEY_TEAM_ANNOUNCE_CLOSED + teamId, false)
    }

    var onlineStateSubsTime: Long
        get() = getLong(KEY_SUBSCRIBE_TIME, 0)
        set(time) {
            saveLong(KEY_SUBSCRIBE_TIME, time)
        }

    private fun getConfig(key: String): StatusBarNotificationConfig? {
        val config = StatusBarNotificationConfig()
        val jsonString = sharedPreferences.getString(key, "")
        try {
            val jsonObject: com.alibaba.fastjson.JSONObject = com.alibaba.fastjson.JSONObject.parseObject(jsonString)
                    ?: return null
            config.downTimeBegin = jsonObject.getString(DOWN_TIME_BEGIN)
            config.downTimeEnd = jsonObject.getString(DOWN_TIME_END)
            config.downTimeToggle = jsonObject.getBoolean(DOWN_TIME_TOGGLE)
            val downTimeEnableNotification: Boolean = jsonObject.getBoolean(DOWN_TIME_ENABLE_NOTIFICATION)
            config.downTimeEnableNotification = downTimeEnableNotification ?: true
            val ring: Boolean = jsonObject.getBoolean(RING)
            config.ring = ring ?: true
            val vibrate: Boolean = jsonObject.getBoolean(VIBRATE)
            config.vibrate = vibrate ?: true
            config.notificationSmallIconId = jsonObject.getIntValue(NOTIFICATION_SMALL_ICON_ID)
            config.notificationSound = jsonObject.getString(NOTIFICATION_SOUND)
            config.hideContent = jsonObject.getBooleanValue(HIDE_CONTENT)
            config.ledARGB = jsonObject.getIntValue(LEDARGB)
            config.ledOnMs = jsonObject.getIntValue(LEDONMS)
            config.ledOffMs = jsonObject.getIntValue(LEDOFFMS)
            config.titleOnlyShowAppName = jsonObject.getBooleanValue(TITLE_ONLY_SHOW_APP_NAME)
            val notificationFolded: Boolean = jsonObject.getBoolean(NOTIFICATION_FOLDED)
            config.notificationFolded = notificationFolded ?: true
            config.notificationEntrance = Class.forName(
                    jsonObject.getString(NOTIFICATION_ENTRANCE)) as Class<out Activity?>
            config.notificationColor = jsonObject.getInteger(NOTIFICATION_COLOR)
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return config
    }

    private fun saveStatusBarNotificationConfig(key: String, config: StatusBarNotificationConfig) {
        val editor = sharedPreferences.edit()
        val jsonObject: com.alibaba.fastjson.JSONObject = com.alibaba.fastjson.JSONObject()
        try {
            jsonObject.put(DOWN_TIME_BEGIN, config.downTimeBegin)
            jsonObject.put(DOWN_TIME_END, config.downTimeEnd)
            jsonObject.put(DOWN_TIME_TOGGLE, config.downTimeToggle)
            jsonObject.put(DOWN_TIME_ENABLE_NOTIFICATION, config.downTimeEnableNotification)
            jsonObject.put(RING, config.ring)
            jsonObject.put(VIBRATE, config.vibrate)
            jsonObject.put(NOTIFICATION_SMALL_ICON_ID, config.notificationSmallIconId)
            jsonObject.put(NOTIFICATION_SOUND, config.notificationSound)
            jsonObject.put(HIDE_CONTENT, config.hideContent)
            jsonObject.put(LEDARGB, config.ledARGB)
            jsonObject.put(LEDONMS, config.ledOnMs)
            jsonObject.put(LEDOFFMS, config.ledOffMs)
            jsonObject.put(TITLE_ONLY_SHOW_APP_NAME, config.titleOnlyShowAppName)
            jsonObject.put(NOTIFICATION_FOLDED, config.notificationFolded)
            jsonObject.put(NOTIFICATION_ENTRANCE, config.notificationEntrance.name)
            jsonObject.put(NOTIFICATION_COLOR, config.notificationColor)
        } catch (e: Exception) {
            e.printStackTrace()
        }
        editor.putString(key, jsonObject.toString())
        editor.commit()
    }

    private fun getBoolean(key: String, value: Boolean): Boolean {
        return sharedPreferences.getBoolean(key, value)
    }

    private fun saveBoolean(key: String, value: Boolean) {
        val editor = sharedPreferences.edit()
        editor.putBoolean(key, value)
        editor.commit()
    }

    private fun saveLong(key: String, value: Long) {
        val editor = sharedPreferences.edit()
        editor.putLong(key, value)
        editor.commit()
    }

    private fun getLong(key: String, value: Long): Long {
        return sharedPreferences.getLong(key, value)
    }

    val sharedPreferences: SharedPreferences
        get() = NimCache.getContext().getSharedPreferences("Demo." + NimCache.getAccount(), Context
                .MODE_PRIVATE)
}
