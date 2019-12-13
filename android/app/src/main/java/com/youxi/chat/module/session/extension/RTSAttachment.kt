package com.youxi.chat.module.session.extension

import com.alibaba.fastjson.JSONObject
import com.youxi.chat.R
import com.youxi.chat.nim.NimCache

/**
 * Created by huangjun on 2015/7/28.
 */
class RTSAttachment() : CustomAttachment(CustomAttachmentType.RTS) {
    var flag: Byte = 0
        private set

    constructor(flag: Byte) : this() {
        this.flag = flag
    }

    override fun packData(): JSONObject {
        val data = JSONObject()
        data["flag"] = flag
        return data
    }

    override fun parseData(data: JSONObject) {
        flag = data.getByte("flag")
    }

    val content: String
        get() = NimCache.getContext().getString(if (flag.toInt() == 0) R.string.start_session_record
        else R.string.session_end_record)
}