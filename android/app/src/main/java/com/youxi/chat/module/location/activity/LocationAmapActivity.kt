package com.youxi.chat.module.location.activity

import android.content.Context
import android.content.Intent
import android.location.Location
import android.os.Bundle
import android.text.TextUtils
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import com.amap.api.maps2d.AMap
import com.amap.api.maps2d.AMap.OnCameraChangeListener
import com.amap.api.maps2d.AMapUtils
import com.amap.api.maps2d.CameraUpdateFactory
import com.amap.api.maps2d.MapView
import com.amap.api.maps2d.model.CameraPosition
import com.amap.api.maps2d.model.LatLng
import com.netease.nim.uikit.api.model.location.LocationProvider
import com.netease.nim.uikit.api.wrapper.NimToolBarOptions
import com.netease.nim.uikit.common.activity.ToolBarOptions
import com.netease.nim.uikit.common.activity.UI
import com.youxi.chat.R
import com.youxi.chat.module.location.helper.NimGeocoder
import com.youxi.chat.module.location.helper.NimGeocoder.NimGeocoderListener
import com.youxi.chat.module.location.helper.NimLocationManager
import com.youxi.chat.module.location.helper.NimLocationManager.NimLocationListener
import com.youxi.chat.module.location.model.NimLocation

class LocationAmapActivity : UI(), OnCameraChangeListener, View.OnClickListener, NimLocationListener {
    private lateinit var sendButton: TextView
    private lateinit var pinView: ImageView
    private lateinit var pinInfoPanel: View
    private lateinit var pinInfoTextView: TextView
    private var locationManager: NimLocationManager? = null
    private var latitude = 0.0 // 经度 = 0.0
    private var longitude = 0.0 // 维度 = 0.0
    private var addressInfo // 对应的地址信息
            : String? = null
    private var cacheLatitude = -1.0
    private var cacheLongitude = -1.0
    private var cacheAddressInfo: String? = null
    private var locating = true // 正在定位的时候不用去查位置
    private var geocoder: NimGeocoder? = null
    private lateinit var amap: AMap
    private lateinit var mapView: MapView
    private lateinit var btnMyLocation: Button
    public override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.map_view_amap_layout)
        mapView = findViewById(R.id.autonavi_mapView)
        mapView.onCreate(savedInstanceState) // 此方法必须重写
        val options: ToolBarOptions = NimToolBarOptions()
        setToolBar(R.id.toolbar, options)
        initView()
        initAmap()
        initLocation()
        updateSendStatus()
    }

    private fun initView() {
        sendButton = findView(R.id.action_bar_right_clickable_textview)
        sendButton.setText(R.string.send)
        sendButton.setOnClickListener(this)
        sendButton.setVisibility(View.INVISIBLE)
        pinView = findViewById(R.id.location_pin)
        pinInfoPanel = findViewById(R.id.location_info)
        pinInfoTextView = pinInfoPanel.findViewById(R.id.marker_address)
        pinView.setOnClickListener(this)
        pinInfoPanel.setOnClickListener(this)
        btnMyLocation = findViewById(R.id.my_location)
        btnMyLocation.setOnClickListener(this)
        btnMyLocation.setVisibility(View.GONE)
    }

    private fun initAmap() {
        try {
            amap = mapView!!.map
            amap.setOnCameraChangeListener(this)
            val uiSettings = amap.getUiSettings()
            uiSettings.isZoomControlsEnabled = true
            // 设置为true表示显示定位层并可触发定位，false表示隐藏定位层并不可触发定位，默认是false
            uiSettings.isMyLocationButtonEnabled = false // 设置默认定位按钮是否显示
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun initLocation() {
        locationManager = NimLocationManager(this, this)
        val location: Location? = locationManager?.lastKnownLocation
        val intent = intent
        val zoomLevel = intent.getIntExtra(LocationExtras.ZOOM_LEVEL, LocationExtras.DEFAULT_ZOOM_LEVEL).toFloat()
        val latlng: LatLng
        latlng = if (location == null) {
            LatLng(39.90923, 116.397428)
        } else {
            LatLng(location.latitude, location.longitude)
        }
        val camera = CameraUpdateFactory.newCameraPosition(CameraPosition(latlng, zoomLevel, 0f, 0f))
        amap!!.moveCamera(camera)
        geocoder = NimGeocoder(this, geocoderListener)
    }

    private fun updateSendStatus() {
        if (isFinishing) {
            return
        }
        var titleResID: Int = R.string.location_map
        if (TextUtils.isEmpty(addressInfo)) {
            titleResID = R.string.location_loading
            sendButton!!.visibility = View.GONE
        } else {
            sendButton!!.visibility = View.VISIBLE
        }
        if (btnMyLocation!!.visibility == View.VISIBLE || Math.abs(-1 - cacheLatitude) < 0.1f) {
            setTitle(titleResID)
        } else {
            setTitle(R.string.my_location)
        }
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        mapView!!.onSaveInstanceState(outState)
    }

    override fun onPause() {
        super.onPause()
        mapView!!.onPause()
        locationManager!!.stop()
    }

    override fun onResume() {
        super.onResume()
        mapView!!.onResume()
        locationManager!!.request()
    }

    override fun onDestroy() {
        super.onDestroy()
        mapView!!.onDestroy()
        if (locationManager != null) {
            locationManager?.stop()
        }
        callback = null
    }

    private val staticMapUrl: String
        private get() {
            val urlBuilder = StringBuilder(LocationExtras.STATIC_MAP_URL_1)
            urlBuilder.append(latitude)
            urlBuilder.append(",")
            urlBuilder.append(longitude)
            urlBuilder.append(LocationExtras.STATIC_MAP_URL_2)
            return urlBuilder.toString()
        }

    private fun sendLocation() {
        val intent = Intent()
        intent.putExtra(LocationExtras.LATITUDE, latitude)
        intent.putExtra(LocationExtras.LONGITUDE, longitude)
        addressInfo = if (TextUtils.isEmpty(addressInfo)) getString(R.string.location_address_unkown) else addressInfo
        intent.putExtra(LocationExtras.ADDRESS, addressInfo)
        intent.putExtra(LocationExtras.ZOOM_LEVEL, amap!!.cameraPosition.zoom)
        intent.putExtra(LocationExtras.IMG_URL, staticMapUrl)
        if (callback != null) {
            callback!!.onSuccess(longitude, latitude, addressInfo)
        }
    }

    override fun onClick(v: View) {
        when (v.id) {
            R.id.action_bar_right_clickable_textview -> {
                sendLocation()
                finish()
            }
            R.id.location_pin -> setPinInfoPanel(!isPinInfoPanelShow)
            R.id.location_info -> pinInfoPanel!!.visibility = View.GONE
            R.id.my_location -> locationAddressInfo(cacheLatitude, cacheLongitude, cacheAddressInfo)
        }
    }

    private fun locationAddressInfo(lat: Double, lng: Double, address: String?) {
        if (amap == null) {
            return
        }
        val latlng = LatLng(lat, lng)
        var cameraPosition: CameraPosition? = null
        try {
            cameraPosition = amap!!.cameraPosition
        } catch (throwable: Throwable) { // do nothing
        }
        val zoom = if (cameraPosition == null) cameraPosition!!.zoom else DEFAULT_ZOOM.toFloat()
        val camera = CameraUpdateFactory.newCameraPosition(CameraPosition(latlng, zoom, 0f, 0f))
        amap!!.moveCamera(camera)
        addressInfo = address
        latitude = lat
        longitude = lng
        setPinInfoPanel(true)
    }

    private val isPinInfoPanelShow: Boolean
        private get() = pinInfoPanel!!.visibility == View.VISIBLE

    private fun setPinInfoPanel(show: Boolean) {
        if (show && !TextUtils.isEmpty(addressInfo)) {
            pinInfoPanel!!.visibility = View.VISIBLE
            pinInfoTextView!!.text = addressInfo
        } else {
            pinInfoPanel!!.visibility = View.GONE
        }
        updateSendStatus()
    }

    override fun onLocationChanged(location: NimLocation?) {
        if (location != null && location.hasCoordinates()) {
            cacheLatitude = location.getLatitude()
            cacheLongitude = location.getLongitude()
            cacheAddressInfo = location.addrStr
            if (locating) {
                locating = false
                locationAddressInfo(cacheLatitude, cacheLongitude, cacheAddressInfo)
            }
        }
    }

    override fun onCameraChange(arg0: CameraPosition) {}
    override fun onCameraChangeFinish(cameraPosition: CameraPosition) {
        if (!locating) {
            queryLatLngAddress(cameraPosition.target)
        } else {
            latitude = cameraPosition.target.latitude
            longitude = cameraPosition.target.longitude
        }
        updateMyLocationStatus(cameraPosition)
    }

    private fun updateMyLocationStatus(cameraPosition: CameraPosition) {
        if (Math.abs(-1 - cacheLatitude) < 0.1f) { // 定位失败
            return
        }
        val source = LatLng(cacheLatitude, cacheLongitude)
        val target = cameraPosition.target
        val distance = AMapUtils.calculateLineDistance(source, target)
        val showMyLocation = distance > 50
        btnMyLocation!!.visibility = if (showMyLocation) View.VISIBLE else View.GONE
        updateSendStatus()
    }

    private fun queryLatLngAddress(latlng: LatLng) {
        if (!TextUtils.isEmpty(addressInfo) && latlng.latitude == latitude && latlng.longitude == longitude) {
            return
        }
        val handler = handler
        handler.removeCallbacks(runable)
        handler.postDelayed(runable, 20 * 1000.toLong()) // 20s超时
        geocoder!!.queryAddressNow(latlng.latitude, latlng.longitude)
        latitude = latlng.latitude
        longitude = latlng.longitude
        addressInfo = null
        setPinInfoPanel(false)
    }

    private fun clearTimeoutHandler() {
        val handler = handler
        handler.removeCallbacks(runable)
    }

    private val geocoderListener: NimGeocoderListener = object : NimGeocoderListener {
        override fun onGeoCoderResult(location: NimLocation) {
            if (latitude == location.getLatitude() && longitude == location.getLongitude()) { // 响应的是当前查询经纬度
                if (location.hasAddress()) {
                    addressInfo = location.fullAddr
                } else {
                    addressInfo = getString(R.string.location_address_unkown)
                }
                setPinInfoPanel(true)
                clearTimeoutHandler()
            }
        }
    }
    private val runable = Runnable {
        addressInfo = getString(R.string.location_address_unkown)
        setPinInfoPanel(true)
    }

    companion object {
        const val DEFAULT_ZOOM = 17
        private var callback: LocationProvider.Callback? = null
        fun start(context: Context, callback: LocationProvider.Callback?) {
            Companion.callback = callback
            context.startActivity(Intent(context, LocationAmapActivity::class.java))
        }
    }
}