package com.youxi.chat.event

/**
 * 在线状态
 */
class OnlineState {
    /**
     * 获取在线客户端类型
     *
     * @return onlineClient
     */
    /**
     * 客户端类型，参照 [com.netease.nimlib.sdk.auth.ClientType]
     */
    var onlineClient: Int
        private set
    /**
     * 网络状态，WIFI,4G,3G,2G
     */
    private var netState: NetStateCode?
    /**
     * 在线状态，0 在线  1 忙碌  2 离开
     */
    private var onlineState: OnlineStateCode?

    constructor(onlineClient: Int, netState: Int, onlineState: Int) {
        this.onlineClient = onlineClient
        this.netState = NetStateCode.getNetStateCode(netState)
        this.onlineState = OnlineStateCode.getOnlineStateCode(onlineState)
    }

    constructor(onlineClient: Int, netState: NetStateCode?, onlineState: OnlineStateCode?) {
        this.onlineClient = onlineClient
        this.netState = netState
        this.onlineState = onlineState
    }

    /**
     * 获取在线状态
     *
     * @return onlineState
     */
    fun getOnlineState(): OnlineStateCode? {
        return onlineState
    }

    /**
     * 获取网络状态
     *
     * @return netState
     */
    fun getNetState(): NetStateCode? {
        return netState
    }
}