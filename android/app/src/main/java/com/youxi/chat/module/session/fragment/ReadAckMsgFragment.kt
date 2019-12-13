package com.youxi.chat.module.session.fragment

import android.os.Bundle
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.AbsListView
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProviders
import com.netease.nim.uikit.business.team.ui.TeamInfoGridView
import com.netease.nim.uikit.common.adapter.TAdapterDelegate
import com.netease.nim.uikit.common.adapter.TViewHolder
import com.netease.nimlib.sdk.msg.model.IMMessage
import com.netease.nimlib.sdk.msg.model.TeamMsgAckInfo
import com.youxi.chat.R
import com.youxi.chat.module.session.activity.AckMsgInfoActivity
import com.youxi.chat.module.session.adapter.AckMsgDetailAdapter
import com.youxi.chat.module.session.fragment.tab.AckMsgTabFragment
import com.youxi.chat.module.session.model.AckMsgViewModel
import com.youxi.chat.module.session.viewholder.AckMsgDetailHolder
import java.util.*

/**
 * 群已读人员界面
 * Created by winnie on 2018/3/15.
 */
class ReadAckMsgFragment : AckMsgTabFragment(), TAdapterDelegate {
    private var viewModel: AckMsgViewModel? = null
    private var adapter: AckMsgDetailAdapter? = null
    private var dataSource: MutableList<AckMsgDetailAdapter.AckMsgDetailItem>? = null
    private var rootView: View? = null
    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initAdapter()
        findViews()
        val message = getActivity()!!.getIntent().getSerializableExtra(AckMsgInfoActivity.EXTRA_MESSAGE) as IMMessage
        viewModel = ViewModelProviders.of(this).get(AckMsgViewModel::class.java)
        viewModel?.init(message)
        viewModel?.teamMsgAckInfo?.observe(this, Observer<TeamMsgAckInfo?> {
            teamMsgAckInfo ->
            for (account in teamMsgAckInfo!!.ackAccountList) {
                dataSource!!.add(AckMsgDetailAdapter.AckMsgDetailItem(teamMsgAckInfo.teamId, account))
            }
            adapter?.notifyDataSetChanged()
        })
    }

    protected override fun onInit() {}
    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        rootView = inflater.inflate(R.layout.unread_ack_msg_fragment, container, false)
        return rootView
    }

    private fun initAdapter() {
        dataSource = ArrayList<AckMsgDetailAdapter.AckMsgDetailItem>()
        adapter = AckMsgDetailAdapter(getActivity(), dataSource, this)
    }

    private fun findViews() {
        val teamInfoGridView: TeamInfoGridView = rootView!!.findViewById(R.id.team_member_grid)
        teamInfoGridView.setSelector(R.color.transparent)
        teamInfoGridView.setOnScrollListener(object : AbsListView.OnScrollListener {
            override fun onScrollStateChanged(view: AbsListView, scrollState: Int) {
                if (scrollState == 0) {
                    adapter?.notifyDataSetChanged()
                }
            }

            override fun onScroll(view: AbsListView, firstVisibleItem: Int, visibleItemCount: Int, totalItemCount: Int) {}
        })
        teamInfoGridView.setOnTouchListener(View.OnTouchListener { v, event ->
            if (event.action == MotionEvent.ACTION_UP) {
                adapter?.notifyDataSetChanged()
                return@OnTouchListener true
            }
            false
        })
        teamInfoGridView.adapter = adapter
    }

    override fun getViewTypeCount(): Int {
        return 1
    }

    override fun viewHolderAtPosition(position: Int): Class<out TViewHolder?> {
        return AckMsgDetailHolder::class.java
    }

    override fun enabled(position: Int): Boolean {
        return false
    }
}