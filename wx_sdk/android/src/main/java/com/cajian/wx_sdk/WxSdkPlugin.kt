package com.cajian.wx_sdk

import android.content.Context
import android.os.Build
import android.util.Log
import android.widget.Toast
import com.blankj.utilcode.util.LogUtils
import com.blankj.utilcode.util.SPUtils
import com.blankj.utilcode.util.ToastUtils
import com.google.gson.GsonBuilder
import com.google.gson.reflect.TypeToken
import com.netease.nim.uikit.api.NimUIKit
import com.netease.nimlib.sdk.NIMSDK
import com.netease.nimlib.sdk.RequestCallback
import com.netease.nimlib.sdk.auth.LoginInfo
import com.tencent.mm.opensdk.modelbase.BaseResp
import com.tencent.mm.opensdk.modelmsg.SendAuth
import com.tencent.mm.opensdk.modelmsg.SendMessageToWX
import com.tencent.mm.opensdk.modelmsg.WXMediaMessage
import com.tencent.mm.opensdk.modelmsg.WXWebpageObject
import com.tencent.mm.opensdk.openapi.IWXAPI
import com.tencent.mm.opensdk.openapi.WXAPIFactory
import com.youxi.chat.base.Config
import com.youxi.chat.base.PopupManager
import com.youxi.chat.base.net.BaseModel
import com.youxi.chat.base.net.CommonApi
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.reactivex.Observer
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers
import java.lang.reflect.InvocationTargetException

/** WxSdkPlugin  */
class WxSdkPlugin private constructor(private val mRegistrar: Registrar) : MethodCallHandler {

    private val mContext: Context
    private val mWxApi: IWXAPI

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        // 适配iOS方法名,iOS中有参数的方法名带有冒号,Android中需要去掉
        val methodName = call.method.replace(":", "")
        if ("getPlatformVersion" == methodName) {
            result.success("Android " + Build.VERSION.RELEASE)
            return
        }
        try {
            val params = if (call.arguments == null) mapOf<Any, Any?>() else call.arguments
            val method = javaClass.getDeclaredMethod(methodName, Map::class.java, MethodChannel.Result::class.java)
            method.isAccessible = true
            method.invoke(this, params, result)
            return
        } catch (e: NoSuchMethodException) {
            e.printStackTrace()
        } catch (e: IllegalAccessException) {
            e.printStackTrace()
        } catch (e: InvocationTargetException) {
            e.printStackTrace()
        } catch (e: Exception) {
            e.printStackTrace()
        }

