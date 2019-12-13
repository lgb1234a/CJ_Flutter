package com.youxi.chat.module.session.fragment.tab

import android.os.Bundle
import com.youxi.chat.R
import com.youxi.chat.module.session.fragment.ReadAckMsgFragment
import com.youxi.chat.module.session.model.AckMsgTab

/**
 * Created by winnie on 2018/3/15.
 */
class ReadAckMsgTabFragment : AckMsgTabFragment() {
    var fragment: ReadAckMsgFragment? = null
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
        fragment = getActivity()!!.getSupportFragmentManager().findFragmentById(R.id.read_ack_msg_fragment) as ReadAckMsgFragment
    }

    init {
        this.setContainerId(AckMsgTab.READ.fragmentId)
    }
}