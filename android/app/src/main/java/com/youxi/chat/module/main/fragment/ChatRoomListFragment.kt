package com.youxi.chat.module.main.fragment

import com.youxi.chat.R

/**
 * 聊天室主TAB页
 * Created by huangjun on 2015/12/11.
 */
class ChatRoomListFragment : MainTabFragment() {
    private var fragment: ChatRoomListFragment? = null
    protected override fun onInit() { // 采用静态集成，这里不需要做什么了
        fragment = getActivity()!!.getSupportFragmentManager().findFragmentById(R.id.chat_rooms_fragment) as ChatRoomListFragment
    }

    override fun onCurrent() {
        super.onCurrent()
        if (fragment != null) {
            fragment!!.onCurrent()
        }
    }

    init {
//        setContainerId(MainTab.CHAT_ROOM.fragmentId)
    }
}