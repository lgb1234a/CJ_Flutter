package com.youxi.chat.base.net

import io.reactivex.Observable
import kotlinx.coroutines.Deferred
import retrofit2.http.*

interface CommonApi {

    companion object {
        private var INSTANCE: CommonApi? = null

        fun getApi(): CommonApi {
            if (INSTANCE == null) {
                synchronized(CommonApi::class.java) {
                    if (INSTANCE == null) {
                        INSTANCE = RetrofitHelper.getRetrofit().create(CommonApi::class.java)
                    }
                }
            }
            return INSTANCE!!
        }
    }

    @GET
    fun get(@Url url: String, @QueryMap(encoded = true) queryMap: Map<String, String> = mapOf(),
            @HeaderMap headerMap: Map<String, String> = mapOf()): Observable<String>

    @FormUrlEncoded
    @POST
    fun postForm(@Url url: String, @FieldMap(encoded = true) fieldMap: Map<String, String> = mapOf(),
                 @HeaderMap headerMap: Map<String, String> = mapOf()): Observable<String>

    @POST
    fun postJson(@Url url: String, @Body fieldMap: Map<String, String> = mapOf(),
                 @HeaderMap headerMap: Map<String, String> = mapOf()): Observable<String>

    @GET
    fun getAsync(@Url url: String, @QueryMap(encoded = true) queryMap: Map<String, String> = mapOf(),
                 @HeaderMap headerMap: Map<String, String> = mapOf()): Deferred<String>

    @FormUrlEncoded
    @POST
    fun postAsync(@Url url: String, @FieldMap(encoded = true) fieldMap: Map<String, String> = mapOf(),
                  @HeaderMap headerMap: Map<String, String> = mapOf()): Deferred<String>

    @POST
    fun postJsonAsync(@Url url: String, @Body fieldMap: Map<String, String> = mapOf(),
                  @HeaderMap headerMap: Map<String, String> = mapOf()): Deferred<String>
}