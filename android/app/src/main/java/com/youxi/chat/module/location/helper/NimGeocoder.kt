package com.youxi.chat.module.location.helper

import android.content.Context
import android.location.Address
import android.location.Geocoder
import android.os.Handler
import android.text.TextUtils
import com.amap.api.services.core.AMapException
import com.amap.api.services.core.LatLonPoint
import com.amap.api.services.geocoder.GeocodeSearch
import com.amap.api.services.geocoder.RegeocodeAddress
import com.amap.api.services.geocoder.RegeocodeQuery
import com.netease.nim.uikit.common.framework.infra.*
import com.netease.nim.uikit.common.util.log.LogUtil
import com.youxi.chat.module.location.model.NimLocation
import java.io.IOException
import java.util.*

class NimGeocoder(private val context: Context, private var listener: NimGeocoderListener?) {
    interface NimGeocoderListener {
        fun onGeoCoderResult(location: NimLocation)
    }

    private val queryList: MutableList<NimLocation>
    private var querying: MutableSet<NimLocation>
    private var providers: MutableList<GeocoderProvider>? = null
    private var taskManager: TaskManager? = null
    private val callerHandler: Handler
    /**
     * 是否来次定位坐标（用于缓存）
     *
     * @param latitude
     * @param longitude
     * @param fromLocation
     */
    @JvmOverloads
    fun queryAddress(latitude: Double, longitude: Double, fromLocation: Boolean = false) {
        val location = NimLocation(latitude, longitude)
        location.isFromLocation = fromLocation
        queryList.add(location)
        query()
    }

    /**
     * @param latitude
     * @param longitude
     * @param fromLocation 是否来次定位坐标（用于缓存）
     */
    @JvmOverloads
    fun queryAddressNow(latitude: Double, longitude: Double, fromLocation: Boolean = false) { // remove all
        queryList.clear()
        querying.clear()
        if (taskManager != null) {
            taskManager!!.cancelAll()
        }
        queryAddress(latitude, longitude, fromLocation)
    }

    fun destroy() {
        queryList.clear()
        querying.clear()
        if (taskManager != null) {
            taskManager!!.shutdown()
        }
        listener = null
    }

    private fun query() {
        if (queryList.size == 0) {
            return
        }
        if (taskManager == null) {
            val config = TaskExecutor.Config(0, 3, 30 * 1000, true)
            taskManager = DefaultTaskManager(DefaultTaskWorker(TAG, config))
        }
        val location: NimLocation = queryList.removeAt(0)
        querying.add(location)
        taskManager!!.schedule(object : ManagedTask() {
            override fun execute(params: Array<Any>): Array<Any>? {
                for (provider in providers!!) {
                    if (!querying.contains(location)) {
                        break
                    }
                    if (provider.queryAddress(location)) {
                        break
                    }
                }
                notifyListener(location)
                return null
            }
        })
    }

    private fun notifyListener(location: NimLocation) {
        callerHandler.post {
            if (listener != null && querying.contains(location)) {
                listener!!.onGeoCoderResult(location)
                querying.remove(location)
            }
            // again to see if there are pending queries
            query()
        }
    }

    private fun setupProviders() {
        providers = mutableListOf(
                AMapGeocoder(),
                GoogleGeocoder()
        )
    }

    private interface GeocoderProvider {
        fun queryAddress(location: NimLocation): Boolean
    }

    private inner class GoogleGeocoder : GeocoderProvider {
        private val geocoder = Geocoder(context, Locale.getDefault())
        override fun queryAddress(location: NimLocation): Boolean {
            var ret = false
            try {
                val list = geocoder.getFromLocation(location.getLatitude(), location.getLongitude(), 1)
                if (list != null && list.size > 0) {
                    val address = list[0]
                    if (address != null) {
                        locationFromGoogleAddress(location, address)
                        ret = true
                    }
                }
            } catch (e: IOException) {
                LogUtil.e(TAG, e.toString() + "")
            }
            return ret
        }
    }

    private inner class AMapGeocoder : GeocoderProvider {
        private val search = GeocodeSearch(context)
        override fun queryAddress(location: NimLocation): Boolean {
            var ret = false
            val point = LatLonPoint(location.getLatitude(), location.getLongitude())
            val query = RegeocodeQuery(point, 100f, GeocodeSearch.AMAP)
            try {
                val address = search.getFromLocation(query)
                if (address != null && !TextUtils.isEmpty(address.formatAddress)) {
                    locationFromAmapAddress(location, address)
                    ret = true
                }
            } catch (e: AMapException) {
                e.printStackTrace()
            }
            return ret
        }
    }

    companion object {
        private const val TAG = "YixinGeoCoder"
        private fun locationFromGoogleAddress(location: NimLocation, address: Address) {
            location.setStatus(NimLocation.Status.HAS_LOCATION_ADDRESS)
            location.countryName = address.countryName
            location.countryCode = address.countryCode
            location.setProvinceName(address.adminArea)
            location.cityName = address.locality
            location.districtName = address.subLocality
            location.streetName = address.thoroughfare
            location.featureName = address.featureName
        }

        private fun locationFromAmapAddress(location: NimLocation, address: RegeocodeAddress) {
            location.setStatus(NimLocation.Status.HAS_LOCATION_ADDRESS)
            location.addrStr = address.formatAddress
            location.setProvinceName(address.province)
            location.cityName = address.city
            location.districtName = address.district
            val street = StringBuilder()
            if (!TextUtils.isEmpty(address.township)) {
                street.append(address.township)
            }
            if (address.streetNumber != null) {
                street.append(address.streetNumber.street)
                if (!TextUtils.isEmpty(address.streetNumber.number)) {
                    street.append(address.streetNumber.number)
                    street.append("号")
                }
            }
            location.streetName = street.toString()
        }
    }

    init {
        queryList = LinkedList<NimLocation>()
        querying = HashSet<NimLocation>()
        querying = Collections.synchronizedSet(querying)
        callerHandler = Handler()
        setupProviders()
    }
}