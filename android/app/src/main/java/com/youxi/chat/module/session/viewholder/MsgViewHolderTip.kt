package com.youxi.chat.module.session.viewholder

import android.text.TextUtils
import android.text.method.LinkMovementMethod
import android.text.style.ImageSpan
import android.view.View
import android.widget.TextView
import com.netease.nim.uikit.R
import com.netease.nim.uikit.business.session.emoji.MoonUtil
import com.netease.nim.uikit.business.session.viewholder.MsgViewHolderBase
import com.netease.nim.uikit.common.ui.recyclerview.adapter.BaseMultiItemFetchLoadAdapter

/**
 * Created by huangjun on 2015/11/25.
 * Tip类型消息ViewHolder
 */
class MsgViewHolderTip(adapter: BaseMultiItemFetchLoadAdapter<*, *>?) : MsgViewHolderBase(adapter) {
    protected var notificationTextView: TextView? = null
    override fun getContentResId(): Int {
        return R.layout.nim_message_item_notification
    }

    override fun inflateContentView() {
        notificationTextView = view.findViewById<View>(R.id.message_item_notification_label) as TextView
    }

    override fun bindContentView() {
        var text: String? = "未知通知提醒"
        if (TextUtils.isEmpty(message.content)) {
            val content = message.remoteExtension
            if (content != null && !content.isEmpty()) {
                text = content["content"] as String?
            }
        } else {
            text = message.content
        }
        handleTextNotification(text)
    }

    private fun handleTextNotification(text: String?) {
        MoonUtil.identifyFaceExpressionAndATags(context, notificationTextView, text, ImageSpan.ALIGN_BOTTOM)
        notificationTextView!!.movementMethod = LinkMovementMethod.getInstance()
    }

    override fun isMiddleItem(): Boolean {
        return true
    }
}