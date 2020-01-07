package com.youxi.chat.module.session.viewholder

import com.netease.nim.uikit.common.ui.recyclerview.adapter.BaseQuickAdapter
import com.netease.nim.uikit.impl.NimUIKitImpl
import com.netease.nimlib.sdk.msg.constant.MsgTypeEnum
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum
import com.netease.nimlib.sdk.msg.model.RecentContact

open class CommonSessionViewHolder internal constructor(adapter: BaseQuickAdapter<*, *>?) : SessionViewHolder(adapter) {
    override fun getContent(recent: RecentContact): String? {
        return descOfMsg(recent)
    }

    override fun getOnlineStateContent(recent: RecentContact): String? {
        return if (recent.sessionType == SessionTypeEnum.P2P && NimUIKitImpl.enableOnlineState()) {
            NimUIKitImpl.getOnlineStateContentProvider().getSimpleDisplay(recent.contactId)
        } else {
            super.getOnlineStateContent(recent)
        }
    }

    fun descOfMsg(recent: RecentContact): String? {
        if (recent.msgType == MsgTypeEnum.text) {
            return recent.content
        } else if (recent.msgType == MsgTypeEnum.tip) {
            var digest: String? = null
            if (callback != null) {
                digest = callback.getDigestOfTipMsg(recent)
            }
            if (digest == null) {
                digest = NimUIKitImpl.getRecentCustomization().getDefaultDigest(recent)
            }
            return digest
        } else if (recent.attachment != null) {
            var digest: String? = null
            if (callback != null) {
                digest = callback.getDigestOfAttachment(recent, recent.attachment)
            }
            if (digest == null) {
                digest = NimUIKitImpl.getRecentCustomization().getDefaultDigest(recent)
            }
            return digest
        }
        return "[收到未知类型消息，请更新擦肩版本]"
    }
}