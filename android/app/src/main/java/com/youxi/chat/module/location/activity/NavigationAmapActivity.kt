package com.youxi.chat.module.location.activity

import android.content.pm.PackageInfo
import android.location.Location
import android.os.Bundle
import android.text.TextUtils
import android.view.View
import android.widget.TextView
import com.amap.api.maps2d.AMap
import com.amap.api.maps2d.AMap.*
import com.amap.api.maps2d.CameraUpdateFactory
import com.amap.api.maps2d.MapView
import com.amap.api.maps2d.model.*
import com.netease.nim.uikit.api.wrapper.NimToolBarOptions
import com.netease.nim.uikit.common.ToastHelper
import com.netease.nim.uikit.common.activity.ToolBarOptions
import com.netease.nim.uikit.common.activity.UI
import com.netease.nim.uikit.common.ui.dialog.CustomAlertDialog
import com.netease.nim.uikit.common.util.string.StringUtil
import com.youxi.chat.R
import com.youxi.chat.module.location.activity.LocationExtras.Companion.ADDRESS
import com.youxi.chat.module.location.activity.LocationExtras.Companion.DEFAULT_ZOOM_LEVEL
import com.youxi.chat.module.location.activity.LocationExtras.Companion.LATITUDE
import com.youxi.chat.module.location.activity.LocationExtras.Companion.LONGITUDE
import com.youxi.chat.module.location.activity.LocationExtras.Companion.ZOOM_LEVEL
import com.youxi.chat.module.location.adapter.IconListAdapter
import com.youxi.chat.module.location.adapter.IconListAdapter.IconListItem
import com.youxi.chat.module.location.helper.MapHelper
import com.youxi.chat.module.location.helper.NimLocationManager
import com.youxi.chat.module.location.helper.NimLocationManager.NimLocationListener
import com.youxi.chat.module.location.model.NimLocation
import java.util.*

