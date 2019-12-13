package com.youxi.chat.module.session.model

import com.youxi.chat.R
import com.youxi.chat.module.session.fragment.tab.AckMsgTabFragment
import com.youxi.chat.module.session.fragment.tab.ReadAckMsgTabFragment
import com.youxi.chat.module.session.fragment.tab.UnreadAckMsgTabFragment

/**
 * Created by winnie on 2018/3/14.
 */
enum class AckMsgTab(val tabIndex: Int, val reminderId: Int, clazz: Class<out AckMsgTabFragment?>, resId: Int, layoutId: Int) {
    UNREAD(0, AckMsgReminderId.UNREAD, UnreadAckMsgTabFragment::class.java, R.string.unread, R.layout.ack_msg_unread_layout), READ(1, AckMsgReminderId.READ, ReadAckMsgTabFragment::class.java, R.string.readed, R.layout.ack_msg_readed_layout);

    val clazz: Class<out AckMsgTabFragment?>
    val resId: Int
    val fragmentId: Int
    val layoutId: Int

    companion object {
        fun fromReminderId(reminderId: Int): AckMsgTab? {
            for (value in values()) {
                if (value.reminderId == reminderId) {
                    return value
                }
            }
            return null
        }

        fun fromTabIndex(tabIndex: Int): AckMsgTab? {
            for (value in values()) {
                if (value.tabIndex == tabIndex) {
                    return value
                }
            }
            return null
        }
    }

    init {
        this.clazz = clazz
        this.resId = resId
        fragmentId = tabIndex
        this.layoutId = layoutId
    }
}