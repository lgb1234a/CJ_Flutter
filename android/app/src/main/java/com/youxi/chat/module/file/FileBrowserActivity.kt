package com.youxi.chat.module.file

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.os.Environment
import android.widget.AdapterView
import android.widget.ListView
import com.netease.nim.uikit.api.wrapper.NimToolBarOptions
import com.netease.nim.uikit.common.ToastHelper
import com.netease.nim.uikit.common.activity.ToolBarOptions
import com.netease.nim.uikit.common.activity.UI
import com.netease.nim.uikit.common.adapter.TAdapterDelegate
import com.netease.nim.uikit.common.adapter.TViewHolder
import com.youxi.chat.R
import com.youxi.chat.module.file.FileBrowserAdapter.FileManagerItem
import java.io.File
import java.util.*

/**
 * 文件管理器
 * Created by hzxuwen on 2015/4/17.
 */
class FileBrowserActivity : UI(), TAdapterDelegate {
    // data
    private var names: ArrayList<String>? = null //存储文件名称
    private var paths: ArrayList<String>? = null //存储文件路径
    // view
    private var fileListView: ListView? = null
    private val fileListItems: MutableList<FileManagerItem> = ArrayList<FileManagerItem>()
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.file_browser_activity)
        val options: ToolBarOptions = NimToolBarOptions()
        setToolBar(R.id.toolbar, options)
        findViews()
        showFileDir(ROOT_PATH)
    }

    private fun findViews() {
        fileListView = findViewById(R.id.file_list)
    }

    /**
     * 显示文件列表
     *
     * @param path 根路径
     */
    private fun showFileDir(path: String) {
        names = ArrayList()
        paths = ArrayList()
        val file = File(path)
        var files: Array<File>? = null
        try {
            files = file.listFiles()
        } catch (e: Exception) {
            e.printStackTrace()
            ToastHelper.showToast(this, "获取文件列表失败")
        }
        //获取失败
        if (files == null || files.size == 0) {
            ToastHelper.showToast(this, "当前文件夹为空")
            return
        }
        //如果当前目录不是根目录
        if (ROOT_PATH != path) {
            names!!.add("@1")
            paths!!.add(ROOT_PATH)
            names!!.add("@2")
            paths!!.add(file.parent)
        }
        //添加所有文件
        for (f in files) {
            names!!.add(f.name)
            paths!!.add(f.path)
        }
        fileListItems.clear()
        for (i in names!!.indices) {
            fileListItems.add(FileManagerItem(names!![i], paths!![i]))
        }
        fileListView!!.itemsCanFocus = true
        fileListView!!.adapter = FileBrowserAdapter(this, fileListItems, this)
        fileListView!!.onItemClickListener = AdapterView.OnItemClickListener { parent, view, position, id ->
            val path: String = fileListItems[position].path
            val file = File(path)
            // 文件存在并可读
            if (file.exists() && file.canRead()) {
                if (file.isDirectory) { //显示子目录及文件
                    showFileDir(path)
                } else { //处理文件
                    selectFile(path)
                }
            } else { //没有权限
                ToastHelper.showToast(this@FileBrowserActivity, R.string.no_permission)
            }
        }
    }

    private fun selectFile(path: String) {
        val intent = Intent()
        intent.putExtra(EXTRA_DATA_PATH, path)
        setResult(Activity.RESULT_OK, intent)
        finish()
    }

    /**
     * *************** implements TAdapterDelegate ***************
     */
    override fun getViewTypeCount(): Int {
        return 1
    }

    override fun viewHolderAtPosition(position: Int): Class<out TViewHolder> {
        return FileBrowserViewHolder::class.java
    }

    override fun enabled(position: Int): Boolean {
        return true
    }

    companion object {
        // constant
        private val ROOT_PATH = Environment.getExternalStorageDirectory().path
        const val EXTRA_DATA_PATH = "EXTRA_DATA_PATH"
        fun startActivityForResult(activity: Activity, reqCode: Int) {
            val intent = Intent()
            intent.setClass(activity, FileBrowserActivity::class.java)
            activity.startActivityForResult(intent, reqCode)
        }
    }
}