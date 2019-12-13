package com.youxi.chat.util

import android.app.ActivityManager
import android.content.Context
import android.os.Build
import android.os.PowerManager

object SysInfoUtil {
    val osInfo: String
        get() = Build.VERSION.RELEASE

    val phoneModelWithManufacturer: String
        get() = Build.MANUFACTURER + " " + Build.MODEL

    val phoneMode: String
        get() = Build.MODEL

    fun isAppOnForeground(context: Context): Boolean {
        val manager = context
                .applicationContext.getSystemService(
                Context.ACTIVITY_SERVICE) as ActivityManager
        val packageName = context.applicationContext.packageName
        val list = manager
                .runningAppProcesses ?: return false
        var ret = false
        val it: Iterator<ActivityManager.RunningAppProcessInfo> = list.iterator()
        while (it.hasNext()) {
            val appInfo = it.next()
            if (appInfo.processName == packageName && appInfo.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND) {
                ret = true
                break
            }
        }
        return ret
    }

    fun isScreenOn(context: Context): Boolean {
        val powerManager = context
                .getSystemService(Context.POWER_SERVICE) as PowerManager
        return powerManager.isScreenOn
    }

    fun stackResumed(context: Context): Boolean {
        val manager = context
                .applicationContext.getSystemService(
                Context.ACTIVITY_SERVICE) as ActivityManager
        val packageName = context.applicationContext.packageName
        val recentTaskInfos = manager.getRunningTasks(1)
        if (recentTaskInfos != null && recentTaskInfos.size > 0) {
            val taskInfo = recentTaskInfos[0]
            if (taskInfo.baseActivity.packageName == packageName && taskInfo.numActivities > 1) {
                return true
            }
        }
        return false
    }
}