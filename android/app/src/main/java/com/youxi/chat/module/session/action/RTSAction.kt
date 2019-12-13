package com.youxi.chat.module.session.action

import com.netease.nim.rtskit.RTSKit
import com.netease.nim.uikit.business.session.actions.BaseAction
import com.netease.nim.uikit.common.ToastHelper
import com.netease.nim.uikit.common.util.sys.NetworkUtil
import com.youxi.chat.R

/**
 * Created by huangjun on 2015/7/7.
 */
class RTSAction : BaseAction(R.drawable.message_plus_rts_selector, R.string.input_panel_RTS) {
    override fun onClick() {
        if (NetworkUtil.isNetAvailable(activity)) {
            RTSKit.startRTSSession(activity, account)
        } else {
            ToastHelper.showToast(activity, R.string.network_is_not_available)
        }
    }
}