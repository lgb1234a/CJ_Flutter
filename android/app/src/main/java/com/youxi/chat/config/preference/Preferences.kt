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
        editor.commit()
    }

    private fun getString(key: String): String? {
        return sharedPreferences.getString(key, null)
    }

    val sharedPreferences: SharedPreferences
        get() = NimCache.getContext().getSharedPreferences("Demo", Context.MODE_PRIVATE)
}
