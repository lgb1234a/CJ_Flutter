package com.youxi.chat.event

import android.text.TextUtils
import org.json.JSONException
import org.json.JSONObject

/**
 * 在线状态事件扩展字段 config 格式
 */
object OnlineStateEventConfig {
    // 多端在线状态配置解析
    const val KEY_NET_STATE = "net_state"
    const val KEY_ONLINE_STATE = "online_state" //0 在线  1忙碌  2离开";
    fun buildConfig(netState: Int, onlineState: Int): String {
        val json = JSONObject()
        try {
            json.put(KEY_NET_STATE, netState)
            json.put(KEY_ONLINE_STATE, onlineState)
        } catch (e: JSONException) {
            e.printStackTrace()
        }
        return json.toString()
    }

    fun parseConfig(config: String?, clientType: Int): OnlineState? {
        if (TextUtils.isEmpty(config)) {
            return null
        }
        var state: OnlineState? = null
        try {
            val json = JSONObject(config)
            val netState = json.getInt(KEY_NET_STATE)
            val onlineState = json.getInt(KEY_ONLINE_STATE)
            state = OnlineState(clientType, netState, onlineState)
        } catch (e: JSONException) {
            e.printStackTrace()
        }
        return state
    }
}