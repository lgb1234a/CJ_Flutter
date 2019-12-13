package com.youxi.chat.util.crash

import android.content.Context

class AppCrashHandler private constructor(private val context: Context) {
    private var uncaughtExceptionHandler: Thread.UncaughtExceptionHandler
    fun saveException(ex: Throwable, uncaught: Boolean) {
        CrashSaver.save(context, ex, uncaught)
    }

    fun setUncaughtExceptionHandler(handler: Thread.UncaughtExceptionHandler?) {
        if (handler != null) {
            uncaughtExceptionHandler = handler
        }
    }

    companion object {
        private var instance: AppCrashHandler? = null
        fun getInstance(mContext: Context): AppCrashHandler? {
            if (instance == null) {
                instance = AppCrashHandler(mContext)
            }
            return instance
        }
    }

    init {
        // get default
        uncaughtExceptionHandler = Thread.getDefaultUncaughtExceptionHandler()
        // install
        Thread.setDefaultUncaughtExceptionHandler { thread, ex ->
            // save log
            saveException(ex, true)
            // uncaught
            uncaughtExceptionHandler.uncaughtException(thread, ex)
        }
    }
}