package com.youxi.chat.module.session.extension

import com.alibaba.fastjson.JSON
import com.alibaba.fastjson.JSONObject
import com.netease.nimlib.sdk.msg.attachment.MsgAttachment
import com.netease.nimlib.sdk.msg.attachment.MsgAttachmentParser

/**
 * Created by zhoujianghua on 2015/4/9.
 */
class CustomAttachParser : MsgAttachmentParser {
    override fun parse(json: String): MsgAttachment {
        var attachment: CustomAttachment? = null
        try {
            val `object` = JSON.parseObject(json)
            val type = `object`.getInteger(KEY_TYPE)
            val data = `object`.getJSONObject(KEY_DATA)
            when (type) {
                CustomAttachmentType.Guess -> attachment = GuessAttachment()
                CustomAttachmentType.SnapChat -> return SnapChatAttachment(data)
                CustomAttachmentType.Sticker -> attachment = StickerAttachment()
                CustomAttachmentType.RTS -> attachment = RTSAttachment()
                CustomAttachmentType.RedPacket -> attachment = RedPacketAttachment()
                CustomAttachmentType.OpenedRedPacket -> attachment = RedPacketOpenedAttachment()
                CustomAttachmentType.MultiRetweet -> attachment = MultiRetweetAttachment()
                else -> attachment = DefaultCustomAttachment()
            }
            if (attachment != null) {
                attachment.fromJson(data)
            }
        } catch (e: Exception) {
        }
        return attachment!!
    }

    companion object {
        private const val KEY_TYPE = "type"
        private const val KEY_DATA = "data"
        fun packData(type: Int, data: JSONObject?): String {
            val `object` = JSONObject()
            `object`[KEY_TYPE] = type
            if (data != null) {
                `object`[KEY_DATA] = data
            }
            return `object`.toJSONString()
        }
    }
}