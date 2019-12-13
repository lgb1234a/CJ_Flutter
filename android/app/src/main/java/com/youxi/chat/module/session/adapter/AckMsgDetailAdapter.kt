package com.youxi.chat.module.session.adapter

import android.content.Context
import com.netease.nim.uikit.common.adapter.TAdapter
import com.netease.nim.uikit.common.adapter.TAdapterDelegate

/**
 * Created by winnie on 2018/3/17.
 */
class AckMsgDetailAdapter(context: Context?, items: List<*>?, delegate: TAdapterDelegate?) : TAdapter<Any?>(context, items, delegate) {
    /**
     * GridView数据项
     */
    class AckMsgDetailItem(val tid: String, val account: String)
}