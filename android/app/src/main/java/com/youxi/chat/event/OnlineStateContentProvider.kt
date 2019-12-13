package com.youxi.chat.event

import android.text.TextUtils
import com.netease.nim.uikit.api.model.main.OnlineStateContentProvider
import com.youxi.chat.nim.NimCache

/**
 * Created by hzchenkang on 2017/3/31.
 */
class OnlineStateContentProvider : OnlineStateContentProvider {
    override fun getSimpleDisplay(account: String): String {
        var content = getDisplayContent(account, true)
        if (!TextUtils.isEmpty(content)) {
            content = "[$content]"
        }
        return content
    }

    override fun getDetailDisplay(account: String): String {
        return getDisplayContent(account, false)
    }

    private fun getDisplayContent(account: String?, simple: Boolean): String {
        if (account == null || account == NimCache.getAccount()) {
            return ""
        }
        // 被过滤掉的直接显示在线，如机器人
        if (OnlineStateEventSubscribe.subscribeFilter(account)) {
            return "在线"
        }
        // 检查是否订阅过
        OnlineStateEventManager.checkSubscribe(account)
        val onlineState: OnlineState? = OnlineStateEventCache.getOnlineState(account)
        return OnlineStateEventManager.getOnlineClientContent(NimCache.getContext(), onlineState, simple)!!
    }
}