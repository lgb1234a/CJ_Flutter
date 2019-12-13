package com.youxi.chat.event

import java.util.*

/**
 * Created by hzchenkang on 2017/4/11.
 */
object OnlineStateEventCache {
    private val onlineStateCache: MutableMap<String, OnlineState?> = HashMap<String, OnlineState?>()
    // 管理在线状态订阅账号
    private val subscribeAccounts: MutableSet<String> = HashSet()

    fun getOnlineState(account: String?): OnlineState? {
        return onlineStateCache.get(account)
    }

    fun cacheOnlineState(account: String, state: OnlineState?) {
        onlineStateCache[account] = state
    }

    fun removeOnlineState(accounts: List<String>?) {
        if (accounts != null && !accounts.isEmpty()) {
            for (account in accounts) {
                onlineStateCache.remove(account)
            }
        }
    }

    fun addSubsAccounts(accounts: List<String>?) {
        subscribeAccounts.addAll(accounts!!)
    }

    fun addSubsAccount(accounts: String) {
        subscribeAccounts.add(accounts)
    }

    fun hasSubscribed(account: String?): Boolean {
        return subscribeAccounts.contains(account)
    }

    fun removeSubsAccounts(accounts: List<String>?) {
        subscribeAccounts.removeAll(accounts as Collection<String>)
    }

    val subsAccounts: List<String>
        get() = ArrayList(subscribeAccounts)

    fun resetCache() {
        onlineStateCache.clear()
        subscribeAccounts.clear()
    }

    fun clearSubsAccounts() {
        subscribeAccounts.clear()
    }
}