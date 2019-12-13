package com.youxi.chat.module.session.extension

import com.alibaba.fastjson.JSONObject
import com.netease.nimlib.sdk.msg.attachment.MsgAttachment

/**
 * Created by zhoujianghua on 2015/4/9.
 */
abstract class CustomAttachment internal constructor(var type: Int) : MsgAttachment {
    fun fromJson(data: JSONObject?) {
        data?.let { parseData(it) }
    }

    override fun toJson(send: Boolean): String {
        return CustomAttachParser.packData(type, packData())
    }

    protected abstract fun parseData(data: JSONObject)
    protected abstract fun packData(): JSONObject?

}