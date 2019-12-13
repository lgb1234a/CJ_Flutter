package com.youxi.chat.base

import android.content.Context
import com.lxj.xpopup.XPopup
import com.lxj.xpopup.core.BasePopupView

/**
 * 弹窗管理器
 */
object PopupManager {

    private var loadingPopup: BasePopupView? = null

    fun showLoading(context: Context?, loadingTips: String = "正在加载中") {
        if (context == null) {
            return
        }
        if (loadingPopup == null) {
            loadingPopup = XPopup.Builder(context).asLoading(loadingTips)
        }
        if (loadingPopup!!.isDismiss) {
            loadingPopup!!.show()
        }
    }

    fun hideLoading(context: Context?) {
        if (loadingPopup != null) {
            if (loadingPopup!!.isShow) {
                loadingPopup!!.dismiss()
            }
            loadingPopup = null
        }
    }
}