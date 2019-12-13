package com.youxi.chat.module.location.helper

import android.content.Context
import android.content.Intent
import android.content.pm.PackageInfo
import android.text.TextUtils
import com.netease.nim.uikit.common.ToastHelper
import com.netease.nim.uikit.common.util.log.LogUtil
import com.youxi.chat.R
import com.youxi.chat.module.location.model.NimLocation
import java.net.URISyntaxException
import java.util.*

object MapHelper {
    private const val Autonavi_Map = "com.autonavi.minimap"
    private fun initComponentInfo(context: Context): List<PackageInfo> {
        val maps: MutableList<String> = ArrayList()
        maps.add(Autonavi_Map)
        return getComponentInfo(context, maps)
    }

    private fun getComponentInfo(context: Context,
                                 maps: List<String>): List<PackageInfo> {
        val pm = context.packageManager
        val infos = pm.getInstalledPackages(0)
        val available: MutableList<PackageInfo> = ArrayList()
        if (infos != null && infos.size > 0) for (info in infos) {
            val packName = info.packageName
            if (!TextUtils.isEmpty(packName) && maps.contains(packName)) {
                if (packName == Autonavi_Map) {
                    if (info.versionCode >= 161) available.add(info)
                } else {
                    available.add(info)
                }
            }
        }
        return available
    }

    fun navigate(context: Context, info: PackageInfo?, origin: NimLocation, des: NimLocation) {
        var intent: Intent? = null
        if (info == null) {
            intent = intentForAmap(origin, des)
        }
        if (intent != null) {
            try {
                context.startActivity(intent)
            } catch (e: Exception) {
                LogUtil.e("mapHelper", "navigate error")
                ToastHelper.showToast(context, R.string.location_open_map_error)
            }
        }
    }

    private fun intentForAmap(origin: NimLocation, des: NimLocation): Intent? {
        var intentForAmap: Intent?
        val arrayOfObject = arrayOfNulls<Any>(4)
        arrayOfObject[0] = java.lang.Double.valueOf(origin.getLatitude())
        arrayOfObject[1] = java.lang.Double.valueOf(origin.getLongitude())
        arrayOfObject[2] = java.lang.Double.valueOf(des.getLatitude())
        arrayOfObject[3] = java.lang.Double.valueOf(des.getLongitude())
        val str = String.format("androidamap://route?sourceApplication=yixin&slat=%f&slon=%f&sname=起点&dlat=%f&dlon=%f&dname=终点&dev=0&m=0&t=0&showType=1", *arrayOfObject)
        val intent: Intent
        try {
            intent = Intent.parseUri(str, 0)
            intent.setPackage(Autonavi_Map)
            intentForAmap = intent
        } catch (e: URISyntaxException) {
            e.printStackTrace()
            intentForAmap = null
        }
        return intentForAmap
    }

    fun getAvailableMaps(context: Context): List<PackageInfo> {
        return initComponentInfo(context)
    }
}