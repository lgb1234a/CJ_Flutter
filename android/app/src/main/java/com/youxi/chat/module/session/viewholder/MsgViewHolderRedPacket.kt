package com.youxi.chat.module.session.viewholder

import android.view.View
import android.widget.RelativeLayout
import android.widget.TextView
import com.netease.nim.uikit.business.chatroom.adapter.ChatRoomMsgAdapter
import com.netease.nim.uikit.business.session.module.ModuleProxy
import com.netease.nim.uikit.business.session.module.list.MsgAdapter
import com.netease.nim.uikit.business.session.viewholder.MsgViewHolderBase
import com.netease.nim.uikit.common.ui.recyclerview.adapter.BaseMultiItemFetchLoadAdapter
import com.youxi.chat.R
import com.youxi.chat.module.session.extension.RedPacketAttachment

class MsgViewHolderRedPacket(adapter: BaseMultiItemFetchLoadAdapter<*, *>?) : MsgViewHolderBase(adapter) {
    private var sendView: RelativeLayout? = null
    private var revView: RelativeLayout? = null
    private var sendContentText: TextView? = null
    private var revContentText // 红包描述
            : TextView? = null
    private var sendTitleText: TextView? = null
    private var revTitleText // 红包名称
            : TextView? = null

    override fun getContentResId(): Int {
        return R.layout.red_packet_item
    }

    override fun inflateContentView() {
        sendContentText = findViewById(R.id.tv_bri_mess_send)
        sendTitleText = findViewById(R.id.tv_bri_name_send)
        sendView = findViewById(R.id.bri_send)
        revContentText = findViewById(R.id.tv_bri_mess_rev)
        revTitleText = findViewById(R.id.tv_bri_name_rev)
        revView = findViewById(R.id.bri_rev)
    }

    override fun bindContentView() {
        val attachment: RedPacketAttachment = message.attachment as RedPacketAttachment
        if (!isReceivedMessage) { // 消息方向，自己发送的
            sendView!!.visibility = View.VISIBLE
            revView!!.visibility = View.GONE
            sendContentText?.setText(attachment.rpContent)
            sendTitleText?.setText(attachment.rpTitle)
        } else {
            sendView!!.visibility = View.GONE
            revView!!.visibility = View.VISIBLE
            revContentText?.setText(attachment.rpContent)
            revTitleText?.setText(attachment.rpTitle)
        }
    }

    override fun leftBackground(): Int {
        return R.color.transparent
    }

    override fun rightBackground(): Int {
        return R.color.transparent
    }

    override fun onItemClick() { // 拆红包
        val attachment: RedPacketAttachment = message.attachment as RedPacketAttachment
        val adapter = getAdapter()
        var proxy: ModuleProxy? = null
        if (adapter is MsgAdapter) {
            proxy = adapter.container.proxy
        } else if (adapter is ChatRoomMsgAdapter) {
            proxy = adapter.container.proxy
        }
        // TODO 拆红包
//        val cb = NIMOpenRpCallback(message.fromAccount, message.sessionId, message.sessionType, proxy)
//        NIMRedPacketClient.startOpenRpDialog(context as Activity, message.sessionType, attachment.getRpId(), cb)
    }
}