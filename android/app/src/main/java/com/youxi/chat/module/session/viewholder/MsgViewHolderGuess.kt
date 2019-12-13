package com.youxi.chat.module.session.viewholder

import android.view.View
import android.widget.ImageView
import com.netease.nim.uikit.business.session.viewholder.MsgViewHolderBase
import com.netease.nim.uikit.common.ui.recyclerview.adapter.BaseMultiItemFetchLoadAdapter
import com.youxi.chat.R
import com.youxi.chat.module.session.extension.GuessAttachment

/**
 * Created by hzliuxuanlin on 17/9/15.
 */
class MsgViewHolderGuess(adapter: BaseMultiItemFetchLoadAdapter<*, *>?) : MsgViewHolderBase(adapter) {
    private var guessAttachment: GuessAttachment? = null
    private var imageView: ImageView? = null
    override fun getContentResId(): Int {
        return R.layout.rock_paper_scissors
    }

    override fun inflateContentView() {
        imageView = view.findViewById<View>(R.id.rock_paper_scissors_text) as ImageView
    }

    override fun bindContentView() {
        if (message.attachment == null) {
            return
        }
        guessAttachment = message.attachment as GuessAttachment
        when (guessAttachment?.value?.desc) {
            "石头" -> imageView!!.setImageResource(R.drawable.message_view_rock)
            "剪刀" -> imageView!!.setImageResource(R.drawable.message_view_scissors)
            "布" -> imageView!!.setImageResource(R.drawable.message_view_paper)
            else -> {
            }
        }
    }
}