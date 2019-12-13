package com.youxi.chat.module.location

import android.content.Context
import android.content.Intent
import android.provider.Settings
import com.youxi.chat.module.location.activity.LocationAmapActivity
import com.youxi.chat.module.location.activity.LocationExtras
import com.youxi.chat.module.location.activity.NavigationAmapActivity
import com.youxi.chat.module.location.helper.NimLocationManager
import com.netease.nim.uikit.api.model.location.LocationProvider
import com.netease.nim.uikit.common.ui.dialog.EasyAlertDialog
import com.netease.nim.uikit.common.util.log.LogUtil

/**
 * Created by zhoujianghua on 2015/8/11.
 */
class NimLocationProvider : LocationProvider {
    override fun requestLocation(context: Context, callback: LocationProvider.Callback) {
        if (!NimLocationManager.Companion.isLocationEnable(context)) {
            val alertDialog = EasyAlertDialog(context)
            alertDialog.setMessage("位置服务未开启")
            alertDialog.addNegativeButton("取消", EasyAlertDialog.NO_TEXT_COLOR, EasyAlertDialog.NO_TEXT_SIZE.toFloat()
            ) { alertDialog.dismiss() }
            alertDialog.addPositiveButton("设置", EasyAlertDialog.NO_TEXT_COLOR, EasyAlertDialog.NO_TEXT_SIZE.toFloat()
            ) {
                alertDialog.dismiss()
                val intent = Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS)
                try {
                    context.startActivity(intent)
                } catch (e: Exception) {
                    LogUtil.e("LOC", "start ACTION_LOCATION_SOURCE_SETTINGS error")
                }
            }
            alertDialog.show()
            return
        }
        LocationAmapActivity.Companion.start(context, callback)
    }

    override fun openMap(context: Context, longitude: Double, latitude: Double, address: String) {
        val intent = Intent(context, NavigationAmapActivity::class.java)
        intent.putExtra(LocationExtras.Companion.LONGITUDE, longitude)
        intent.putExtra(LocationExtras.Companion.LATITUDE, latitude)
        intent.putExtra(LocationExtras.Companion.ADDRESS, address)
        context.startActivity(intent)
    }
}