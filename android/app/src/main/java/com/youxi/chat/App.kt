package com.youxi.chat

import android.content.Context
import android.os.Build
import android.os.Process
import android.text.TextUtils
import android.webkit.WebView
import androidx.multidex.MultiDex
import com.blankj.utilcode.util.LogUtils
import com.blankj.utilcode.util.Utils
import com.idlefish.flutterboost.FlutterBoost
import com.idlefish.flutterboost.interfaces.INativeRouter
import com.netease.nim.uikit.api.NimUIKit
import com.netease.nim.uikit.api.UIKitOptions
import com.netease.nim.uikit.business.contact.core.query.PinYin
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.auth.LoginInfo
import com.netease.nimlib.sdk.mixpush.NIMPushClient
import com.netease.nimlib.sdk.util.NIMUtil
import com.youxi.chat.base.BaseApplication
import com.youxi.chat.config.preference.Preferences
import com.youxi.chat.config.preference.UserPreferences
import com.youxi.chat.event.OnlineStateContentProvider
import com.youxi.chat.hybird.FlutterHelper
import com.youxi.chat.module.avchat.AvchatHelper
import com.youxi.chat.module.contact.ContactHelper
import com.youxi.chat.module.location.NimLocationProvider
import com.youxi.chat.module.login.LoginHelper
import com.youxi.chat.module.rts.RtsHelper
import com.youxi.chat.module.session.SessionHelper
import com.youxi.chat.module.wallet.NimWalletClient
import com.youxi.chat.nim.NimCache
import com.youxi.chat.nim.NimInitManager
import com.youxi.chat.nim.NimSdkOptionConfig
import com.youxi.chat.push.MixPushMessageHandler
import com.youxi.chat.push.PushContentProvider
import com.youxi.chat.util.crash.AppCrashHandler
import io.flutter.embedding.android.FlutterView
import java.util.*


class App : BaseApplication() {

    override fun attachBaseContext(newBase: Context?) {
        super.attachBaseContext(newBase)
        MultiDex.install(this)
    }

    override fun onCreate() {
        super.onCreate()

        Utils.init(this)

        NimCache.setContext(this);

        // 4.6.0 开始，第三方推送配置入口改为 SDKOption#mixPushConfig，旧版配置方式依旧支持。
        NIMClient.init(this, getLoginInfo(), NimSdkOptionConfig.getSDKOptions(this));

        // crash handler
        AppCrashHandler.getInstance(this);

        // 以下逻辑只在主进程初始化时执行
        if (NIMUtil.isMainProcess(this)) {
            // 注册自定义推送消息处理，这个是可选项
            NIMPushClient.registerMixPushMessageHandler(MixPushMessageHandler())
            // 初始化钱包模块，在初始化UIKit模块之前执行
            NimWalletClient.init(this)
            // init pinyin
            PinYin.init(this)
            PinYin.validate()
            // 初始化UIKit模块
            initUIKit()
            // 初始化消息提醒
            NIMClient.toggleNotification(UserPreferences.noticeContentToggle)
            //关闭撤回消息提醒
//            NIMClient.toggleRevokeMessageNotification(false);
            // 云信sdk相关业务初始化
            NimInitManager.getInstance().init(true)
            // 初始化音视频模块
            initAVChatKit()
            // 初始化rts模块
            initRTSKit()

            // 初始化Flutter
            initFlutter()

            LoginHelper.init()
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            WebView.setDataDirectorySuffix(Process.myPid().toString() + "")
        }
    }

    private fun initUIKit() { // 初始化
        NimUIKit.init(this, buildUIKitOptions())
        // 设置地理位置提供者。如果需要发送地理位置消息，该参数必须提供。如果不需要，可以忽略。
        NimUIKit.setLocationProvider(NimLocationProvider())
        // IM会话窗口的定制初始化。
        SessionHelper.init()
        // 聊天室聊天窗口的定制初始化。
//        ChatRoomSessionHelper.init()
        // 通讯录列表定制初始化
        ContactHelper.init()
        // 添加自定义推送文案以及选项，请开发者在各端（Android、IOS、PC、Web）消息发送时保持一致，以免出现通知不一致的情况
        NimUIKit.setCustomPushContentProvider(PushContentProvider())
        NimUIKit.setOnlineStateContentProvider(OnlineStateContentProvider())
    }

    private fun buildUIKitOptions(): UIKitOptions? {
        val options = UIKitOptions()
        // 设置app图片/音频/日志等缓存目录
        options.appCacheDir = NimSdkOptionConfig.getAppCacheDir(this).toString() + "/app"
        return options
    }

    private fun getLoginInfo(): LoginInfo? {
        val account: String? = Preferences.userAccount
        val token: String? = Preferences.userToken
        return if (!TextUtils.isEmpty(account) && !TextUtils.isEmpty(token)) {
            NimCache.setAccount(account!!.toLowerCase(Locale.getDefault()))
            LoginInfo(account, token)
        } else {
            null
        }
    }

    private fun initAVChatKit() {
        AvchatHelper.init()
    }

    private fun initRTSKit() {
        RtsHelper.init()
    }

    private fun initFlutter() {
        // Flutter和Native路由入口
        val router = INativeRouter { context, url, urlParams, requestCode, exts ->
            // requestCode, exts暂时没用到
            Router.open(context!!, url, urlParams)
        }

        // Flutter生命周期回调
        val lifecycleListener = object : FlutterBoost.BoostLifecycleListener {
            override fun onEngineCreated() {
                LogUtils.d("FlutterBoost onEngineCreated")
            }

            override fun onPluginsRegistered() {
                // 内部已经通过反射的方式调用了GeneratedPluginRegistrant.registerWith(mRegistry)
                LogUtils.d("FlutterBoost onPluginsRegistered")
                FlutterHelper.addEventListener()
            }

            override fun onEngineDestroy() {
                LogUtils.d("FlutterBoost onEngineDestroy")
            }

        }

        // FlutterBoost引擎
        val platform = FlutterBoost.ConfigBuilder(this, router)
                .isDebug(true)
                // Activity创建时启动Flutter引擎
                .whenEngineStart(FlutterBoost.ConfigBuilder.ANY_ACTIVITY_CREATED)
                .renderMode(FlutterView.RenderMode.texture)
                .lifecycleListener(lifecycleListener)
                .build()

        FlutterBoost.instance().init(platform)
    }
}