package com.youxi.chat.base

object Config {
    val apiSignSalt = "74d6de00551d4db6a2a3e4484ba101ae"
    val baseUrl = "https://api.youxi2018.cn"
    /** 微信绑定 */
    val wechatBindUrl = "$baseUrl/g2/user/wx/bind"
    /** 微信登录 */
    val wechatLoginUrl = "$baseUrl/g2/login/wx/new"
    /** 微信绑定状态 */
    val wechatStatusUrl = "$baseUrl/g2/user/wx/bind/exist"
    /** 微信解绑 */
    val wechatUnbindUrl = "$baseUrl/g2/user/wx/untying"
}