package com.youxi.chat.base

object Config {
    val baseUrl = "https://api.youxi2018.cn"
    /** 微信绑定 */
    val wechatBindUrl = "$baseUrl/g2/user/wx/bind"
    /** 微信登录 */
    val wechatLoginUrl = "$baseUrl/g2/login/wx/new"
}