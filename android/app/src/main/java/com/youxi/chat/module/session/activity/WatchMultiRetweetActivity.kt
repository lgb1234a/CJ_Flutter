package com.youxi.chat.module.session.activity

import android.app.Activity
import android.app.AlertDialog
import android.content.DialogInterface
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.HandlerThread
import android.text.TextUtils
import android.view.View
import android.widget.ImageButton
import android.widget.TextView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.netease.nim.uikit.api.NimUIKit
import com.netease.nim.uikit.business.contact.selector.activity.ContactSelectActivity
import com.netease.nim.uikit.business.session.constant.Extras
import com.netease.nim.uikit.business.session.module.list.MessageListPanelEx
import com.netease.nim.uikit.common.ToastHelper
import com.netease.nim.uikit.common.activity.UI
import com.netease.nim.uikit.common.ui.dialog.CustomAlertDialog
import com.netease.nim.uikit.common.util.log.sdk.wrapper.NimLog
import com.netease.nim.uikit.common.util.string.MD5
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.RequestCallback
import com.netease.nimlib.sdk.ResponseCode
import com.netease.nimlib.sdk.msg.MessageBuilder
import com.netease.nimlib.sdk.msg.constant.MsgDirectionEnum
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum
import com.netease.nimlib.sdk.msg.model.IMMessage
import com.netease.nimlib.sdk.nos.NosService
import com.youxi.chat.R
import com.youxi.chat.module.session.MessageHelper.decryptByRC4
import com.youxi.chat.module.session.adapter.MultiRetweetAdapter
import com.youxi.chat.module.session.extension.MultiRetweetAttachment
import org.json.JSONException
import org.json.JSONObject
import java.io.IOException
import java.io.InputStream
import java.net.HttpURLConnection
import java.net.URL
import java.util.*

