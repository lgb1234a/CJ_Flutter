package com.youxi.chat.module.main.model

import com.youxi.chat.R
import com.youxi.chat.module.main.fragment.*
import com.youxi.chat.module.main.reminder.ReminderId

enum class MainTab(val tabIndex: Int, val reminderId: Int, clazz: Class<out MainTabFragment?>,
                   resId: Int, iconId: Int, layoutId: Int) {
    RECENT_CONTACTS(0, ReminderId.SESSION, SessionListFragment::class.java, R.string.main_tab_session,
            R.drawable.tab_chat_selector, R.layout.session_list),
    CONTACT(1, ReminderId.CONTACT, ContactListFragment::class.java, R.string.main_tab_contact,
            R.drawable.tab_contact_selector, R.layout.contacts_list),
    DISCOVER(2, ReminderId.INVALID, DiscoverListFragment::class.java, R.string.main_tab_discover,
            R.drawable.tab_discover_selector, R.layout.discover_list),
    MINE(3, ReminderId.INVALID, MineListFragment::class.java, R.string.main_tab_mine,
            R.drawable.tab_me_selector, R.layout.mine_list);

//    RECENT_CONTACTS(0, ReminderId.SESSION, SessionListFragment::class.java, R.string.main_tab_session, R.layout.session_list),
//    CONTACT(1, ReminderId.CONTACT, ContactListFragment::class.java, R.string.main_tab_contact, R.layout.contacts_list),
//    DISCOVER(2, ReminderId.INVALID, ChatRoomListFragment::class.java, R.string.main_tab_discover, R.layout.discover_list),
//    MINE(3, ReminderId.INVALID, MineListFragment::class.java, R.string.main_tab_mine, R.layout.mine_list),
//    CHAT_ROOM(4, ReminderId.INVALID, ChatRoomListFragment::class.java, R.string.chat_room, R.layout.chat_room_tab);

    val clazz: Class<out MainTabFragment?>
    val resId: Int
    val iconId: Int
    val fragmentId: Int
    val layoutId: Int

    companion object {
        fun fromReminderId(reminderId: Int): MainTab? {
            for (value in values()) {
                if (value.reminderId == reminderId) {
                    return value
                }
            }
            return null
        }

        fun fromTabIndex(tabIndex: Int): MainTab? {
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
        this.iconId = iconId
        fragmentId = tabIndex
        this.layoutId = layoutId
    }
}