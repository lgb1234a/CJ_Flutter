package com.youxi.chat.module.session.viewholder

import android.app.Activity
import android.widget.TextView
import com.netease.nim.uikit.business.team.activity.AdvancedTeamMemberInfoActivity
import com.netease.nim.uikit.business.team.helper.TeamHelper
import com.netease.nim.uikit.common.adapter.TViewHolder
import com.netease.nim.uikit.common.ui.imageview.HeadImageView
import com.youxi.chat.R
import com.youxi.chat.module.session.adapter.AckMsgDetailAdapter

class AckMsgDetailHolder : TViewHolder() {
    private var headImageView: HeadImageView? = null
    private var nameTextView: TextView? = null
    private var memberItem: AckMsgDetailAdapter.AckMsgDetailItem? = null
    override fun getAdapter(): AckMsgDetailAdapter {
        return super.getAdapter() as AckMsgDetailAdapter
    }

    override fun getResId(): Int {
        return R.layout.ack_msg_detail_item
    }

    override fun inflate() {
        headImageView = view.findViewById(R.id.imageViewHeader)
        nameTextView = view.findViewById(R.id.textViewName)
    }

    override fun refresh(item: Any) {
        memberItem = item as AckMsgDetailAdapter.AckMsgDetailItem
        headImageView!!.resetImageView()
        refreshTeamMember(memberItem)
    }

    private fun refreshTeamMember(item: AckMsgDetailAdapter.AckMsgDetailItem?) {
        nameTextView!!.text = TeamHelper.getTeamMemberDisplayName(item?.tid, item?.account)
        headImageView?.loadBuddyAvatar(item?.account)
        headImageView!!.setOnClickListener { AdvancedTeamMemberInfoActivity
                .startActivityForResult(context as Activity, item?.account, item?.tid) }
    }
}