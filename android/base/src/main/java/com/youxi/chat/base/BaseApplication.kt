package com.youxi.chat.base

import android.app.Application
import com.blankj.utilcode.util.LogUtils

abstract class BaseApplication : Application() {

    override fun onCreate() {
        super.onCreate()
        LogUtils.d("Application onCreate")
    }

}