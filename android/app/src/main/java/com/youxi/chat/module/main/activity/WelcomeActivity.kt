package com.youxi.chat.module.main.activity

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.text.TextUtils
import android.util.Log
import com.alibaba.fastjson.JSON
import com.netease.nim.avchatkit.activity.AVChatActivity
import com.netease.nim.avchatkit.constant.AVChatExtras
import com.netease.nim.uikit.api.NimUIKit
import com.netease.nim.uikit.common.activity.UI
import com.netease.nim.uikit.common.util.log.LogUtil
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.NimIntent
import com.netease.nimlib.sdk.mixpush.MixPushService
import com.netease.nimlib.sdk.msg.MessageBuilder
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum
import com.netease.nimlib.sdk.msg.model.IMMessage
import com.youxi.chat.R
import com.youxi.chat.config.preference.Preferences
import com.youxi.chat.module.login.LoginHelper
import com.youxi.chat.module.main.activity.MainActivity.Companion.start
import com.youxi.chat.nim.NimCache
import com.youxi.chat.nim.NimCache.getAccount
import com.youxi.chat.push.MixPushMessageHandler
import com.youxi.chat.util.SysInfoUtil.stackResumed
import java.util.*

class WelcomeActivity : UI() {

    private var customSplash = false

    companion object {
        private val TAG = "WelcomeActivity"
        private var firstEnter = true
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_welcome)

        if (savedInstanceState != null) {
            intent = Intent()
        }

        if (!firstEnter) {
            onIntent()
        } else {
            showSplashView()
        }
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        // 如果Activity在，不会走到onCreate，而是onNewIntent，这时候需要setIntent
        // 场景：点击通知栏跳转到此，会收到Intent
        // 如果Activity在，不会走到onCreate，而是onNewIntent，这时候需要setIntent
        // 场景：点击通知栏跳转到此，会收到Intent
        setIntent(intent)
        if (!customSplash) {
            onIntent()
        }
    }

    override fun onResume() {
        super.onResume()
        if (firstEnter) {
            firstEnter = false
            val runnable = object : Runnable {
                override fun run() {
                    if (!NimUIKit.isInitComplete()) {
                        LogUtil.i(WelcomeActivity.TAG, "wait for uikit cache!")
                        Handler().postDelayed(this, 100)
                        return
                    }

                    customSplash = false
                    if (canAutoLogin()) {
                        onIntent()
                    } else {
                        LoginHelper.gotoLogin(this@WelcomeActivity)
                        finish();
                    }
                }
            }
            if (customSplash) {
                Handler().postDelayed(runnable, 1000)
            } else {
                runnable.run()
            }
        }
    }

    override fun finish() {
        super.finish()
        overridePendingTransition(0, 0)
    }

    override fun onDestroy() {
        super.onDestroy()
        NimCache.mainTaskLaunching = false
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        outState.clear()
    }

    // 处理收到的Intent
    private fun onIntent() {
        LogUtil.i(WelcomeActivity.TAG, "onIntent...")
        if (TextUtils.isEmpty(getAccount())) {
            // 判断当前app是否正在运行
            if (!stackResumed(this)) {
                LoginHelper.gotoLogin(this)
            }
            finish()
        } else {
            // 已经登录过了，处理过来的请求
            val intent = intent
            if (intent != null) {
                if (intent.hasExtra(NimIntent.EXTRA_NOTIFY_CONTENT)) {
                    parseNotifyIntent(intent)
                    return
                } else if (NIMClient.getService(MixPushService::class.java).isFCMIntent(intent)) {
                    parseFCMNotifyIntent(NIMClient.getService(MixPushService::class.java).parseFCMPayload(intent))
                } else if (intent.hasExtra(AVChatExtras.EXTRA_FROM_NOTIFICATION) || intent.hasExtra(AVChatActivity.INTENT_ACTION_AVCHAT)) {
                    parseNormalIntent(intent)
                }
            }
            if (!WelcomeActivity.firstEnter && intent == null) {
                finish()
            } else {
                showMainActivity()
            }
        }
    }

    private fun showSplashView() {
        // 首次进入，打开欢迎界面
        window.setBackgroundDrawableResource(R.drawable.splash_bg)
        customSplash = true
    }

    /**
     * 已经登陆过，自动登陆
     */
    private fun canAutoLogin(): Boolean {
        val account = Preferences.userAccount
        val token = Preferences.userToken
        Log.i(WelcomeActivity.TAG, "get local sdk token =$token")
        return !TextUtils.isEmpty(account) && !TextUtils.isEmpty(token)
    }

    private fun parseNotifyIntent(intent: Intent) {
        val messages = intent.getSerializableExtra(NimIntent.EXTRA_NOTIFY_CONTENT) as ArrayList<IMMessage>?
        if (messages == null || messages.size > 1) {
            showMainActivity(null)
        } else {
            showMainActivity(Intent().putExtra(NimIntent.EXTRA_NOTIFY_CONTENT, messages[0]))
        }
    }

    private fun parseFCMNotifyIntent(payloadString: String) {
        val payload: Map<String, String> = JSON.parseObject(payloadString, Map::class.java) as Map<String, String>
        val sessionId = payload[MixPushMessageHandler.PAYLOAD_SESSION_ID]
        val type = payload[MixPushMessageHandler.PAYLOAD_SESSION_TYPE]
        if (sessionId != null && type != null) {
            val typeValue = Integer.valueOf(type)
            val message = MessageBuilder.createEmptyMessage(sessionId,
                    SessionTypeEnum.typeOfValue(typeValue), 0)
            showMainActivity(Intent().putExtra(NimIntent.EXTRA_NOTIFY_CONTENT, message))
        } else {
            showMainActivity(null)
        }
    }

    private fun parseNormalIntent(intent: Intent) {
        showMainActivity(intent)
    }

    private fun showMainActivity() {
        showMainActivity(null)
    }

    private fun showMainActivity(intent: Intent?) {
        start(this@WelcomeActivity, intent)
        finish()
    }
}