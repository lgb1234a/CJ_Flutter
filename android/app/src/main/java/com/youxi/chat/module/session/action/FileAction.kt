package com.youxi.chat.module.session.action

import android.content.Intent
import com.netease.nim.uikit.business.session.actions.BaseAction
import com.netease.nim.uikit.business.session.constant.RequestCode
import com.netease.nimlib.sdk.msg.MessageBuilder
import com.youxi.chat.R
import com.youxi.chat.module.file.FileBrowserActivity
import java.io.File

/**
 * Created by hzxuwen on 2015/6/11.
 */
class FileAction : BaseAction(R.drawable.message_plus_file_selector, R.string.input_panel_file) {
    /**
     * **********************文件************************
     */
    private fun chooseFile() {
        FileBrowserActivity.startActivityForResult(activity, makeRequestCode(RequestCode.GET_LOCAL_FILE))
    }

    override fun onClick() {
        chooseFile()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent) {
        if (requestCode == RequestCode.GET_LOCAL_FILE) {
            val path = data.getStringExtra(FileBrowserActivity.EXTRA_DATA_PATH)
            val file = File(path)
            val message = MessageBuilder.createFileMessage(account, sessionType, file, file.name)
            sendMessage(message)
        }
    }
}