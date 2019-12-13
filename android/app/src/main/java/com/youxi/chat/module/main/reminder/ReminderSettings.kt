package com.youxi.chat.module.main.reminder

object ReminderSettings {
    /**
     * 最大显示未读数
     */
    const val MAX_UNREAD_SHOW_NUMBER = 99

    fun unreadMessageShowRule(unread: Int): Int {
        return Math.min(MAX_UNREAD_SHOW_NUMBER, unread)
    }
}