class WatchMultiRetweetActivity : UI() {
    /** 合并消息对象  */
    private var mMessage: IMMessage? = null
    /** 被合并的消息组成的列表  */
    private var mItems: MutableList<IMMessage>? = null
    /** 是否可以转发消息  */
    private var mCanForward = false
    /** 展示消息的列表  */
    private var mMsgListRV: RecyclerView? = null
    /** 转发按钮  */
    private var mForwardTV: TextView? = null
    /** 返回按钮  */
    private var mBackBtn: ImageButton? = null
    /** 标题，展示合并消息的来源会话  */
    private var mSessionNameTV: TextView? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.nim_watch_multi_retweet_activity)
        onParseIntent()
        findViews()
        queryFileBackground(object : QueryFileCallbackImp() {
            override fun onFinished(attachment: MultiRetweetAttachment?) {
                runOnUiThread {
                    setTitle(attachment)
                    setList()
                }
            }
        })
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            MessageListPanelEx.REQUEST_CODE_FORWARD_PERSON, MessageListPanelEx.REQUEST_CODE_FORWARD_TEAM -> onSelectSessionResult(requestCode, resultCode, data)
            else -> {
            }
        }
    }

    /**
     * 选择转发目标结束的回调
     */
    private fun onSelectSessionResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (resultCode != Activity.RESULT_OK || data == null) {
            return
        }
        val dialogBuilder = AlertDialog.Builder(this)
        dialogBuilder.setTitle(R.string.confirm_forwarded)
                .setMessage(getString(R.string.confirm_forwarded_to) + data.getStringArrayListExtra(Extras.RESULT_NAME)[0] + "?")
                .setPositiveButton(getString(R.string.ok), object : DialogInterface.OnClickListener {
                    private fun sendMsg(sessionType: SessionTypeEnum, packedMsg: IMMessage?) {
                        data.putExtra(Extras.EXTRA_DATA, packedMsg)
                        data.putExtra(Extras.EXTRA_TYPE, sessionType.value)
                        setResult(Activity.RESULT_OK, data)
                        finish()
                    }

                    override fun onClick(dialog: DialogInterface, which: Int) {
                        val type: SessionTypeEnum
                        type = when (requestCode) {
                            MessageListPanelEx.REQUEST_CODE_FORWARD_PERSON -> SessionTypeEnum.P2P
                            MessageListPanelEx.REQUEST_CODE_FORWARD_TEAM -> SessionTypeEnum.Team
                            else -> return
                        }
                        sendMsg(type, mMessage)
                    }
                })
                .setNegativeButton(getString(R.string.cancel)) { dialog: DialogInterface?, which: Int ->
                    setResult(Activity.RESULT_CANCELED)
                    finish()
                }
                .setOnCancelListener { dialog: DialogInterface? ->
                    setResult(Activity.RESULT_CANCELED)
                    finish()
                }
        dialogBuilder.create().show()
    }

    /**
     * 在标题处写上会话名称
     */
    private fun setTitle(attachment: MultiRetweetAttachment?) {
        val sessionName = attachment?.sessionName
        mSessionNameTV!!.text = sessionName ?: ""
    }

    private fun setList() {
        mMsgListRV!!.layoutManager = LinearLayoutManager(applicationContext, RecyclerView.VERTICAL, false)
        val adapter = MultiRetweetAdapter(mMsgListRV!!, mItems!!, this)
        mMsgListRV!!.adapter = adapter
        adapter.notifyDataSetChanged()
    }

    private fun onParseIntent() {
        mMessage = intent.getSerializableExtra(INTENT_EXTRA_DATA) as IMMessage
        mCanForward = intent.getBooleanExtra(Extras.EXTRA_FORWARD, false)
    }

    private fun findViews() {
        mMsgListRV = findViewById(R.id.rv_msg_history)
        mForwardTV = findViewById(R.id.tv_forward)
        mForwardTV?.setOnClickListener(View.OnClickListener { v: View? -> showTransFormTypeDialog() })
        mForwardTV?.setVisibility(if (mCanForward) View.VISIBLE else View.INVISIBLE)
        mBackBtn = findViewById(R.id.ib_back)
        mBackBtn?.setOnClickListener(View.OnClickListener { v: View? -> finish() })
        mSessionNameTV = findViewById(R.id.tv_session_name)
    }

    /**
     * 展示选择转发类型的会话框
     */
    private fun showTransFormTypeDialog() {
        val alertDialog = CustomAlertDialog(this)
        alertDialog.setCancelable(true)
        alertDialog.setCanceledOnTouchOutside(true)
        addForwardToPersonItem(alertDialog)
        addForwardToTeamItem(alertDialog)
        alertDialog.show()
    }

    /**
     * 添加转发到个人的项
     *
     * @param alertDialog 所在会话框
     */
    private fun addForwardToPersonItem(alertDialog: CustomAlertDialog) {
        alertDialog.addItem(getString(R.string.forward_to_person)) {
            val option = ContactSelectActivity.Option()
            option.title = "个人"
            option.type = ContactSelectActivity.ContactSelectType.BUDDY
            option.multi = false
            option.maxSelectNum = 1
            NimUIKit.startContactSelector(this@WatchMultiRetweetActivity, option, MessageListPanelEx.REQUEST_CODE_FORWARD_PERSON)
        }
    }

    /**
     * 添加转发到群组的项
     *
     * @param alertDialog 所在会话框
     */
    private fun addForwardToTeamItem(alertDialog: CustomAlertDialog) {
        alertDialog.addItem(getString(R.string.forward_to_team)) {
            val option = ContactSelectActivity.Option()
            option.title = "群组"
            option.type = ContactSelectActivity.ContactSelectType.TEAM
            option.multi = false
            option.maxSelectNum = 1
            NimUIKit.startContactSelector(this@WatchMultiRetweetActivity, option, MessageListPanelEx.REQUEST_CODE_FORWARD_TEAM)
        }
    }

    /**
     * 异步获取与解析Nos上存储的附件
     *
     * @param callback 进度回调
     */
    private fun queryFileBackground(callback: IQueryFileCallback) {
        if (mMessage == null || mMessage!!.attachment !is MultiRetweetAttachment) {
            return
        }
        val attachment = mMessage!!.attachment as MultiRetweetAttachment
        //短链换长链
        NIMClient.getService(NosService::class.java).getOriginUrlFromShortUrl(attachment.url).setCallback(object : RequestCallback<String?> {
            override fun onSuccess(param: String?) {
                if (TextUtils.isEmpty(param)) {
                    return
                }
                attachment.url = param
                val thread = HandlerThread(QUERY_FILE_THREAD_NAME)
                thread.start()
                val backgroundHandler = Handler(thread.looper)
                backgroundHandler.post {
                    try {
                        val connection = URL(attachment.url).openConnection() as HttpURLConnection
                        connection.requestMethod = "GET"
                        connection.readTimeout = DEFAULT_TIMEOUT
                        connection.connectTimeout = DEFAULT_TIMEOUT
                        connection.useCaches = false
                        connection.doInput = true
                        callback.onProgress(0)
                        //开始下载
                        val resCode = connection.responseCode
                        if (resCode != ResponseCode.RES_SUCCESS.toInt()) {
                            runOnUiThread {
                                backgroundHandler.looper.quit()
                                callback.onFailed("download failed, code=$resCode")
                            }
                            return@post
                        }
                        //读取文件内容
                        val inputStream = connection.inputStream
                        var src: ByteArray? = readFromInputStream(inputStream)
                        callback.onProgress(35)
                        //检验MD5
                        val fileMd5 = MD5.getMD5(src).toUpperCase()
                        val recordedMd5 = attachment.md5!!.toUpperCase()
                        if (fileMd5 != recordedMd5) {
                            callback.onProgress(40)
                            NimLog.d(TAG, "MD5 check failed, fileMD5=$fileMd5; record = $recordedMd5")
                            //                    callback.onFailed("MD5 check failed, fileMD5=" + fileMd5 + "; record = " + recordedMd5);
//                    return;
                        }
                        callback.onProgress(40)
                        //解密
                        if (attachment.isEncrypted) {
                            val key = attachment.password!!.toByteArray()
                            src = decryptByRC4(src, key)
                            callback.onProgress(45)
                        }
                        if (attachment.isCompressed) {
                            callback.onProgress(50)
                        }
                        //解码
                        val blocks = String(src!!).split("\n").toTypedArray()
                        val count = getMsgCount(blocks[0])
                        mItems = ArrayList(count)
                        for (i in 1..count) {
                            val lineMsg = getMessage(blocks[i]) ?: continue
                            val msg = getMessage(blocks[i])
                            val progressUnit = 40 / count.toDouble()
                            if (msg == null) {
                                continue
                            }
                            msg.direct = MsgDirectionEnum.In
                            mItems?.add(msg)
                            callback.onProgress(50 + (progressUnit * i).toInt())
                        }
                        callback.onProgress(100)
                        runOnUiThread {
                            backgroundHandler.looper.quit()
                            callback.onFinished(attachment)
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                        runOnUiThread {
                            backgroundHandler.looper.quit()
                            callback.onException(e)
                        }
                    }
                }
            }

            override fun onFailed(code: Int) {
                callback.onFailed("failed to get origin url from short url, code=$code")
            }

            override fun onException(exception: Throwable) {
                callback.onException(exception)
            }
        })
    }

    @Throws(IOException::class)
    private fun readFromInputStream(inputStream: InputStream): ByteArray {
        val fileByteList = LinkedList<Byte>()
        var newByte: Int
        while (inputStream.read().also { newByte = it } != -1) {
            fileByteList.add(newByte.toByte())
        }
        val fileBytes = ByteArray(fileByteList.size)
        var index = 0
        for (b in fileByteList) {
            fileBytes[index++] = b
        }
        return fileBytes
    }

    private fun getMsgCount(firstLine: String): Int {
        return try {
            val `object` = JSONObject(firstLine)
            `object`.getInt("message_count")
        } catch (e: JSONException) {
            e.printStackTrace()
            0
        }
    }

    private fun getMessage(line: String): IMMessage {
        return MessageBuilder.createFromJson(line)
    }

    internal interface IQueryFileCallback {
        /**
         * 读取文件进度回调
         *
         * @param percent 进度百分比
         */
        fun onProgress(percent: Int)

        /**
         * 完成加载
         */
        fun onFinished(attachment: MultiRetweetAttachment?)

        /**
         * 加载失败
         *
         * @param msg 错误信息
         */
        fun onFailed(msg: String)

        /**
         * 加载中出现异常
         *
         * @param e 异常
         */
        fun onException(e: Throwable)
    }

    internal inner open class QueryFileCallbackImp : IQueryFileCallback {
        override fun onProgress(percent: Int) {
            NimLog.d(TAG, "query file on progress: $percent%")
            runOnUiThread { ToastHelper.showToast(this@WatchMultiRetweetActivity, "$percent%") }
        }

        override fun onFinished(attachment: MultiRetweetAttachment?) {
            NimLog.d(TAG, "query file finished, attachment=" + (attachment?.toJson(false)
                    ?: null.toString()))
        }

        override fun onFailed(msg: String) {
            val briefMsg = "query file failed"
            NimLog.d(TAG, "$briefMsg, msg=$msg")
            runOnUiThread { ToastHelper.showToast(this@WatchMultiRetweetActivity, briefMsg) }
        }

        override fun onException(e: Throwable) {
            val briefMsg = "query file failed"
            NimLog.d(TAG, briefMsg + ", msg=" + e.message)
            runOnUiThread { ToastHelper.showToast(this@WatchMultiRetweetActivity, briefMsg) }
        }
    }

    companion object {
        private const val TAG = "WatchMultiRetweetActivity"
        private const val QUERY_FILE_THREAD_NAME = "$TAG/queryFile"
        private const val DEFAULT_TIMEOUT = 3000
        /** 接收消息  */
        private const val INTENT_EXTRA_DATA = Extras.EXTRA_DATA

        /**
         * 可以再次转发的打开方式
         *
         * @param reqCode  请求码
         * @param activity 触发Activity
         * @param message  聊天记录
         */
        fun startForResult(reqCode: Int, activity: Activity, message: IMMessage?) {
            val intent = Intent()
            intent.putExtra(INTENT_EXTRA_DATA, message)
            intent.putExtra(Extras.EXTRA_FORWARD, true)
            intent.setClass(activity, WatchMultiRetweetActivity::class.java)
            intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            activity.startActivityForResult(intent, reqCode)
        }

        /**
         * 不再次转发消息的打开方式
         *
         * @param activity 触发Activity
         * @param message  聊天记录
         */
        fun start(activity: Activity, message: IMMessage?) {
            val intent = Intent()
            intent.putExtra(INTENT_EXTRA_DATA, message)
            intent.putExtra(Extras.EXTRA_FORWARD, false)
            intent.setClass(activity, WatchMultiRetweetActivity::class.java)
            activity.startActivity(intent)
        }
    }
}