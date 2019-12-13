package com.youxi.chat.base.net

data class BaseModel<T>(
        var errmsg: String,
        var error: String,
        var data: T
) {
    fun success(): Boolean {
        return "0" == error
    }
}