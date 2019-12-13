package com.youxi.chat.module.session.adapter

import android.app.Activity
import android.text.style.ImageSpan
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.netease.nim.uikit.api.NimUIKit
import com.netease.nim.uikit.business.session.emoji.MoonUtil
import com.netease.nim.uikit.business.session.module.Container
import com.netease.nim.uikit.business.session.module.list.MsgAdapter
import com.netease.nim.uikit.business.session.viewholder.MsgViewHolderAudio
import com.netease.nim.uikit.business.session.viewholder.MsgViewHolderBase
import com.netease.nim.uikit.business.session.viewholder.MsgViewHolderFactory
import com.netease.nim.uikit.common.ui.imageview.HeadImageView
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.msg.MsgService
import com.netease.nimlib.sdk.msg.attachment.ImageAttachment
import com.netease.nimlib.sdk.msg.attachment.VideoAttachment
import com.netease.nimlib.sdk.msg.constant.MsgTypeEnum
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum
import com.netease.nimlib.sdk.msg.model.IMMessage
import com.youxi.chat.R
import com.youxi.chat.module.session.MessageHelper
import java.text.SimpleDateFormat
import java.util.*

class MultiRetweetAdapter(private val mRecyclerView: RecyclerView, private val mItems: List<IMMessage>, private val mContext: Activity) : RecyclerView.Adapter<MultiRetweetAdapter.ViewHolder>() {
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val itemView: View = LayoutInflater.from(parent.context).inflate(R.layout.nim_multi_retweet_item, parent, false)
        return ViewHolder(itemView)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val msg = mItems[position]
        var subViewHolder: MsgViewHolderBase? = null
        try {
            val viewHolerClazz = MsgViewHolderFactory.getViewHolderByType(msg)
            val vidwHolderConstructor = viewHolerClazz.declaredConstructors[0] // 第一个显式的构造函数
            vidwHolderConstructor.isAccessible = true
            val subAdapter = MsgAdapter(mRecyclerView, mItems, Container(mContext, null, null, null))
            subViewHolder = vidwHolderConstructor.newInstance(*arrayOf<Any>(subAdapter)) as MsgViewHolderBase
        } catch (e: Exception) {
            e.printStackTrace()
        }
        holder.setViews(msg, mContext, showDate(position), subViewHolder)
    }

    /**
     * 判断是否需要显示日期
     * 如果跨越一天，则要显示
     *
     * @param position 项所在的位置
     * @return true: 显示; false: 不显示
     */
    private fun showDate(position: Int): Boolean {
        if (position < 0) {
            return false
        }
        if (position == 0) {
            return true
        }
        val message = mItems[position]
        val lastMessage = mItems[position - 1]
        val dateFormat = SimpleDateFormat("yyyyMMdd", Locale.CHINA)
        val msgDate = Date(message.time)
        val lastDate = Date(lastMessage.time)
        return dateFormat.format(msgDate) != dateFormat.format(lastDate)
    }

    override fun getItemCount(): Int {
        return mItems.size
    }

    class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        /** 发送方名称  */
        private var mSessionNameTV: TextView? = null
        /** 头像  */
        private var mAvatarHIV: HeadImageView? = null
        /** 消息内容  */
        private var mDetailsTV: TextView? = null
        /** 图片、视频的简略展示  */
        private var mDetailsIV: ImageView? = null
        /** 消息时间  */
        private var mTimeTV: TextView? = null
        /** 日期标记  */
        private var mDateTV: TextView? = null
        private var mContentContainer: FrameLayout? = null
        private var mContentViewHolder: MsgViewHolderBase? = null
        fun setViews(msg: IMMessage, context: Activity, showDate: Boolean, contentViewHolder: MsgViewHolderBase?) {
            mContentViewHolder = contentViewHolder
            findViews()
            initViews(msg, context, showDate)
        }

        private fun findViews() {
            mAvatarHIV = itemView.findViewById(R.id.message_item_portrait_left)
            mSessionNameTV = itemView.findViewById(R.id.tv_session_name)
            mDetailsTV = itemView.findViewById(R.id.tv_details)
            mDetailsIV = itemView.findViewById(R.id.img_details)
            mTimeTV = itemView.findViewById(R.id.tv_time)
            mDateTV = itemView.findViewById(R.id.tv_date)
            mContentContainer = itemView.findViewById(R.id.fl_content_container)
        }

        private fun initViews(msg: IMMessage, context: Activity, showDate: Boolean) { //头像
            mAvatarHIV!!.loadBuddyAvatar(msg)
            //会话名称
            val senderName: String? = MessageHelper.getStoredNameFromSessionId(msg.fromAccount,
                    SessionTypeEnum.P2P)
            mSessionNameTV!!.text = senderName ?: msg.fromAccount
            //消息时间和日期 HH:mm
            val time = msg.time
            val timeFormat = SimpleDateFormat("HH:mm", Locale.CHINA)
            val dateFormat = SimpleDateFormat("yyyy-MM-dd", Locale.CHINA)
            val date = Date(time)
            mTimeTV!!.text = timeFormat.format(date)
            mDateTV!!.text = dateFormat.format(date)
            mDateTV!!.visibility = if (showDate) View.VISIBLE else View.GONE
            //初始化消息内容
            initContent(msg, context)
            //设置点击事件
            itemView.setOnClickListener { v: View? ->
                if (mContentViewHolder == null) {
                    return@setOnClickListener
                }
                mContentViewHolder!!.onItemClick()
            }
        }

        private fun initContent(msg: IMMessage, context: Activity) { //读取ViewHolder失败
            if (mContentViewHolder == null) { //缺省方式加载资源
                initContentInSimple(msg, context)
                return
            }
            mDetailsTV!!.visibility = View.GONE
            mDetailsIV!!.visibility = View.GONE
            try {
                val subViewId = mContentViewHolder!!.contentResId
                mContentContainer!!.removeAllViews()
                val inflater = LayoutInflater.from(context)
                inflater.inflate(subViewId, mContentContainer, true)
                mContentViewHolder!!.initParameter(itemView, context, msg, layoutPosition)
                mContentViewHolder!!.inflateContentView()
                mContentViewHolder!!.bindContentView()
                if (mContentViewHolder is MsgViewHolderAudio) {
                    NIMClient.getService(MsgService::class.java).downloadAttachment(msg, false)
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        private fun initContentInSimple(msg: IMMessage, context: Activity) {
            mContentContainer!!.removeAllViews()
            val msgType = msg.msgType
            // 消息概要
            if (MsgTypeEnum.text == msgType) {
                // 文本
                mDetailsTV!!.visibility = View.VISIBLE
                mDetailsIV!!.visibility = View.GONE
                MoonUtil.identifyFaceExpression(NimUIKit.getContext(), mDetailsTV, MessageHelper.getContent(msg), ImageSpan.ALIGN_BOTTOM)
            } else if (MsgTypeEnum.image == msgType) {
                // 图片
                mDetailsTV!!.visibility = View.GONE
                mDetailsIV!!.visibility = View.VISIBLE
                val attachment = msg.attachment as ImageAttachment
                Glide.with(context).load(attachment.url).into(mDetailsIV!!)
            } else if (MsgTypeEnum.video == msgType) {
                // 视频
                mDetailsTV!!.visibility = View.GONE
                mDetailsIV!!.visibility = View.VISIBLE
                val attachment = msg.attachment as VideoAttachment
                Glide.with(context).load(attachment.thumbUrl).into(mDetailsIV!!)
            } else {
                mDetailsTV!!.visibility = View.VISIBLE
                mDetailsIV!!.visibility = View.GONE
                mDetailsTV?.setText(MessageHelper.getContent(msg))
            }
            return
        }
    }

}