package com.youxi.chat

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.text.TextUtils
import com.blankj.utilcode.util.GsonUtils
import com.blankj.utilcode.util.LogUtils
import com.blankj.utilcode.util.ToastUtils
import com.idlefish.flutterboost.containers.BoostFlutterActivity
import com.youxi.chat.base.BaseActivity
import com.youxi.chat.module.main.activity.WelcomeActivity
import com.youxi.chat.module.session.SessionHelper
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

        fun open(context: Context, cls: Class<*>, params: Map<String, Any>? = null): Boolean {
            return open(context, "nativePage://androidPageName=${cls.name}&iOSPageName=MainController", params)
        }

        /**
         * Flutter和Native路由入口
         * @param url 跳转协议
         * @param params 携带参数
         * @return 是否成功打开页面
         */
        fun open(context: Context, url: String, params: Map<String, Any>? = null): Boolean {
            LogUtils.d("Router Open Url= ${assembleUrl(url, params)}")

            try {
                if (TextUtils.isEmpty(url)) {
                    ToastUtils.showShort("打开页面为空")
                    return false
                }
                if (url.startsWith("nativePage://")) {
                    // url = "nativePage://androidPageName=com.example.android.MainActivity&iOSPageName=MainController"

                    // 打开原生Android页面
                    val activityName = Regex("androidPageName=(.+?)&").find(url)?.destructured?.component1()
                    // TODO 一些特殊处理,后期优化掉
                    if (SessionHelper.javaClass.name == activityName) {
                        // 会话窗口
                        val type = params?.get("type") as Int
                        val id = params.get("id") as String
                        if (type == 0) {
                            // 单聊
                            SessionHelper.startP2PSession(context, id)
                        } else if (type == 1) {
                            // 群聊
                            SessionHelper.startTeamSession(context, id)
                        } else {
                            throw RuntimeException("未找到匹配的页面")
                        }
                    } else {
                        // 正常的流程
                        val intent = Intent(context, Class.forName(activityName!!))
                                .apply {
                                    params?.let {
                                        putExtras(Bundle().apply {
                                            putSerializable("params", params as Serializable)
                                        })
                                    }
                                }
                        context.startActivity(intent)
                    }
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
        private fun assembleUrl(url: String, params: Map<String, Any>?): String {
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