package com.youxi.chat.push

import com.netease.nim.uikit.api.model.main.CustomPushContentProvider
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum
import com.netease.nimlib.sdk.msg.model.IMMessage
import java.util.*

/**
 * 示例：
 * 1.自定义的推送文案
 * 2.自定义推送 payload 实现特定的点击通知栏跳转行为[MixPushMessageHandler]
 *
 *
 * 如果自定义文案和payload，请开发者在各端发送消息时保持一致。
 */
class PushContentProvider : CustomPushContentProvider {
    override fun getPushContent(message: IMMessage): String? {
        return null
    }

    override fun getPushPayload(message: IMMessage): Map<String, Any> {
        return getPayload(message)!!
    }

    private fun getPayload(message: IMMessage?): Map<String, Any>? {
        if (message == null) {
            return null
        }
        val payload = HashMap<String, Any>()
        payload["sessionType"] = message.sessionType.value
        if (message.sessionType == SessionTypeEnum.Team) {
            payload["sessionID"] = message.sessionId
        } else if (message.sessionType == SessionTypeEnum.P2P) {
            payload["sessionID"] = message.fromAccount
        }
        return payload
    }
}