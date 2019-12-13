package com.youxi.chat

import android.content.Context
import android.content.Intent
import android.os.Bundle
import com.blankj.utilcode.util.GsonUtils
import com.blankj.utilcode.util.LogUtils
import com.idlefish.flutterboost.containers.BoostFlutterActivity
import com.youxi.chat.base.BaseActivity
import com.youxi.chat.module.main.activity.WelcomeActivity
import java.io.Serializable
import java.io.UnsupportedEncodingException
import java.net.URLEncoder

class Router : BaseActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        open(this, WelcomeActivity::class.java)
        finish()
    }

    companion object {

        fun open(context: Context, cls: Class<*>, params: MutableMap<String, Any>? = null): Boolean {
            return open(context, "native://AndroidPage=${cls.name}&", params)
        }

        /**
         * Flutter和Native路由入口
         * @param url 跳转协议
         * @param params 携带参数
         * @return 是否成功打开页面
         */
        fun open(context: Context, url: String, params: MutableMap<String, Any>? = null): Boolean {
            LogUtils.d("Router Open Url= ${assembleUrl(url, params)}")

            try {
                if (url.startsWith("native://")) {
                    // url = "native://AndroidPage=com.example.android.MainActivity&iOSPage=MainController"

                    // 打开原生Android页面
                    val activityName = Regex("AndroidPage=(.+?)&").find(url)?.destructured?.component1()
                    val intent = Intent(context, Class.forName(activityName!!))
                            .apply {
                                params?.let {
                                    putExtras(Bundle().apply {
                                        putSerializable("params", params as Serializable)
                                    })
                                }
                            }
                    context.startActivity(intent)
                    return true
                } else {
                    // url = "main"

                    // 打开纯Flutter页面
                    val intent = BoostFlutterActivity.withNewEngine()
                            .url(url)
                            .apply { params?.let { this.params(params) } }
                            .backgroundMode(BoostFlutterActivity.BackgroundMode.opaque)
                            .build(context)
                    context.startActivity(intent)
                    return true
                }
            } catch (e: Exception) {
                e.printStackTrace()
                return false
            }
        }

        /**
         * 组装协议和参数
         */
        private fun assembleUrl(url: String, params: MutableMap<String, Any>?): String {
            val targetUrl = StringBuilder(url)
            params?.let {
                if (!targetUrl.toString().contains("?")) {
                    targetUrl.append("?")
                }

                for ((key, value) in params) {
                    var valueStr = ""
                    if (value is Map<*, *> || value is List<*>) {
                        try {
                            valueStr = URLEncoder.encode(GsonUtils.toJson(value), "UTF-8")
                        } catch (e: UnsupportedEncodingException) {
                            e.printStackTrace()
                        }
                    } else {
                        valueStr = URLEncoder.encode(value.toString(), "UTF-8")
                    }

                    if (targetUrl.toString().endsWith("?")) {
                        targetUrl.append(key).append("=").append(valueStr)
                    } else {
                        targetUrl.append("&").append(key).append("=").append(valueStr)
                    }
                }
            }

            return targetUrl.toString()
        }
    }
}