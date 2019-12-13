package com.youxi.chat.module.session

/**
 * Created by huangjun on 2015/8/20.
 */
class SystemMessageUnreadManager {
    @set:Synchronized
    var sysMsgUnreadCount = 0

    companion object {
        val instance = SystemMessageUnreadManager()
    }
}