class NavigationAmapActivity : UI(), View.OnClickListener, LocationExtras, NimLocationListener, OnMarkerClickListener, OnInfoWindowClickListener, InfoWindowAdapter {
    private var sendButton: TextView? = null
    private var mapView: MapView? = null
    private var locationManager: NimLocationManager? = null
    private var myLatLng: LatLng? = null
    private var desLatLng: LatLng? = null
    private var myMaker: Marker? = null
    private var desMaker: Marker? = null
    private var myAddressInfo // 对应的地址信息
            : String? = null
    private var desAddressInfo // 目的地址信息
            : String? = null
    private var firstLocation = true
    private var firstTipLocation = true
    private var myLocationFormatText: String? = null
    var amap: AMap? = null
    public override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.map_view_amap_navigation_layout)
        mapView = findViewById<View>(R.id.autonavi_mapView) as MapView
        mapView!!.onCreate(savedInstanceState) // 此方法必须重写
        val options: ToolBarOptions = NimToolBarOptions()
        setToolBar(R.id.toolbar, options)
        initView()
        initAmap()
        initLocation()
        updateSendStatus()
    }

    private fun initView() {
        sendButton = findView(R.id.action_bar_right_clickable_textview)
        sendButton?.setText(R.string.location_navigate)
        sendButton?.setOnClickListener(this)
        sendButton?.setVisibility(View.INVISIBLE)
        myLocationFormatText = getString(R.string.format_mylocation)
    }

    private fun initAmap() {
        try {
            amap = mapView!!.map
            val uiSettings = amap?.getUiSettings()
            uiSettings?.isZoomControlsEnabled = true
            // 设置为true表示显示定位层并可触发定位，false表示隐藏定位层并不可触发定位，默认是false
            uiSettings?.isMyLocationButtonEnabled = false // 设置默认定位按钮是否显示
            amap?.setOnMarkerClickListener(this) // 标记点击
            amap?.setOnInfoWindowClickListener(this) // 设置点击infoWindow事件监听器
            amap?.setInfoWindowAdapter(this) // 必须 信息窗口显示
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun initLocation() {
        locationManager = NimLocationManager(this, this)
        val location: Location? = locationManager?.lastKnownLocation
        val intent = intent
        val latitude = intent.getDoubleExtra(LATITUDE, -100.0)
        val longitude = intent.getDoubleExtra(LONGITUDE, -100.0)
        desLatLng = LatLng(latitude, longitude)
        desAddressInfo = intent.getStringExtra(ADDRESS)
        if (TextUtils.isEmpty(desAddressInfo)) {
            desAddressInfo = getString(R.string.location_address_unkown)
        }
        val zoomLevel = intent.getIntExtra(ZOOM_LEVEL, DEFAULT_ZOOM_LEVEL).toFloat()
        myLatLng = if (location == null) {
            LatLng(39.90923, 116.397428)
        } else {
            LatLng(location.latitude, location.longitude)
        }
        createNavigationMarker()
        startLocationTimeout()
        val camera = CameraUpdateFactory.newCameraPosition(CameraPosition(desLatLng, zoomLevel,
                0f, 0f))
        amap!!.moveCamera(camera)
    }

    private fun startLocationTimeout() {
        val handler = handler
        handler.removeCallbacks(runnable)
        handler.postDelayed(runnable, 20 * 1000.toLong()) // 20s超时
    }

    private fun updateSendStatus() {
        if (isFinishing) {
            return
        }
        if (TextUtils.isEmpty(myAddressInfo)) {
            setTitle(R.string.location_loading)
            sendButton!!.visibility = View.GONE
        } else {
            setTitle(R.string.location_map)
            sendButton!!.visibility = View.GONE
        }
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        mapView!!.onSaveInstanceState(outState)
    }

    override fun onPause() {
        super.onPause()
        mapView!!.onPause()
        if (locationManager != null) {
            locationManager?.stop()
        }
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
    }

    private fun navigate() {
        val des = NimLocation(desLatLng!!.latitude, desLatLng!!.longitude)
        val origin = NimLocation(myLatLng!!.latitude, myLatLng!!.longitude)
        doNavigate(origin, des)
    }

    override fun onClick(v: View) {
        when (v.id) {
            R.id.action_bar_right_clickable_textview -> navigate()
        }
    }

    override fun onLocationChanged(location: NimLocation?) {
        if (location != null && location.hasCoordinates()) {
            if (firstLocation) {
                firstLocation = false
                myAddressInfo = location.fullAddr
                val latitude: Double = location.getLatitude()
                val longitude: Double = location.getLongitude()
                myLatLng = LatLng(latitude, longitude)
                // 缩放到可见区
                val boundPadding = resources.getDimensionPixelSize(R.dimen.friend_map_bound_padding)
                val bounds = LatLngBounds.builder().include(myLatLng).include(desLatLng).build()
                val camera = CameraUpdateFactory.newLatLngBounds(bounds, boundPadding)
                amap!!.moveCamera(camera)
                updateMyMarkerLatLng()
                updateSendStatus()
            }
        } else {
            showLocationFailTip()
        }
        clearTimeoutHandler()
    }

    private fun updateMyMarkerLatLng() {
        myMaker!!.position = myLatLng
        myMaker!!.showInfoWindow()
    }

    private fun showLocationFailTip() {
        if (firstLocation && firstTipLocation) {
            firstTipLocation = false
            myAddressInfo = getString(R.string.location_address_unkown)
            ToastHelper.showToast(this, R.string.location_address_fail)
        }
    }

    private fun clearTimeoutHandler() {
        val handler = handler
        handler.removeCallbacks(runnable)
    }

    private val runnable = Runnable {
        showLocationFailTip()
        updateSendStatus()
    }

    private fun defaultMarkerOptions(): MarkerOptions {
        val markerOptions = MarkerOptions()
        markerOptions.anchor(0.5f, 0.5f)
        markerOptions.icon(BitmapDescriptorFactory.fromResource(R.drawable.pin))
        return markerOptions
    }

    private fun createNavigationMarker() {
        desMaker = amap!!.addMarker(defaultMarkerOptions())
        desMaker?.setPosition(desLatLng)
        desMaker?.setTitle(desAddressInfo)
        desMaker?.showInfoWindow()
        myMaker = amap!!.addMarker(defaultMarkerOptions())
        myMaker?.setPosition(myLatLng)
    }

    private fun doNavigate(origin: NimLocation, des: NimLocation) {
        val items: MutableList<IconListItem> = ArrayList<IconListItem>()
        val adapter = IconListAdapter(this, items)
        val infos: List<PackageInfo> = MapHelper.getAvailableMaps(this)
        if (infos.size >= 1) {
            for (info in infos) {
                val name = info.applicationInfo.loadLabel(packageManager).toString()
                val icon = info.applicationInfo.loadIcon(packageManager)
                val item = IconListItem(name, icon, info)
                items.add(item)
            }
            val dialog = CustomAlertDialog(this, items.size)
            dialog.setAdapter(adapter) { dialog, position ->
                val item: IconListItem = adapter.getItem(position)!!
                val info = item.attach as PackageInfo
                MapHelper.navigate(this@NavigationAmapActivity, info, origin, des)
            }
            dialog.setTitle(getString(R.string.tools_selected))
            dialog.show()
        } else {
            val item = IconListItem(getString(R.string.friends_map_navigation_web), null, null)
            items.add(item)
            val dialog = CustomAlertDialog(this, items.size)
            dialog.setAdapter(adapter) { dialog, position -> MapHelper.navigate(this@NavigationAmapActivity, null, origin, des) }
            dialog.setTitle(getString(R.string.tools_selected))
            dialog.show()
        }
    }

    override fun onInfoWindowClick(marker: Marker) {
        marker.hideInfoWindow()
    }

    override fun onMarkerClick(marker: Marker): Boolean {
        if (marker == null) {
            return false
        }
        var text: String? = null
        if (marker == desMaker) {
            text = desAddressInfo
        } else if (marker == myMaker) {
            text = myAddressInfo
        }
        if (!TextUtils.isEmpty(text)) {
            marker.title = text
            marker.showInfoWindow()
        }
        return true
    }

    override fun getInfoContents(pmarker: Marker): View {
        return getMarkerInfoView(pmarker)!!
    }

    override fun getInfoWindow(pmarker: Marker): View {
        return getMarkerInfoView(pmarker)!!
    }

    private fun getMarkerInfoView(pmarker: Marker): View? {
        var text: String? = null
        if (pmarker == desMaker) {
            text = desAddressInfo
        } else if (pmarker == myMaker) {
            if (!StringUtil.isEmpty(myAddressInfo)) {
                text = String.format(myLocationFormatText!!, myAddressInfo)
            }
        }
        if (StringUtil.isEmpty(text)) {
            return null
        }
        val view: View = layoutInflater.inflate(R.layout.amap_marker_window_info, null)
        val textView = view.findViewById<View>(R.id.title) as TextView
        textView.text = text
        return view
    }
}