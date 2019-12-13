package com.youxi.chat.module.file

import android.content.Context
import com.netease.nim.uikit.common.adapter.TAdapter
import com.netease.nim.uikit.common.adapter.TAdapterDelegate

/**
 * Created by hzxuwen on 2015/4/17.
 */
class FileBrowserAdapter(context: Context?, items: List<*>?, delegate: TAdapterDelegate?) : TAdapter<Any?>(context, items, delegate) {
    class FileManagerItem(val name: String, val path: String)
}