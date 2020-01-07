package com.youxi.chat.module.session

import com.netease.nim.uikit.business.recent.RecentContactsCallback

interface RecentSessionCallback : RecentContactsCallback {
    fun ToActivity(code: Int): String?
}