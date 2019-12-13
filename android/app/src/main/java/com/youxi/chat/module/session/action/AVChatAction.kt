package com.youxi.chat.module.session.action

import com.netease.nim.avchatkit.AVChatKit
import com.netease.nim.avchatkit.activity.AVChatActivity
import com.netease.nim.uikit.business.session.actions.BaseAction
import com.netease.nim.uikit.business.uinfo.UserInfoHelper
import com.netease.nim.uikit.common.ToastHelper
import com.netease.nim.uikit.common.util.sys.NetworkUtil
import com.netease.nimlib.sdk.avchat.constant.AVChatType
import com.youxi.chat.R

/**
 * Created by hzxuwen on 2015/6/12.
 */
open class AVChatAction(avChatType: AVChatType) : BaseAction(if (avChatType === AVChatType.AUDIO) R.drawable.message_plus_audio_chat_selector else R.drawable.message_plus_video_chat_selector,
        if (avChatType === AVChatType.AUDIO) R.string.input_panel_audio_call else R.string.input_panel_video_call) {
    private val avChatType: AVChatType
    override fun onClick() {
        if (NetworkUtil.isNetAvailable(activity)) {
            startAudioVideoCall(avChatType)
        } else {
            ToastHelper.showToast(activity, R.string.network_is_not_available)
        }
    }

    /************************ 音视频通话  */
    open fun startAudioVideoCall(avChatType: AVChatType) {
        AVChatKit.outgoingCall(activity, account, UserInfoHelper.getUserDisplayName(account), avChatType.getValue(), AVChatActivity.FROM_INTERNAL)
    }

    init {
        this.avChatType = avChatType
    }
}