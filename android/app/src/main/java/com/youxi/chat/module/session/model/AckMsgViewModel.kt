package com.youxi.chat.module.session.model

import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel
import com.netease.nimlib.sdk.msg.model.IMMessage
import com.netease.nimlib.sdk.msg.model.TeamMsgAckInfo

/**
 * Created by winnie on 2018/3/17.
 */
class AckMsgViewModel : ViewModel() {
    var teamMsgAckInfo: LiveData<TeamMsgAckInfo>? = null
        private set
    private var ackModelRepository: AckModelRepository? = null
    fun init(message: IMMessage?) {
        if (teamMsgAckInfo != null) {
            return
        }
        ackModelRepository = AckModelRepository()
        teamMsgAckInfo = ackModelRepository?.getMsgAckInfo(message)
    }

}