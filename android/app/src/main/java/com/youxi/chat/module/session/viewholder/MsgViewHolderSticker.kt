package com.youxi.chat.module.session.viewholder

import android.widget.ImageView
import com.bumptech.glide.Glide
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.bumptech.glide.request.RequestOptions
import com.netease.nim.uikit.business.session.emoji.StickerManager
import com.netease.nim.uikit.business.session.viewholder.MsgViewHolderBase
import com.netease.nim.uikit.business.session.viewholder.MsgViewHolderThumbBase
import com.netease.nim.uikit.common.ui.recyclerview.adapter.BaseMultiItemFetchLoadAdapter
import com.youxi.chat.R
import com.youxi.chat.module.session.extension.StickerAttachment

/**
 * Created by zhoujianghua on 2015/8/7.
 */
class MsgViewHolderSticker(adapter: BaseMultiItemFetchLoadAdapter<*, *>?) : MsgViewHolderBase(adapter) {
    private var baseView: ImageView? = null
    override fun getContentResId(): Int {
        return R.layout.nim_message_item_sticker
    }

    override fun inflateContentView() {
        baseView = findViewById(R.id.message_item_sticker_image)
        baseView?.setMaxWidth(MsgViewHolderThumbBase.getImageMaxEdge())
    }

    override fun bindContentView() {
        val attachment: StickerAttachment = message.attachment as StickerAttachment ?: return
        Glide.with(context)
                .load(StickerManager.getInstance().getStickerUri(attachment.catalog, attachment.chartlet))
                .apply(RequestOptions()
                        .error(R.drawable.nim_default_img_failed)
                        .diskCacheStrategy(DiskCacheStrategy.NONE))
                .into(baseView!!)
    }

    override fun leftBackground(): Int {
        return 0
    }

    override fun rightBackground(): Int {
        return 0
    }
}