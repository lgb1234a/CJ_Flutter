package com.youxi.chat.base.net

import android.text.TextUtils
import com.blankj.utilcode.util.EncryptUtils
import com.blankj.utilcode.util.LogUtils
import com.google.gson.GsonBuilder
import com.youxi.chat.base.Config
import me.jessyan.retrofiturlmanager.RetrofitUrlManager
import okhttp3.FormBody
import okhttp3.Interceptor
import okhttp3.OkHttpClient
import okhttp3.Response
import okhttp3.logging.HttpLoggingInterceptor
import okio.Buffer
import org.json.JSONObject
import retrofit2.Retrofit
import retrofit2.adapter.rxjava2.RxJava2CallAdapterFactory
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.converter.scalars.ScalarsConverterFactory
import java.util.*
import java.util.concurrent.TimeUnit


class RetrofitHelper private constructor() {

    private lateinit var retrofit: Retrofit
    private lateinit var okHttpClient: OkHttpClient

    init {
        okHttpClient = RetrofitUrlManager.getInstance()
                .with(OkHttpClient.Builder())
                .connectTimeout(10, TimeUnit.SECONDS)
                .readTimeout(10, TimeUnit.SECONDS)
                .addInterceptor(HttpLoggingInterceptor().apply { level = HttpLoggingInterceptor.Level.BODY })
                .addInterceptor(SignInterceptor())
                .build()

        retrofit = Retrofit.Builder()
                .baseUrl(Config.baseUrl)
                .client(okHttpClient)
                .addCallAdapterFactory(RxJava2CallAdapterFactory.create())
                .addConverterFactory(ScalarsConverterFactory.create())
                .addConverterFactory(GsonConverterFactory.create(GsonBuilder().setLenient().create()))
                .build()
    }

    companion object {

        private var INSTANCE: Retrofit? = null

        fun getRetrofit(): Retrofit {
            if (INSTANCE == null) {
                synchronized(RetrofitHelper::class.java) {
                    if (INSTANCE == null) {
                        INSTANCE = RetrofitHelper().retrofit
                    }
                }
            }
            return INSTANCE!!
        }
    }

    /**
     * 请求接口加签拦截器
     */
    inner class SignInterceptor : Interceptor {
        override fun intercept(chain: Interceptor.Chain): Response {
            // 只拦截擦肩的请求
            if (!shouldIntercept(chain.request().url.toString())) {
                return chain.proceed(chain.request())
            }

            val builder = chain.request().newBuilder()
            if (chain.request().method == "GET") {
                // 处理GET请求参数的加签, 暂时忽略
//                chain.request().url.queryParameterNames
//                builder.addHeader("sign", getSign())

            } else if (chain.request().method == "POST") {
                if (chain.request().body is FormBody) {
                    // 处理POST请求参数为表单类型的加签, 暂时忽略
//                    val body = chain.request().body as FormBody
//                    body.value(body.size)

                } else if (chain.request().body?.contentType().toString().contains("json", ignoreCase = true)) {
                    // 处理POST请求参数为JSON类型的加签
                    val buffer = Buffer()
                    chain.request().body?.writeTo(buffer)
                    val content = buffer.readString(Charsets.UTF_8)
                    builder.addHeader("sign", getSign(content))

                    // TODO 特例情况,上传文件时只对accid加签
                }
            }

            return chain.proceed(builder.build())
        }
    }

    fun shouldIntercept(url: String): Boolean {
        return url.contains(Config.baseUrl)
    }

    fun getSign(param: String): String {
        LogUtils.d("SignContent=$param")
        try {
            if (!TextUtils.isEmpty(param)) {
                val jsonObject = JSONObject(param)
                val iteratorKeys = jsonObject.keys()
                val map: SortedMap<String, String> = TreeMap<String, String>()
                while (iteratorKeys.hasNext()) {
                    val key = iteratorKeys.next().toString()
                    val vlaue = jsonObject.optString(key)
                    if (!TextUtils.isEmpty(vlaue)) {
                        map[key] = vlaue
                    }
                }
                val itemData: LinkedList<*> = LinkedList(map.keys)
                val stringBuilder = StringBuilder()
                for (i in itemData.indices) {
                    val key = itemData[i] as String
                    val value = map[key] as String?
                    val replaceValue = value!!.replace("\\", "")
                    stringBuilder.append(key.toLowerCase(Locale.getDefault()))
                            .append("=")
                            .append(replaceValue)
                            .append("&")
                }
                stringBuilder.append("solt=").append(Config.apiSignSalt)
                val sign: String = EncryptUtils.encryptMD5ToString(stringBuilder.toString())
                        .toLowerCase(Locale.getDefault())
                LogUtils.i(sign)
                return sign
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return ""
    }
}