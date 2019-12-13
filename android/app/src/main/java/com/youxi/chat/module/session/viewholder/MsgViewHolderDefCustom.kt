package com.youxi.chat.module.session.viewholder

import com.netease.nim.uikit.business.session.viewholder.MsgViewHolderText
import com.netease.nim.uikit.common.ui.recyclerview.adapter.BaseMultiItemFetchLoadAdapter
import com.youxi.chat.module.session.extension.DefaultCustomAttachment

/**
 * Created by zhoujianghua on 2015/8/4.
 */
class MsgViewHolderDefCustom(adapter: BaseMultiItemFetchLoadAdapter<*, *>?) : MsgViewHolderText(adapter) {
    override fun getDisplayText(): String {
        val attachment: DefaultCustomAttachment = message.attachment as DefaultCustomAttachment
        return "type: " + attachment.type.toString() + ", data: " + attachment.content
    }
}