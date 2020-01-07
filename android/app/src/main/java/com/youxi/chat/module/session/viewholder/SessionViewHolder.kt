package com.youxi.chat.module.session.viewholder

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import android.widget.TextView
import com.netease.nim.uikit.api.NimUIKit
import com.netease.nim.uikit.business.recent.RecentContactsCallback
import com.netease.nim.uikit.business.recent.RecentContactsFragment
import com.netease.nim.uikit.business.uinfo.UserInfoHelper
import com.netease.nim.uikit.common.ui.imageview.HeadImageView
import com.netease.nim.uikit.common.ui.recyclerview.adapter.BaseQuickAdapter
import com.netease.nim.uikit.common.ui.recyclerview.holder.BaseViewHolder
import com.netease.nim.uikit.common.ui.recyclerview.holder.RecyclerViewHolder
import com.netease.nim.uikit.common.util.sys.ScreenUtil
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum
import com.netease.nimlib.sdk.msg.model.RecentContact
import com.youxi.chat.R
import com.youxi.chat.module.session.adapter.RecentSessionAdapter

abstract class SessionViewHolder(adapter: BaseQuickAdapter<*, *>?) : RecyclerViewHolder<BaseQuickAdapter<*, *>, BaseViewHolder, RecentContact>(adapter) {
    //    private int lastUnreadCount = 0;
    protected var portraitPanel: FrameLayout? = null
    protected var imgHead: HeadImageView? = null
    protected var tvNickname: TextView? = null
    protected var bottomLine: View? = null
    protected var topLine: View? = null
    // 子类覆写
    protected abstract fun getContent(recent: RecentContact): String?

    override fun convert(holder: BaseViewHolder, data: RecentContact, position: Int, isScrolling: Boolean) {
        inflate(holder, data)
        refresh(holder, data, position)
    }

    fun inflate(holder: BaseViewHolder, recent: RecentContact?) {
        portraitPanel = holder.getView(R.id.portrait_panel)
        imgHead = holder.getView(R.id.img_head)
        tvNickname = holder.getView(R.id.tv_nickname)
    }

    fun refresh(holder: BaseViewHolder, recent: RecentContact, position: Int) { // unread count animation
//        boolean shouldBoom = lastUnreadCount > 0 && recent.getUnreadCount() == 0; // 未读数从N->0执行爆裂动画;
//        lastUnreadCount = recent.getUnreadCount();
        updateBackground(holder, recent, position)
        //        Context context=holder.getContext();
        loadPortrait(recent, holder.context)
        updateNickLabel(UserInfoHelper.getUserTitleName(recent.contactId, recent.sessionType))
    }

    private fun updateBackground(holder: BaseViewHolder, recent: RecentContact, position: Int) { //topLine.setVisibility(getAdapter().isFirstDataItem(position) ? View.GONE : View.VISIBLE);
//bottomLine.setVisibility(getAdapter().isLastDataItem(position) ? View.VISIBLE : View.GONE);
        if (recent.tag and RecentContactsFragment.RECENT_TAG_STICKY == 0L) {
            holder.getConvertView().setBackgroundResource(R.drawable.nim_touch_bg)
        } else {
            holder.getConvertView().setBackgroundResource(R.drawable.nim_recent_contact_sticky_selecter)
        }
    }

    protected fun loadPortrait(recent: RecentContact, context: Context?) { // 设置头像
        if (recent.sessionType == SessionTypeEnum.P2P) {
            imgHead!!.loadBuddyAvatar(recent.contactId)
        } else if (recent.sessionType == SessionTypeEnum.Team) {
            val team = NimUIKit.getTeamProvider().getTeamById(recent.contactId)
            //imgHead.loadTeamIconByTeam2(context,imgHead,team);
            if (team != null && team.icon != null) {
                if (team.icon == "") {
                    // TODO 头像
//                    imgHead.loadTeamIconByTeam2(context, imgHead, team)
                } else {
                    imgHead!!.loadTeamIconByTeam(team)
                }
            }
        }
    }

    protected open fun getOnlineStateContent(recent: RecentContact): String? {
        return ""
    }

    protected fun updateNickLabel(nick: String?) {
        var labelWidth = ScreenUtil.screenWidth
        labelWidth -= ScreenUtil.dip2px(50 + 70.toFloat()) // 减去固定的头像和时间宽度
        if (labelWidth > 0) {
            tvNickname!!.maxWidth = labelWidth
        }
        tvNickname!!.text = nick
    }

    protected fun unreadCountShowRule(unread: Int): String {
        var unread = unread
        unread = Math.min(unread, 99)
        return unread.toString()
    }

    // TODO 最近联系人
    protected val callback: RecentContactsCallback
        protected get() = (adapter as RecentSessionAdapter?)!!.getCallback()
}