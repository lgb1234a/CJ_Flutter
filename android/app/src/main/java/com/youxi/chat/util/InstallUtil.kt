package com.youxi.chat.util

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.text.TextUtils
import com.netease.nim.uikit.api.NimUIKit
import java.io.File

object InstallUtil {
    private const val TAG = "InstallUtil"
    private var versionCode = 0
    private var versionName: String? = null
    /**
     * 是否已安装app
     *
     * @param context
     * @param packageName
     * @return
     */
    fun isAppInstalled(context: Context, packageName: String?): Boolean {
        return try {
            if (TextUtils.isEmpty(packageName)) false else context.packageManager.getPackageInfo(packageName, PackageManager.GET_ACTIVITIES) != null
        } catch (localNameNotFoundException: PackageManager.NameNotFoundException) {
            false
        }
    }

    /**
     * 打开app
     *
     * @param packageName
     * @param context
     */
    fun openApp(context: Context, packageName: String?) {
        val packageManager = context.packageManager
        val intent = packageManager.getLaunchIntentForPackage(packageName)
        if (intent != null) context.startActivity(intent)
    }

    /**
     * 某个app的版本号，未安装时返回null
     */
    fun getVersionName(context: Context, packageName: String?): String? {
        return try {
            val pi = context.packageManager.getPackageInfo(packageName, 0)
            pi?.versionName
        } catch (e: PackageManager.NameNotFoundException) {
            null
        }
    }

    fun getVersionCode(context: Context): Int {
        if (versionCode == 0) {
            loadVersionInfo(context)
        }
        return versionCode
    }

    /**
     * 易信版本号
     */
    fun getVersionName(context: Context): String? {
        if (TextUtils.isEmpty(versionName)) {
            loadVersionInfo(context)
        }
        return versionName
    }

    private fun loadVersionInfo(context: Context) {
        try {
            val pi = context.packageManager.getPackageInfo(context.packageName, 0)
            if (pi != null) {
                versionCode = pi.versionCode
                versionName = pi.versionName
            }
        } catch (e: PackageManager.NameNotFoundException) {
            e.printStackTrace()
        }
    }

    /**
     * 安装apk文件
     */
    fun installApk(filepath: String) {
        NimUIKit.getContext().startActivity(getInstallApkIntent(filepath))
    }

    /**
     * 安装apk文件
     */
    private fun getInstallApkIntent(filepath: String): Intent {
        val intent = Intent(Intent.ACTION_VIEW)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        val file = File(filepath)
        intent.setDataAndType(Uri.fromFile(file), "application/vnd.android.package-archive")
        return intent
    }
}