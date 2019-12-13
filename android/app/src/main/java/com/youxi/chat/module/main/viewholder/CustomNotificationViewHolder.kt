package com.youxi.chat.module.main.viewholder

import android.view.View
import android.widget.TextView
import com.alibaba.fastjson.JSONObject
import com.netease.nim.uikit.common.adapter.TViewHolder
import com.netease.nim.uikit.common.ui.imageview.HeadImageView
import com.netease.nim.uikit.common.util.sys.ScreenUtil
import com.netease.nim.uikit.common.util.sys.TimeUtil
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum
import com.netease.nimlib.sdk.msg.model.CustomNotification
import com.youxi.chat.R
import com.youxi.chat.module.session.MessageHelper

class CustomNotificationViewHolder : TViewHolder() {
    private var imgHead: HeadImageView? = null
    private var lblNickname: TextView? = null
    private var lblMessage: TextView? = null
    private var lblDatetime: TextView? = null
    private var notification: CustomNotification? = null
    private var bottomLine: View? = null
    private var topLine: View? = null
    public override fun refresh(item: Any) {
        notification = item as CustomNotification
        updateBackground()
        loadPortrait()
        updateNickLabel(MessageHelper.getName(notification!!.fromAccount,
                notification!!.sessionType))
        updateMsgLabel()
    }

    private fun updateBackground() {
        topLine!!.visibility = if (isFirstItem) View.GONE else View.VISIBLE
        bottomLine!!.visibility = if (isLastItem) View.VISIBLE else View.GONE
        view.setBackgroundResource(R.drawable.nim_list_item_bg_selecter)
    }

    protected fun loadPortrait() { // 设置头像
        if (notification!!.sessionType == SessionTypeEnum.P2P) {
            imgHead!!.loadBuddyAvatar(notification!!.fromAccount)
        } else if (notification!!.sessionType == SessionTypeEnum.Team) {
            imgHead!!.setImageResource(R.drawable.nim_avatar_group)
        } else if (notification!!.sessionType == SessionTypeEnum.SUPER_TEAM) {
            imgHead!!.setImageResource(R.drawable.nim_avatar_group)
        }
    }

    private fun updateMsgLabel() {
        val jsonObj = JSONObject.parseObject(notification!!.content)
        val id = jsonObj.getString("id")
        val content: String
        content = if (id != null && id == "1") {
            "正在输入..."
        } else {
            jsonObj.getString("content")
        }
        lblMessage!!.text = content
        val timeString = TimeUtil.getTimeShowString(notification!!.time, true)
        lblDatetime!!.text = timeString
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
        return R.layout.item_custom_notification
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