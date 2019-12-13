package com.youxi.chat.module.main.reminder

import java.io.Serializable

class ReminderItem(val id: Int) : Serializable {
    private var unread = 0
    private var indicator = false

    fun unread(): Int {
        return unread
    }

    fun indicator(): Boolean {
        return unread <= 0 && indicator
    }

    fun getUnread(): Int {
        return unread
    }

    fun setUnread(unread: Int) {
        this.unread = unread
    }

    fun setIndicator(indicator: Boolean) {
        this.indicator = indicator
    }

    /*package*/
    fun copy(): ReminderItem {
        val item = ReminderItem(id)
        copyData(item)
        return item
    }

    protected fun copyData(item: ReminderItem) {
        item.unread = unread
        item.indicator = indicator
    }

    companion object {
        private const val serialVersionUID = -2101649256143239157L
    }

}