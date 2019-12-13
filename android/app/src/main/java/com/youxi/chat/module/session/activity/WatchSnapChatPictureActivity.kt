package com.youxi.chat.module.session.activity

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.text.TextUtils
import android.view.View
import android.view.WindowManager
import com.netease.nim.uikit.common.ToastHelper
import com.netease.nim.uikit.common.activity.UI
import com.netease.nim.uikit.common.ui.dialog.CustomAlertDialog
import com.netease.nim.uikit.common.ui.imageview.BaseZoomableImageView
import com.netease.nim.uikit.common.util.media.BitmapDecoder
import com.netease.nim.uikit.common.util.media.ImageUtil
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.Observer
import com.netease.nimlib.sdk.msg.MsgService
import com.netease.nimlib.sdk.msg.MsgServiceObserve
import com.netease.nimlib.sdk.msg.constant.AttachStatusEnum
import com.netease.nimlib.sdk.msg.model.IMMessage
import com.youxi.chat.R
import com.youxi.chat.module.session.extension.SnapChatAttachment

/**
 * 查看阅后即焚消息原图
 */
class WatchSnapChatPictureActivity : UI() {
    private var mHandler: Handler? = null
    private var message: IMMessage? = null
    private var loadingLayout: View? = null
    private var image: BaseZoomableImageView? = null
    protected var alertDialog: CustomAlertDialog? = null
    public override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.nim_watch_snapchat_activity)
        window.setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN)
        onParseIntent()
        findViews()
        mHandler = Handler()
        registerObservers(true)
        requestOriImage()
        instance = this
    }

    override fun onDestroy() {
        registerObservers(false)
        super.onDestroy()
        instance = null
    }

    private fun onParseIntent() {
        message = intent.getSerializableExtra(INTENT_EXTRA_IMAGE) as IMMessage
    }

    private fun findViews() {
        alertDialog = CustomAlertDialog(this)
        loadingLayout = findViewById(R.id.loading_layout)
        image = findViewById<View>(R.id.watch_image_view) as BaseZoomableImageView
    }

    private fun requestOriImage() {
        if (isOriginImageHasDownloaded(message)) {
            onDownloadSuccess(message)
            return
        }
        // async download original image
        onDownloadStart(message)
        NIMClient.getService(MsgService::class.java).downloadAttachment(message, false)
    }

    private fun isOriginImageHasDownloaded(message: IMMessage?): Boolean {
        return if (message!!.attachStatus == AttachStatusEnum.transferred &&
                !TextUtils.isEmpty((message.attachment as SnapChatAttachment).getPath())) {
            true
        } else false
    }

    /**
     * ******************************** 设置图片 *********************************
     */
    private fun setThumbnail() {
        val path: String = (message!!.attachment as SnapChatAttachment).getThumbPath()
        if (!TextUtils.isEmpty(path)) {
            var bitmap = BitmapDecoder.decodeSampledForDisplay(path)
            bitmap = ImageUtil.rotateBitmapInNeeded(path, bitmap)
            if (bitmap != null) {
                image!!.imageBitmap = bitmap
                return
            }
        }
        image!!.imageBitmap = ImageUtil.getBitmapFromDrawableRes(imageResOnLoading)
    }

    private fun setImageView(msg: IMMessage?) {
        val path: String = (msg!!.attachment as SnapChatAttachment).getPath()
        if (TextUtils.isEmpty(path)) {
            image!!.imageBitmap = ImageUtil.getBitmapFromDrawableRes(imageResOnLoading)
            return
        }
        var bitmap = BitmapDecoder.decodeSampledForDisplay(path, false)
        bitmap = ImageUtil.rotateBitmapInNeeded(path, bitmap)
        if (bitmap == null) {
            ToastHelper.showToast(this, R.string.picker_image_error)
            image!!.imageBitmap = ImageUtil.getBitmapFromDrawableRes(imageResOnFailed)
        } else {
            image!!.imageBitmap = bitmap
        }
    }

    private val imageResOnLoading: Int
        private get() = R.drawable.nim_image_default

    private val imageResOnFailed: Int
        private get() = R.drawable.nim_image_download_failed

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
        if (msg.attachStatus == AttachStatusEnum.transferred && isOriginImageHasDownloaded(msg)) {
            onDownloadSuccess(msg)
        } else if (msg.attachStatus == AttachStatusEnum.fail) {
            onDownloadFailed()
        }
    }

    private fun onDownloadStart(msg: IMMessage?) {
        setThumbnail()
        if (TextUtils.isEmpty((msg!!.attachment as SnapChatAttachment).getPath())) {
            loadingLayout!!.visibility = View.VISIBLE
        } else {
            loadingLayout!!.visibility = View.GONE
        }
    }

    private fun onDownloadSuccess(msg: IMMessage?) {
        loadingLayout!!.visibility = View.GONE
        handler!!.post { setImageView(msg) }
    }

    private fun onDownloadFailed() {
        loadingLayout!!.visibility = View.GONE
        image!!.imageBitmap = ImageUtil.getBitmapFromDrawableRes(imageResOnFailed)
        ToastHelper.showToast(this, R.string.download_picture_fail)
    }

    companion object {
        private const val INTENT_EXTRA_IMAGE = "INTENT_EXTRA_IMAGE"
        private var instance: WatchSnapChatPictureActivity? = null
        fun start(context: Context, message: IMMessage?) {
            val intent = Intent()
            intent.putExtra(INTENT_EXTRA_IMAGE, message)
            intent.setClass(context, WatchSnapChatPictureActivity::class.java)
            context.startActivity(intent)
        }

        fun destroy() {
            if (instance != null) {
                instance!!.finish()
                instance = null
            }
        }
    }
}