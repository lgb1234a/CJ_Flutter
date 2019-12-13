package com.youxi.chat.module.session.extension

import com.alibaba.fastjson.JSONObject

/**
 * Created by zhoujianghua on 2015/4/10.
 */
class DefaultCustomAttachment : CustomAttachment(0) {
    var content: String? = null
        private set

    override fun parseData(data: JSONObject) {
        content = data.toJSONString()
    }

    protected override fun packData(): JSONObject? {
        var data: JSONObject? = null
        try {
            data = JSONObject.parseObject(content)
        } catch (e: Exception) {
        }
        return data
    }

}