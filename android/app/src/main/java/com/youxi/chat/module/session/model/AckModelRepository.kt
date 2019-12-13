package com.youxi.chat.module.session.model

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.netease.nimlib.sdk.NIMSDK
import com.netease.nimlib.sdk.RequestCallback
import com.netease.nimlib.sdk.msg.model.IMMessage
import com.netease.nimlib.sdk.msg.model.TeamMsgAckInfo

/**
 * Created by winnie on 2018/3/17.
 */
class AckModelRepository {
    fun getMsgAckInfo(message: IMMessage?): LiveData<TeamMsgAckInfo> {
        val teamMsgAckInfoLiveData = MutableLiveData<TeamMsgAckInfo>()
        NIMSDK.getTeamService().fetchTeamMessageReceiptDetail(message).setCallback(object : RequestCallback<TeamMsgAckInfo> {
            override fun onSuccess(param: TeamMsgAckInfo) {
                teamMsgAckInfoLiveData.setValue(param)
            }

            override fun onFailed(code: Int) {}
            override fun onException(exception: Throwable) {}
        })
        return teamMsgAckInfoLiveData
    }
}