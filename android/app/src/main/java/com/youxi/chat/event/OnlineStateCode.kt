package com.youxi.chat.event

enum class OnlineStateCode(val value: Int) {
    /**
     * 在线
     */
    Online(0),
    /**
     * 忙碌
     */
    Busy(1),
    /**
     * 离线
     */
    Offline(2);

    companion object {
        fun getOnlineStateCode(value: Int): OnlineStateCode? {
            return when (value) {
                0 -> Online
                1 -> Busy
                2 -> Offline
                else -> null
            }
        }
    }

}