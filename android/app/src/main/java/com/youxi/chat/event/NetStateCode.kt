package com.youxi.chat.event

enum class NetStateCode(val value: Int) {
    /**
     * 未知
     */
    Unkown(0),
    /**
     * wifi
     */
    Wifi(1),
    /**
     * WWAN
     */
    WWAN(2),
    /**
     * 2G
     */
    _2G(3),
    /**
     * 3G
     */
    _3G(4),
    /**
     * 4G
     */
    _4G(5);

    companion object {
        fun getNetStateCode(value: Int): NetStateCode? {
            return when (value) {
                0 -> Unkown
                1 -> Wifi
                2 -> WWAN
                3 -> _2G
                4 -> _3G
                5 -> _4G
                else -> null
            }
        }
    }

}