package com.youxi.chat.config.preference

import android.content.Context
import android.content.SharedPreferences
import com.youxi.chat.nim.NimCache


/**
 * Created by hzxuwen on 2015/4/13.
 */
object Preferences {
    private const val KEY_USER_ACCOUNT = "flutter.accid"
    private const val KEY_USER_TOKEN = "flutter.token"
    fun saveUserAccount(account: String) {
        saveString(KEY_USER_ACCOUNT, account)
    }

    val userAccount: String?
        get() = getString(KEY_USER_ACCOUNT)

    fun saveUserToken(token: String) {
        saveString(KEY_USER_TOKEN, token)
    }

    val userToken: String?
        get() = getString(KEY_USER_TOKEN)

    private fun saveString(key: String, value: String) {
        val editor = sharedPreferences.edit()
        editor.putString(key, value)
        editor.apply()
    }

    private fun getString(key: String): String? {
        return sharedPreferences.getString(key, null)
    }

    private val sharedPreferences: SharedPreferences
        // 适配Flutter插件中的sp文件名,保证和Flutter通用
        get() = NimCache.getContext().getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
}
