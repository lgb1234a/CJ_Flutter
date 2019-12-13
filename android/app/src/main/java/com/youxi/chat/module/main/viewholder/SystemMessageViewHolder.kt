package com.youxi.chat.module.main.viewholder

import android.view.View
import android.widget.Button
import android.widget.TextView
import com.netease.nim.uikit.business.uinfo.UserInfoHelper
import com.netease.nim.uikit.common.adapter.TViewHolder
import com.netease.nim.uikit.common.ui.imageview.HeadImageView
import com.netease.nim.uikit.common.util.sys.TimeUtil
import com.netease.nimlib.sdk.msg.constant.SystemMessageStatus
import com.netease.nimlib.sdk.msg.model.SystemMessage
import com.youxi.chat.R
import com.youxi.chat.module.session.MessageHelper

/**
 * Created by huangjun on 2015/3/18.
 */
class SystemMessageViewHolder : TViewHolder() {
    private var message: SystemMessage? = null
    private var headImageView: HeadImageView? = null
    private var fromAccountText: TextView? = null
    private var timeText: TextView? = null
    private var contentText: TextView? = null
    private var operatorLayout: View? = null
    private var agreeButton: Button? = null
    private var rejectButton: Button? = null
    private var operatorResultText: TextView? = null
    private var listener: SystemMessageListener? = null

    interface SystemMessageListener {
        fun onAgree(message: SystemMessage?)
        fun onReject(message: SystemMessage?)
        fun onLongPressed(message: SystemMessage?)
    }

    override fun getResId(): Int {
        return R.layout.message_system_notification_view_item
    }

    override fun inflate() {
        headImageView = view.findViewById<View>(R.id.from_account_head_image) as HeadImageView
        fromAccountText = view.findViewById<View>(R.id.from_account_text) as TextView
        contentText = view.findViewById<View>(R.id.content_text) as TextView
        timeText = view.findViewById<View>(R.id.notification_time) as TextView
        operatorLayout = view.findViewById(R.id.operator_layout)
        agreeButton = view.findViewById<View>(R.id.agree) as Button
        rejectButton = view.findViewById<View>(R.id.reject) as Button
        operatorResultText = view.findViewById<View>(R.id.operator_result) as TextView
        view.setBackgroundResource(R.drawable.nim_list_item_bg_selecter)
    }

    override fun refresh(item: Any) {
        message = item as SystemMessage
        view.setOnLongClickListener {
            if (listener != null) {
                listener!!.onLongPressed(message)
            }
            true
        }
        headImageView!!.loadBuddyAvatar(message!!.fromAccount)
        fromAccountText!!.text = UserInfoHelper.getUserDisplayNameEx(message!!.fromAccount, "我")
        contentText?.setText(MessageHelper.getVerifyNotificationText(message!!))
        timeText!!.text = TimeUtil.getTimeShowString(message!!.time, false)
        if (!MessageHelper.isVerifyMessageNeedDeal(message!!)) {
            operatorLayout!!.visibility = View.GONE
        } else {
            if (message!!.status == SystemMessageStatus.init) { // 未处理
                operatorResultText!!.visibility = View.GONE
                operatorLayout!!.visibility = View.VISIBLE
                agreeButton!!.visibility = View.VISIBLE
                rejectButton!!.visibility = View.VISIBLE
            } else { // 处理结果
                agreeButton!!.visibility = View.GONE
                rejectButton!!.visibility = View.GONE
                operatorResultText!!.visibility = View.VISIBLE
                operatorResultText?.setText(MessageHelper.getVerifyNotificationDealResult
                (message!!))
            }
        }
    }

    fun refreshDirectly(message: SystemMessage?) {
        message?.let { refresh(it) }
    }

    fun setListener(l: SystemMessageListener?) {
        if (l == null) {
            return
        }
        listener = l
        agreeButton!!.setOnClickListener {
            setReplySending()
            listener!!.onAgree(message)
        }
        rejectButton!!.setOnClickListener {
            setReplySending()
            listener!!.onReject(message)
        }
    }

    /**
     * 等待服务器返回状态设置
     */
    private fun setReplySending() {
        agreeButton!!.visibility = View.GONE
        rejectButton!!.visibility = View.GONE
        operatorResultText!!.visibility = View.VISIBLE
        operatorResultText?.setText(R.string.team_apply_sending)
    }
}