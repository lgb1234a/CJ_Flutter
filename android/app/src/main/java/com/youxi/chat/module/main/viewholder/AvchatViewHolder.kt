package com.youxi.chat.module.main.viewholder

import android.view.View
import android.widget.TextView
import com.alibaba.fastjson.JSONObject
import com.netease.nim.uikit.common.adapter.TViewHolder
import com.netease.nim.uikit.common.ui.imageview.HeadImageView
import com.netease.nim.uikit.common.util.sys.ScreenUtil
import com.netease.nim.uikit.common.util.sys.TimeUtil
import com.netease.nimlib.sdk.avchat.model.AVChatAttachment
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum
import com.netease.nimlib.sdk.msg.model.IMMessage
import com.youxi.chat.R
import com.youxi.chat.module.session.MessageHelper

class AvchatViewHolder : TViewHolder() {
    private var imgHead: HeadImageView? = null
    private var lblNickname: TextView? = null
    private var lblMessage: TextView? = null
    private var lblDatetime: TextView? = null
    private var message: IMMessage? = null
    private var bottomLine: View? = null
    private var topLine: View? = null
    public override fun refresh(item: Any) {
        message = item as IMMessage
        updateBackground()
        loadPortrait()
        updateNickLabel(MessageHelper.getName(message!!.fromAccount, message!!.sessionType))
        updateMsgLabel()
    }

    private fun updateBackground() {
        topLine!!.visibility = if (isFirstItem) View.GONE else View.VISIBLE
        bottomLine!!.visibility = if (isLastItem) View.VISIBLE else View.GONE
        view.setBackgroundResource(R.drawable.nim_list_item_bg_selecter)
    }

    protected fun loadPortrait() { // 设置头像
        if (message!!.sessionType == SessionTypeEnum.P2P) {
            imgHead!!.loadBuddyAvatar(message!!.fromAccount)
        } else if (message!!.sessionType == SessionTypeEnum.Team) {
            imgHead!!.setImageResource(R.drawable.nim_avatar_group)
        } else if (message!!.sessionType == SessionTypeEnum.Team) {
            imgHead!!.setImageResource(R.drawable.nim_avatar_group)
        }
    }

    private fun updateMsgLabel() {
        lblMessage!!.text = content
        val timeString = TimeUtil.getTimeShowString(message!!.time, true)
        lblDatetime!!.text = timeString
    }

    private val content: String
        private get() {
            val avChatAttachment = message!!.attachment as AVChatAttachment
            val node = JSONObject()
            node["聊天对象ID"] = message!!.sessionId
            node["Nick"] = message!!.fromNick
            node["Time"] = message!!.time
            node["SessionType"] = message!!.sessionType
            node["MsgType"] = message!!.msgType
            node["state:"] = avChatAttachment.state
            node["duration:"] = avChatAttachment.duration
            node["type:"] = avChatAttachment.type
            return node.toJSONString()
        }

    protected fun updateNickLabel(nick: String?) {
        var labelWidth = ScreenUtil.screenWidth
        labelWidth -= ScreenUtil.dip2px(50 + 70.toFloat()) // 减去固定的头像和时间宽度
        if (labelWidth > 0) {
            lblNickname!!.maxWidth = labelWidth
        }
        lblNickname!!.text = nick
    }

    override fun getResId(): Int {
        return R.layout.item_avchat_view_holder
    }

    public override fun inflate() {
        imgHead = view.findViewById(R.id.img_head)
        lblNickname = view.findViewById(R.id.tv_nick_name)
        lblMessage = view.findViewById(R.id.tv_message)
        lblDatetime = view.findViewById(R.id.tv_date_time)
        topLine = view.findViewById(R.id.top_line)
        bottomLine = view.findViewById(R.id.bottom_line)
    }
}