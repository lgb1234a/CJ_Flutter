package com.youxi.chat.module.session.extension

import com.alibaba.fastjson.JSONObject
import com.netease.nim.uikit.common.util.file.FileUtil

/**
 * Created by zhoujianghua on 2015/7/8.
 */
class StickerAttachment() : CustomAttachment(CustomAttachmentType.Sticker) {
    private val KEY_CATALOG = "catalog"
    private val KEY_CHARTLET = "chartlet"
    var catalog: String? = null
        private set
    var chartlet: String? = null
        private set

    constructor(catalog: String?, emotion: String?) : this() {
        this.catalog = catalog
        chartlet = FileUtil.getFileNameNoEx(emotion)
    }

    override fun parseData(data: JSONObject) {
        catalog = data.getString(KEY_CATALOG)
        chartlet = data.getString(KEY_CHARTLET)
    }

    protected override fun packData(): JSONObject {
        val data = JSONObject()
        data[KEY_CATALOG] = catalog
        data[KEY_CHARTLET] = chartlet
        return data
    }

}