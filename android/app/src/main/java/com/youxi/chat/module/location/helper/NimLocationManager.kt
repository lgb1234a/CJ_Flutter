package com.youxi.chat.module.location.helper

import android.content.Context
import android.location.*
import android.os.Handler
import android.os.Message
import android.text.TextUtils
import com.amap.api.location.AMapLocation
import com.amap.api.location.AMapLocationClient
import com.amap.api.location.AMapLocationClientOption
import com.amap.api.location.AMapLocationListener
import com.youxi.chat.module.location.model.NimLocation
import com.netease.nim.uikit.common.framework.infra.TaskExecutor
import com.netease.nim.uikit.common.util.log.LogUtil
import java.io.IOException
import java.util.*

class NimLocationManager(private val mContext: Context, oneShotListener: NimLocationListener?) : AMapLocationListener {
    interface NimLocationListener {
        fun onLocationChanged(location: NimLocation?)
    }

    private val mListener: NimLocationListener?
    private var criteria: Criteria? = null
    private val mMsgHandler = MsgHandler()
    private val executor = TaskExecutor(TAG, TaskExecutor.defaultConfig, true)
    /**
     * AMap location
     */
    private var client: AMapLocationClient? = null
    private val mGeocoder: Geocoder
    val lastKnownLocation: Location?
        get() {
            try {
                if (criteria == null) {
                    criteria = Criteria()
                    criteria!!.accuracy = Criteria.ACCURACY_COARSE
                    criteria!!.isAltitudeRequired = false
                    criteria!!.isBearingRequired = false
                    criteria!!.isCostAllowed = false
                }
                return client!!.lastKnownLocation
            } catch (e: Exception) {
                LogUtil.i(TAG, "get last known location failed: $e")
            }
            return null
        }

    fun request() {
        if (client == null) {
            val option = AMapLocationClientOption()
            option.locationMode = AMapLocationClientOption.AMapLocationMode.Battery_Saving
            option.interval = 30 * 1000.toLong()
            option.httpTimeOut = 10 * 1000.toLong()
            client = AMapLocationClient(mContext)
            client!!.setLocationOption(option)
            client!!.setLocationListener(this)
            client!!.startLocation()
        }
    }

    fun stop() {
        if (client != null) {
            client!!.unRegisterLocationListener(this)
            client!!.stopLocation()
            client!!.onDestroy()
        }
        mMsgHandler.removeCallbacksAndMessages(null)
        client = null
    }

    override fun onLocationChanged(aMapLocation: AMapLocation) {
        if (aMapLocation != null) {
            executor.execute { getAMapLocationAddress(aMapLocation) }
        } else {
            onLocation(null, MSG_LOCATION_ERROR)
        }
    }

    private fun onLocation(location: NimLocation?, what: Int) {
        val msg = mMsgHandler.obtainMessage()
        msg.what = what
        msg.obj = location
        mMsgHandler.sendMessage(msg)
    }

    private inner class MsgHandler : Handler() {
        override fun handleMessage(msg: Message) {
            when (msg.what) {
                MSG_LOCATION_WITH_ADDRESS_OK -> if (mListener != null && msg.obj != null) {
                    if (msg.obj != null) {
                        val loc: NimLocation = msg.obj as NimLocation
                        loc.setStatus(NimLocation.Status.HAS_LOCATION_ADDRESS)
                        // 记录地址信息
                        loc.isFromLocation = true
                        mListener.onLocationChanged(loc)
                    } else {
                        val loc = NimLocation()
                        mListener.onLocationChanged(loc)
                    }
                }
                MSG_LOCATION_POINT_OK -> if (mListener != null) {
                    if (msg.obj != null) {
                        val loc: NimLocation = msg.obj as NimLocation
                        loc.setStatus(NimLocation.Status.HAS_LOCATION)
                        mListener.onLocationChanged(loc)
                    } else {
                        val loc = NimLocation()
                        mListener.onLocationChanged(loc)
                    }
                }
                MSG_LOCATION_ERROR -> if (mListener != null) {
                    val loc = NimLocation()
                    mListener.onLocationChanged(loc)
                }
                else -> {
                }
            }
            super.handleMessage(msg)
        }
    }

    private fun getAMapLocationAddress(loc: AMapLocation) {
        if (TextUtils.isEmpty(loc.address)) {
            executor.execute { getLocationAddress(NimLocation(loc, NimLocation.AMap_Location)) }
        } else {
            val location = NimLocation(loc, NimLocation.AMap_Location)
            location.addrStr = loc.address
            location.setProvinceName(loc.province)
            location.cityName = loc.city
            location.cityCode = loc.cityCode
            location.districtName = loc.district
            location.streetName = loc.street
            location.streetCode = loc.adCode
            onLocation(location, MSG_LOCATION_WITH_ADDRESS_OK)
        }
    }

    private fun getLocationAddress(location: NimLocation): Boolean {
        val list: List<Address>?
        var ret = false
        try {
            list = mGeocoder.getFromLocation(location.getLatitude(), location.getLongitude(), 2)
            if (list != null && list.size > 0) {
                val address = list[0]
                if (address != null) {
                    location.countryName = address.countryName
                    location.countryCode = address.countryCode
                    location.setProvinceName(address.adminArea)
                    location.cityName = address.locality
                    location.districtName = address.subLocality
                    location.streetName = address.thoroughfare
                    location.featureName = address.featureName
                }
                ret = true
            }
        } catch (e: IOException) {
            LogUtil.e(TAG, e.toString() + "")
        }
        val what = if (ret) MSG_LOCATION_WITH_ADDRESS_OK else MSG_LOCATION_POINT_OK
        onLocation(location, what)
        return ret
    }

    companion object {
        private const val TAG = "NimLocationManager"
        /**
         * msg handler
         */
        private const val MSG_LOCATION_WITH_ADDRESS_OK = 1
        private const val MSG_LOCATION_POINT_OK = 2
        private const val MSG_LOCATION_ERROR = 3
        fun isLocationEnable(context: Context): Boolean {
            val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
            val cri = Criteria()
            cri.accuracy = Criteria.ACCURACY_COARSE
            cri.isAltitudeRequired = false
            cri.isBearingRequired = false
            cri.isCostAllowed = false
            val bestProvider = locationManager.getBestProvider(cri, true)
            return !TextUtils.isEmpty(bestProvider)
        }
    }

    init {
        mGeocoder = Geocoder(mContext, Locale.getDefault())
        mListener = oneShotListener
    }
}