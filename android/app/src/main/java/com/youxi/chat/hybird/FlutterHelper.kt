package com.youxi.chat.hybird

import com.blankj.utilcode.util.ToastUtils
import com.idlefish.flutterboost.FlutterBoostPlugin

object FlutterHelper {
    fun init() {

    }

    fun addEventListener() {
        FlutterBoostPlugin.singleton().addEventListener("showTip", object : FlutterBoostPlugin.EventListener {
            override fun onEvent(name: String?, args: MutableMap<Any?, Any?>?) {
                ToastUtils.showShort("showTip")
            }
        })
    }
}