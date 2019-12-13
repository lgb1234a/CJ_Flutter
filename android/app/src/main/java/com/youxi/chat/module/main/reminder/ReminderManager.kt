package com.youxi.chat.module.main.reminder

import android.util.SparseArray
import java.util.*

/**
 * TAB红点提醒管理器
 * Created by huangjun on 2015/3/18.
 */
class ReminderManager private constructor() {
    // callback
    interface UnreadNumChangedCallback {
        fun onUnreadNumChanged(item: ReminderItem?)
    }

    // observers
    private val items: SparseArray<ReminderItem> = SparseArray<ReminderItem>()
    private val unreadNumChangedCallbacks: MutableList<UnreadNumChangedCallback> = ArrayList()
    // interface
    fun updateSessionUnreadNum(unreadNum: Int) {
        updateUnreadMessageNum(unreadNum, false, ReminderId.SESSION)
    }

    fun updateSessionDeltaUnreadNum(delta: Int) {
        updateUnreadMessageNum(delta, true, ReminderId.SESSION)
    }

    fun updateContactUnreadNum(unreadNum: Int) {
        updateUnreadMessageNum(unreadNum, false, ReminderId.CONTACT)
    }

    fun registerUnreadNumChangedCallback(cb: UnreadNumChangedCallback) {
        if (unreadNumChangedCallbacks.contains(cb)) {
            return
        }
        unreadNumChangedCallbacks.add(cb)
    }

    fun unregisterUnreadNumChangedCallback(cb: UnreadNumChangedCallback?) {
        if (!unreadNumChangedCallbacks.contains(cb)) {
            return
        }
        unreadNumChangedCallbacks.remove(cb)
    }

    // inner
    private fun populate(items: SparseArray<ReminderItem>) {
        items.put(ReminderId.SESSION, ReminderItem(ReminderId.SESSION))
        items.put(ReminderId.CONTACT, ReminderItem(ReminderId.CONTACT))
    }

    private fun updateUnreadMessageNum(unreadNum: Int, delta: Boolean, reminderId: Int) {
        val item: ReminderItem = items[reminderId] ?: return
        var num: Int = item.getUnread()
        // 增量
        if (delta) {
            num = num + unreadNum
            if (num < 0) {
                num = 0
            }
        } else {
            num = unreadNum
        }
        item.setUnread(num)
        item.setIndicator(false)
        for (cb in unreadNumChangedCallbacks) {
            cb.onUnreadNumChanged(item)
        }
    }

    companion object {
        // singleton
        @get:Synchronized
        var instance: ReminderManager? = null
            get() {
                if (field == null) {
                    field = ReminderManager()
                }
                return field
            }
            private set

    }

    init {
        populate(items)
    }
}