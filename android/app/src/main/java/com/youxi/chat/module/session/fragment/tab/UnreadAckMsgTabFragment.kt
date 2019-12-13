package com.youxi.chat.module.session.fragment.tab

import android.os.Bundle
import com.youxi.chat.R
import com.youxi.chat.module.session.fragment.UnreadAckMsgFragment
import com.youxi.chat.module.session.model.AckMsgTab

/**
 * Created by winnie on 2018/3/15.
 */
class UnreadAckMsgTabFragment : AckMsgTabFragment() {
    var fragment: UnreadAckMsgFragment? = null
    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        onCurrent()
    }

    protected override fun onInit() {
        findViews()
    }

    override fun onCurrent() {
        super.onCurrent()
    }

    private fun findViews() {
        fragment = getActivity()!!.getSupportFragmentManager().findFragmentById(R.id.unread_ack_msg_fragment) as UnreadAckMsgFragment
    }

    init {
        this.setContainerId(AckMsgTab.UNREAD.fragmentId)
    }
}