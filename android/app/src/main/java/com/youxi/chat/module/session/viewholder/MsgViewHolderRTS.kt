package com.youxi.chat.module.session.viewholder

import android.view.View
import android.widget.TextView
import com.netease.nim.uikit.business.session.viewholder.MsgViewHolderBase
import com.netease.nim.uikit.common.ui.recyclerview.adapter.BaseMultiItemFetchLoadAdapter
import com.youxi.chat.R
import com.youxi.chat.module.session.extension.RTSAttachment

class MsgViewHolderRTS(adapter: BaseMultiItemFetchLoadAdapter<*, *>?) : MsgViewHolderBase(adapter) {
    private var textView: TextView? = null
    override fun getContentResId(): Int {
        return R.layout.nim_message_item_rts
    }

    override fun inflateContentView() {
        textView = view.findViewById<View>(R.id.rts_text) as TextView
    }

    override fun bindContentView() {
        val attachment: RTSAttachment = message.attachment as RTSAttachment
        textView?.setText(attachment.content)
    }
}