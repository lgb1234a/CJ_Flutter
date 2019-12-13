package com.youxi.chat.module.session.viewholder

import android.graphics.Color
import android.widget.ImageView
import android.widget.TextView
import com.netease.nim.uikit.business.session.viewholder.MsgViewHolderBase
import com.netease.nim.uikit.common.ui.recyclerview.adapter.BaseMultiItemFetchLoadAdapter
import com.netease.nim.uikit.common.util.sys.TimeUtil
import com.netease.nimlib.sdk.avchat.constant.AVChatRecordState
import com.netease.nimlib.sdk.avchat.constant.AVChatType
import com.netease.nimlib.sdk.avchat.model.AVChatAttachment
import com.netease.nimlib.sdk.msg.constant.MsgDirectionEnum
import com.youxi.chat.R

/**
 * Created by zhoujianghua on 2015/8/6.
 */
class MsgViewHolderAVChat(adapter: BaseMultiItemFetchLoadAdapter<*, *>?) : MsgViewHolderBase(adapter) {
    private var typeImage: ImageView? = null
    private var statusLabel: TextView? = null
    override fun getContentResId(): Int {
        return R.layout.nim_message_item_avchat
    }

    override fun inflateContentView() {
        typeImage = findViewById(R.id.message_item_avchat_type_img)
        statusLabel = findViewById(R.id.message_item_avchat_state)
    }

    override fun bindContentView() {
        if (message.attachment == null) {
            return
        }
        layoutByDirection()
        refreshContent()
    }

    private fun layoutByDirection() {
        val attachment: AVChatAttachment = message.attachment as AVChatAttachment
        if (isReceivedMessage) {
            if (attachment.getType() === AVChatType.AUDIO) {
                typeImage!!.setImageResource(R.drawable.avchat_left_type_audio)
            } else {
                typeImage!!.setImageResource(R.drawable.avchat_left_type_video)
            }
            statusLabel!!.setTextColor(context.resources.getColor(R.color.color_grey_999999))
        } else {
            if (attachment.getType() === AVChatType.AUDIO) {
                typeImage!!.setImageResource(R.drawable.avchat_right_type_audio)
            } else {
                typeImage!!.setImageResource(R.drawable.avchat_right_type_video)
            }
            statusLabel!!.setTextColor(Color.WHITE)
        }
    }

    private fun refreshContent() {
        val attachment: AVChatAttachment = message.attachment as AVChatAttachment
        var textString: String? = ""
        when (attachment.getState()) {
            AVChatRecordState.Success -> textString = TimeUtil.secToTime(attachment.getDuration())
            AVChatRecordState.Missed -> textString = context.getString(R.string.avchat_no_pick_up)
            AVChatRecordState.Rejected -> {
                val strID: Int = if (message.direct == MsgDirectionEnum.In) R.string.avchat_has_reject else R.string.avchat_be_rejected
                textString = context.getString(strID)
            }
            AVChatRecordState.Canceled -> textString = context.getString(R.string.avchat_cancel)
            else -> {
            }
        }
        statusLabel!!.text = textString
    }
}