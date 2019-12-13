package com.youxi.chat.module.session.viewholder

import android.text.TextUtils
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import com.netease.nim.uikit.business.session.viewholder.MsgViewHolderBase
import com.netease.nim.uikit.common.ui.recyclerview.adapter.BaseMultiItemFetchLoadAdapter
import com.netease.nim.uikit.common.util.file.AttachmentStore
import com.netease.nim.uikit.common.util.string.StringUtil
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.msg.MsgService
import com.netease.nimlib.sdk.msg.constant.AttachStatusEnum
import com.netease.nimlib.sdk.msg.constant.MsgStatusEnum
import com.youxi.chat.R
import com.youxi.chat.module.session.activity.WatchSnapChatPictureActivity
import com.youxi.chat.module.session.extension.SnapChatAttachment

/**
 * Created by zhoujianghua on 2015/8/7.
 */
class MsgViewHolderSnapChat(adapter: BaseMultiItemFetchLoadAdapter<*, *>?) : MsgViewHolderBase(adapter) {
    private var thumbnailImageView: ImageView? = null
    protected var progressCover: View? = null
    private var progressLabel: TextView? = null
    private var isLongClick = false
    override fun getContentResId(): Int {
        return R.layout.nim_message_item_snapchat
    }

    override fun inflateContentView() {
        thumbnailImageView = view.findViewById<View>(R.id.message_item_snap_chat_image) as ImageView
        progressBar = findViewById(R.id.message_item_thumb_progress_bar) // 覆盖掉
        progressCover = findViewById(R.id.message_item_thumb_progress_cover)
        progressLabel = view.findViewById<View>(R.id.message_item_thumb_progress_text) as TextView
    }

    override fun bindContentView() {
        contentContainer.setOnTouchListener(onTouchListener)
        layoutByDirection()
        refreshStatus()
    }

    private fun refreshStatus() {
        thumbnailImageView!!.setBackgroundResource(if (isReceivedMessage) R.drawable.message_view_holder_left_snapchat else R.drawable.message_view_holder_right_snapchat)
        if (message.status == MsgStatusEnum.sending || message.attachStatus == AttachStatusEnum.transferring) {
            progressCover!!.visibility = View.VISIBLE
            progressBar.visibility = View.VISIBLE
        } else {
            progressCover!!.visibility = View.GONE
        }
        progressLabel!!.text = StringUtil.getPercentString(msgAdapter.getProgress(message))
    }

    override fun shouldDisplayReceipt(): Boolean {
        return false
    }

    protected var onTouchListener = View.OnTouchListener { v, event ->
        when (event.action) {
            MotionEvent.ACTION_MOVE -> v.parent.requestDisallowInterceptTouchEvent(true)
            MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                v.parent.requestDisallowInterceptTouchEvent(false)
                WatchSnapChatPictureActivity.destroy()
                // 删除这条消息，当然你也可以将其标记为已读，同时删除附件内容，然后不让再查看
                if (isLongClick && message.attachStatus == AttachStatusEnum.transferred) { // 物理删除
                    NIMClient.getService(MsgService::class.java).deleteChattingHistory(message)
                    AttachmentStore.delete((message.attachment as SnapChatAttachment).getPath())
                    AttachmentStore.delete((message.attachment as SnapChatAttachment).getThumbPath())
                    msgAdapter.deleteItem(message, true)
                    isLongClick = false
                }
            }
        }
        false
    }

    override fun onItemLongClick(): Boolean {
        if (message.status == MsgStatusEnum.success) {
            WatchSnapChatPictureActivity.start(context, message)
            isLongClick = true
            return true
        }
        return false
    }

    override fun leftBackground(): Int {
        return 0
    }

    override fun rightBackground(): Int {
        return 0
    }

    private fun layoutByDirection() {
        val body = findViewById<View>(R.id.message_item_snap_chat_body)
        val tipsLayout = findViewById<View>(R.id.message_item_tips_layout)
        val tips = findViewById<View>(R.id.message_item_snap_chat_tips_label)
        val readed = findViewById<View>(R.id.message_item_snap_chat_readed)
        val container = body.parent as ViewGroup
        container.removeView(tipsLayout)
        if (isReceivedMessage) {
            container.addView(tipsLayout, 1)
        } else {
            container.addView(tipsLayout, 0)
        }
        if (message.status == MsgStatusEnum.success) {
            tips.visibility = View.VISIBLE
        } else {
            tips.visibility = View.GONE
        }
        if (!TextUtils.isEmpty(msgAdapter.uuid) && message.uuid == msgAdapter.uuid) {
            readed.visibility = View.VISIBLE
        } else {
            readed.visibility = View.GONE
        }
    }
}