        ToastUtils.showLong("method ${call.method} notImplemented")
        result.notImplemented()
    }

    /**
     * 微信登录
     */
    private fun wxlogin(params: Map<*, *>, result: MethodChannel.Result) {
        if (mWxApi.isWXAppInstalled) {
            val req = SendAuth.Req()
            req.scope = "snsapi_userinfo"
            req.state = "get_access_token"
            mWxApi.sendReq(req)
        } else {
            Toast.makeText(mContext, "您还没有安装微信,请下载安装", Toast.LENGTH_SHORT).show()
        }
        result.success(null)
    }

    /**
     * 微信分享
     */
    private fun share(params: Map<*, *>, result: MethodChannel.Result) {
        val title = params["title"] as String?
        val content = params["content"] as String
        val url = params["url"] as String
        val type = params["type"] as Int

        val message = WXMediaMessage()
        message.title = title ?: ""
        message.description = content
        message.messageExt = content
        message.messageAction = content

        val ext = WXWebpageObject()
        ext.webpageUrl = url

        message.mediaObject = ext

        val req = SendMessageToWX.Req()
        req.transaction = buildTransaction("text")
        req.message = message
        req.scene = SendMessageToWX.Req.WXSceneSession

        mWxApi.sendReq(req)
    }

    private fun onResp(_resp: BaseResp) {
        if (_resp is SendMessageToWX.Resp) {
            // 分享成功是否的监听
            if (_resp.errCode == 0) {
                // 什么也不做
            }
        } else if (_resp is SendAuth.Resp) {
            // 授权结果监听
            if (_resp.errCode == 0) {
                val resp = _resp
                val accessToken = resp.code
                LogUtils.d("Wechat AccessToken = $accessToken")
                if ("get_access_token_bind" == resp.state) {
                    wxBindCode(accessToken)
                } else { // 拿到TOKEN后去服务端认证下
                    sendLoginAuth(accessToken)
                }
            }
        } else {
            Toast.makeText(mContext, "用户取消或者拒绝了微信授权登录", Toast.LENGTH_SHORT).show()
        }
    }

    private fun onWxLoginResp(model: BaseModel<LoginInfoResp>, code: String) {
        if (model.success()) {
            val loginInfo = LoginInfo(model.data.accid, model.data.token)
            NIMSDK.getAuthService()
                    .login(loginInfo)
                    .setCallback(object : RequestCallback<Any?> {
                        override fun onSuccess(param: Any?) {
                            ToastUtils.showShort("登录成功")
                            stashLoginInfo(model.data.accid, model.data.token)
                        }

                        override fun onFailed(code: Int) {
                            ToastUtils.showShort("登录失败, 错误码=$code")
                        }

                        override fun onException(exception: Throwable?) {
                            ToastUtils.showShort("登录异常, 异常原因=${exception?.message}")
                        }
                    })
        } else if ("1" == model.error) {
            // TODO 绑定手机
        } else if ("8" == model.error) {
            // TODO 账号冻结
        } else {
            ToastUtils.showShort(model.errmsg)
        }
    }

    private fun stashLoginInfo(accid: String, token: String) {
        SPUtils.getInstance().put("flutter.accid", accid)
        SPUtils.getInstance().put("flutter.token", token)
    }

    private fun wxBindCode(code: String) {
        val accid = NimUIKit.getAccount()
        val json = mapOf(
                "accid" to accid,
                "code" to code,
                "union_id" to "",
                "app_key" to APP_ID
        )

        CommonApi.getApi().postJson(Config.wechatBindUrl, json = json)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : Observer<String> {
                    override fun onComplete() {
                        PopupManager.hideLoading(mContext)
                    }

                    override fun onSubscribe(d: Disposable) {
                        PopupManager.showLoading(mContext)
                    }

                    override fun onNext(t: String) {
                        val model = GsonBuilder().setLenient().create().fromJson(t, BaseModel::class.java)
                        if (model.success()) {
                            ToastUtils.showShort("绑定成功")
                        } else {
                            ToastUtils.showShort(model.errmsg)
                        }
                    }

                    override fun onError(e: Throwable) {
                        PopupManager.hideLoading(mContext)
                        ToastUtils.showShort(e.message)
                    }
                })
    }

    private fun sendLoginAuth(accessToken: String) {
        LogUtils.d("sendLoginAuth accessToken = $accessToken")

        val json = mapOf(
                "code" to accessToken,
                "app_key" to APP_ID
        )

        CommonApi.getApi().postJson(Config.wechatLoginUrl, json = json)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : Observer<String> {
                    override fun onComplete() {
                        PopupManager.hideLoading(mContext)
                    }

                    override fun onSubscribe(d: Disposable) {
                        PopupManager.showLoading(mContext, loadingTips = "登录中...")
                    }

                    override fun onNext(t: String) {
                        val model = GsonBuilder().setLenient().create()
                                .fromJson<BaseModel<LoginInfoResp>>(t, object : TypeToken<BaseModel<LoginInfoResp>>() {}.type)
                        onWxLoginResp(model, accessToken)
                    }

                    override fun onError(e: Throwable) {
                        PopupManager.hideLoading(mContext)
                        ToastUtils.showShort(e.message)
                    }
                })
    }

    /**
     * 查询微信绑定状态
     */
    private fun wxBindStatus(params: Map<*, *>, result: MethodChannel.Result) {
        val accid = NimUIKit.getAccount()

        val json = mapOf(
                "accid" to accid,
                "app_key" to APP_ID
        )

        CommonApi.getApi().postJson(Config.wechatStatusUrl, json = json)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : Observer<String> {
                    override fun onComplete() {
                        PopupManager.hideLoading(mContext)
                    }

                    override fun onSubscribe(d: Disposable) {
                        PopupManager.showLoading(mContext)
                    }

                    override fun onNext(t: String) {
                        val model = GsonBuilder().setLenient().create().fromJson(t, BaseModel::class.java)
                        if (model.success()) {
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    }

                    override fun onError(e: Throwable) {
                        PopupManager.hideLoading(mContext)
                        result.success(false)
                    }
                })
    }

    /**
     * 解绑微信
     */
    private fun unBindWeChat(params: Map<*, *>, result: MethodChannel.Result) {
        val accid = NimUIKit.getAccount()

        val json = mapOf(
                "accid" to accid,
                "app_key" to APP_ID
        )

        CommonApi.getApi().postJson(Config.wechatUnbindUrl, json = json)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : Observer<String> {
                    override fun onComplete() {
                        PopupManager.hideLoading(mContext)
                    }

                    override fun onSubscribe(d: Disposable) {
                        PopupManager.showLoading(mContext, loadingTips = "登录中...")
                    }

                    override fun onNext(t: String) {
                        val model = GsonBuilder().setLenient().create().fromJson(t, BaseModel::class.java)
                        if (model.success()) {
                            ToastUtils.showShort("解绑成功")
                        } else {
                            ToastUtils.showShort(model.errmsg)
                        }
                    }

                    override fun onError(e: Throwable) {
                        PopupManager.hideLoading(mContext)
                        ToastUtils.showShort(e.message)
                    }
                })
    }

    private fun buildTransaction(type: String?): String {
        return if (type == null) System.currentTimeMillis().toString() else type + System.currentTimeMillis();
    }

    companion object {
        private const val APP_ID = "wxa590aacb6f7b637b"
        private val TAG = WxSdkPlugin::class.java.simpleName
        /** Plugin registration.  */
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "wx_sdk")
            channel.setMethodCallHandler(WxSdkPlugin(registrar))
            Log.d(TAG, "registerWith")
        }
    }

    init {
        mContext = mRegistrar.context()
        mWxApi = WXAPIFactory.createWXAPI(mContext, APP_ID)
        mWxApi.registerApp(APP_ID)
    }

    data class LoginInfoResp(
            val accid: String,
            val token: String
    )
}