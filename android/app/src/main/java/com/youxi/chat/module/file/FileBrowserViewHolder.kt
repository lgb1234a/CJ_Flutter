package com.youxi.chat.module.file

import android.widget.ImageView
import android.widget.TextView
import com.netease.nim.uikit.common.adapter.TViewHolder
import com.youxi.chat.R
import com.youxi.chat.module.file.FileBrowserAdapter.FileManagerItem
import java.io.File

/**
 * Created by hzxuwen on 2015/4/17.
 */
class FileBrowserViewHolder : TViewHolder() {
    private var fileImage: ImageView? = null
    private var fileName: TextView? = null
    private var fileItem: FileManagerItem? = null
    override fun getResId(): Int {
        return R.layout.file_browser_list_item
    }

    override fun inflate() {
        fileImage = view.findViewById(R.id.file_image)
        fileName = view.findViewById(R.id.file_name)
    }

    override fun refresh(item: Any) {
        fileItem = item as FileManagerItem
        val f = File(fileItem?.path)
        if (fileItem?.name == "@1") {
            fileName!!.text = "/返回根目录"
            fileImage!!.setImageResource(R.drawable.directory)
        } else if (fileItem?.name == "@2") {
            fileName!!.text = "..返回上一级目录"
            fileImage!!.setImageResource(R.drawable.directory)
        } else {
            fileName?.setText(fileItem?.name)
            if (f.isDirectory) {
                fileImage!!.setImageResource(R.drawable.directory)
            } else if (f.isFile) {
                fileImage!!.setImageResource(R.drawable.file)
            }
        }
    }
}