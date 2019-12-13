package com.youxi.chat.module.download

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.text.TextUtils
import android.view.View
import android.widget.Button
import android.widget.TextView
import com.netease.nim.uikit.common.ToastHelper
import com.netease.nim.uikit.common.activity.UI
import com.netease.nim.uikit.common.ui.dialog.DialogMaker
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.Observer
import com.netease.nimlib.sdk.msg.MsgService
import com.netease.nimlib.sdk.msg.MsgServiceObserve
import com.netease.nimlib.sdk.msg.attachment.FileAttachment
import com.netease.nimlib.sdk.msg.constant.AttachStatusEnum
import com.netease.nimlib.sdk.msg.model.IMMessage
import com.youxi.chat.R

/**
 * Created by hzxuwen on 2016/12/14.
 */
class FileDownloadActivity : UI() {
    private var fileNameText: TextView? = null
    private var fileDownloadBtn: Button? = null
    private var message: IMMessage? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.nim_file_download_activity)
        onParseIntent()
        findViews()
        updateUI()
        registerObservers(true)
    }

    override fun onDestroy() {
        super.onDestroy()
        registerObservers(false)
    }

    private fun onParseIntent() {
        message = intent.getSerializableExtra(INTENT_EXTRA_DATA) as IMMessage
    }

    private fun findViews() {
        fileNameText = findView(R.id.file_name)
        fileDownloadBtn = findView(R.id.download_btn)
        fileDownloadBtn?.setOnClickListener(View.OnClickListener {
            if (isOriginDataHasDownloaded(message)) {
                return@OnClickListener
            }
            downloadFile()
        })
    }

    private fun updateUI() {
        val attachment = message!!.attachment as FileAttachment
        if (attachment != null) {
            fileNameText!!.text = attachment.displayName
        }
        if (isOriginDataHasDownloaded(message)) {
            onDownloadSuccess()
        } else {
            onDownloadFailed()
        }
    }

    private fun isOriginDataHasDownloaded(message: IMMessage?): Boolean {
        return if (!TextUtils.isEmpty((message!!.attachment as FileAttachment).path)) {
            true
        } else false
    }

    private fun downloadFile() {
        DialogMaker.showProgressDialog(this, "loading")
        NIMClient.getService(MsgService::class.java).downloadAttachment(message, false)
    }

    /**
     * ********************************* 下载 ****************************************
     */
    private fun registerObservers(register: Boolean) {
        NIMClient.getService(MsgServiceObserve::class.java).observeMsgStatus(statusObserver, register)
    }

    private val statusObserver = Observer<IMMessage> { msg ->
        if (!msg.isTheSame(message) || isDestroyedCompatible) {
            return@Observer
        }
        if (msg.attachStatus == AttachStatusEnum.transferred && isOriginDataHasDownloaded(msg)) {
            DialogMaker.dismissProgressDialog()
            onDownloadSuccess()
        } else if (msg.attachStatus == AttachStatusEnum.fail) {
            DialogMaker.dismissProgressDialog()
            ToastHelper.showToast(this@FileDownloadActivity, "download failed")
            onDownloadFailed()
        }
    }

    private fun onDownloadSuccess() {
        fileDownloadBtn!!.text = "已下载"
        fileDownloadBtn!!.isEnabled = false
        fileDownloadBtn!!.setBackgroundResource(R.drawable.g_white_btn_pressed)
    }

    private fun onDownloadFailed() {
        fileDownloadBtn!!.text = "下载"
        fileDownloadBtn!!.isEnabled = true
        fileDownloadBtn!!.setBackgroundResource(R.drawable.nim_team_create_btn_selector)
    }

    companion object {
        private const val INTENT_EXTRA_DATA = "INTENT_EXTRA_DATA"
        fun start(context: Context, message: IMMessage?) {
            val intent = Intent()
            intent.putExtra(INTENT_EXTRA_DATA, message)
            intent.setClass(context, FileDownloadActivity::class.java)
            context.startActivity(intent)
        }
    }
}