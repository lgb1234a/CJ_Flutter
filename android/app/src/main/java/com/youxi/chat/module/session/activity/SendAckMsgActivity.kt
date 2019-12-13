package com.youxi.chat.module.session.activity

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.Button
import android.widget.EditText
import com.netease.nim.uikit.api.wrapper.NimToolBarOptions
import com.netease.nim.uikit.common.activity.ToolBarOptions
import com.netease.nim.uikit.common.activity.UI
import com.youxi.chat.R

/**
 * 发送已读回执消息界面
 * Created by winnie on 2018/3/14.
 */
class SendAckMsgActivity : UI() {
    private var sessionId: String? = null
    private var msgEdit: EditText? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.send_ack_msg_layout)
        val options: ToolBarOptions = NimToolBarOptions()
        options.titleId = R.string.send_ack_msg
        options.navigateId = R.drawable.actionbar_dark_back_icon
        setToolBar(R.id.toolbar, options)
        sessionId = intent.getStringExtra(EXTRA_SESSIONID)
        msgEdit = findView(R.id.ack_msg_edit_text)
        val btn = findView<Button>(R.id.send_btn)
        btn.setOnClickListener { sendAckMsg(msgEdit?.getText().toString()) }
    }

    override fun onBackPressed() {
        super.onBackPressed()
        hideInput(this@SendAckMsgActivity, msgEdit)
    }

    private fun sendAckMsg(msg: String) {
        hideInput(this@SendAckMsgActivity, msgEdit)
        val intent = Intent()
        intent.putExtra(EXTRA_CONTENT, msg)
        setResult(Activity.RESULT_OK, intent)
        finish()
    }

    companion object {
        private const val EXTRA_SESSIONID = "session_id"
        const val EXTRA_CONTENT = "extra_content"
        fun startActivity(context: Context, sessionId: String?, requestCode: Int) {
            val intent = Intent()
            intent.putExtra(EXTRA_SESSIONID, sessionId)
            intent.setClass(context, SendAckMsgActivity::class.java)
            (context as Activity).startActivityForResult(intent, requestCode)
        }

        private fun hideInput(context: Context, view: View?) {
            val inputMethodManager = context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
            inputMethodManager.hideSoftInputFromWindow(view!!.windowToken, 0)
        }
    }
}