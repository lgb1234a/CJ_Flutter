package com.youxi.chat.module.location.model

import android.location.Location
import android.text.TextUtils
import com.alibaba.fastjson.JSONObject
import com.amap.api.location.AMapLocation

class NimLocation {
    enum class Status(var _value: Int) {
        INVALID(0), HAS_LOCATION(1), HAS_LOCATION_ADDRESS(2);

        companion object {
            fun getStatus(value: Int): Status {
                if (value == HAS_LOCATION_ADDRESS._value) {
                    return HAS_LOCATION_ADDRESS
                }
                return if (value == HAS_LOCATION._value) {
                    HAS_LOCATION
                } else INVALID
            }
        }

    }

    private var latitude = DEF_VALUE
    private var longitude = DEF_VALUE
    private var location: Any? = null
    private var type = ""
    private var status = Status.INVALID
    @Transient
    var isFromLocation = false
    var addrStr: String? = null
    private val updateTime: Long = 0
    private val nimAddress = NimAddress()

    constructor(location: Any?, type: String) {
        this.location = location
        this.type = type
        status = Status.HAS_LOCATION
    }

    constructor(latitude: Double, longitude: Double) {
        this.latitude = latitude
        this.longitude = longitude
        type = Just_Point
        status = Status.HAS_LOCATION
    }

    constructor() {
        status = Status.INVALID
    }

    fun setStatus(status: Status) {
        this.status = status
    }

    fun setProvinceName(mProvinceName: String?) {
        nimAddress.provinceName = mProvinceName
    }

    val provinceCode: String?
        get() = nimAddress.provinceCode

    var cityName: String?
        get() = nimAddress.cityName
        set(mCityName) {
            nimAddress.cityName = mCityName
        }

    var cityCode: String?
        get() = nimAddress.cityCode
        set(mCityCode) {
            nimAddress.cityCode = mCityCode
        }

    var districtName: String?
        get() = nimAddress.districtName
        set(mDistrictName) {
            nimAddress.districtName = mDistrictName
        }

    var districtCode: String?
        get() = nimAddress.districtCode
        set(mDistrictCode) {
            nimAddress.districtCode = mDistrictCode
        }

    var streetName: String?
        get() = nimAddress.streetName
        set(mStreetName) {
            nimAddress.streetName = mStreetName
        }

    var streetCode: String?
        get() = nimAddress.streetCode
        set(mStreetCode) {
            nimAddress.streetCode = mStreetCode
        }

    var featureName: String?
        get() = nimAddress.featureName
        set(mFeatureName) {
            nimAddress.featureName = mFeatureName
        }

    var countryName: String?
        get() = nimAddress.countryName
        set(mCountryName) {
            nimAddress.countryName = mCountryName
        }

    var countryCode: String?
        get() = nimAddress.countryCode
        set(mCountryCode) {
            nimAddress.countryCode = mCountryCode
        }

    fun hasCoordinates(): Boolean {
        return if (status != Status.INVALID) true else false
    }

    fun hasAddress(): Boolean {
        return if (status == Status.HAS_LOCATION_ADDRESS) true else false
    }

    val fullAddr: String?
        get() = if (!TextUtils.isEmpty(addrStr)) {
            addrStr
        } else {
            val addr = StringBuilder()
            if (!TextUtils.isEmpty(nimAddress.countryName)) addr.append(nimAddress.countryName)
            if (!TextUtils.isEmpty(nimAddress.provinceName)) addr.append(nimAddress.provinceName)
            if (!TextUtils.isEmpty(nimAddress.cityName)) addr.append(nimAddress.cityName)
            if (!TextUtils.isEmpty(nimAddress.districtName)) addr.append(nimAddress.districtName)
            if (!TextUtils.isEmpty(nimAddress.streetName)) addr.append(nimAddress.streetName)
            addr.toString()
        }

    fun getLatitude(): Double {
        if (location != null) {
            if (type == AMap_Location) latitude = (location as AMapLocation).latitude else if (type == System_Location) latitude = (location as Location).latitude
        }
        return latitude
    }

    fun getLongitude(): Double {
        if (location != null) {
            if (type == AMap_Location) longitude = (location as AMapLocation).longitude else if (type == System_Location) longitude = (location as Location).longitude
        }
        return longitude
    }

    inner class NimAddress {
        var countryName: String? = null
        var countryCode: String? = null
        var provinceName: String? = null
        var provinceCode: String? = null
        var cityName: String? = null
        var cityCode: String? = null
        var districtName: String? = null
        var districtCode: String? = null
        var streetName: String? = null
        var streetCode: String? = null
        var featureName: String? = null
        fun fromJSON(jsonObj: JSONObject?) {
            if (jsonObj == null) {
                return
            }
            countryName = jsonObj.getString(TAG.TAG_COUNTRYNAME)
            countryCode = jsonObj.getString(TAG.TAG_COUNTRYCODE)
            provinceName = jsonObj.getString(TAG.TAG_PROVINCENAME)
            provinceCode = jsonObj.getString(TAG.TAG_PROVINCECODE)
            cityName = jsonObj.getString(TAG.TAG_CITYNAME)
            cityCode = jsonObj.getString(TAG.TAG_CITYCODE)
            districtName = jsonObj.getString(TAG.TAG_DISTRICTNAME)
            districtCode = jsonObj.getString(TAG.TAG_DISTRICTCODE)
            streetName = jsonObj.getString(TAG.TAG_STREETNAME)
            streetCode = jsonObj.getString(TAG.TAG_STREETCODE)
            featureName = jsonObj.getString(TAG.TAG_FEATURENAME)
        }

        fun toJSONObject(): JSONObject {
            val jsonObj = JSONObject()
            jsonObj[TAG.TAG_COUNTRYNAME] = countryName
            jsonObj[TAG.TAG_COUNTRYCODE] = countryCode
            jsonObj[TAG.TAG_PROVINCENAME] = provinceName
            jsonObj[TAG.TAG_PROVINCECODE] = provinceCode
            jsonObj[TAG.TAG_CITYNAME] = cityName
            jsonObj[TAG.TAG_CITYCODE] = cityCode
            jsonObj[TAG.TAG_DISTRICTNAME] = districtName
            jsonObj[TAG.TAG_DISTRICTCODE] = districtCode
            jsonObj[TAG.TAG_STREETNAME] = streetName
            jsonObj[TAG.TAG_STREETCODE] = streetCode
            jsonObj[TAG.TAG_FEATURENAME] = featureName
            return jsonObj
        }
    }

    private object TAG {
        const val TAG_LATITUDE = "latitude"
        const val TAG_LONGITUDE = "longitude"
        const val TAG_TYPE = "type"
        const val TAG_STATUS = "status"
        const val TAG_NIMADDRESS = "nimaddress"
        const val TAG_ADDRSTR = "addrstr"
        const val TAG_UPDATETIME = "updatetime"
        const val TAG_COUNTRYNAME = "countryname"
        const val TAG_COUNTRYCODE = "countrycode"
        const val TAG_PROVINCENAME = "provincename"
        const val TAG_PROVINCECODE = "provincecode"
        const val TAG_CITYNAME = "cityname"
        const val TAG_CITYCODE = "citycode"
        const val TAG_DISTRICTNAME = "districtname"
        const val TAG_DISTRICTCODE = "districtcode"
        const val TAG_STREETNAME = "streetname"
        const val TAG_STREETCODE = "streetcode"
        const val TAG_FEATURENAME = "featurename"
    }

    fun toJSONString(): String {
        val jsonObj = JSONObject()
        jsonObj[TAG.TAG_LATITUDE] = getLatitude()
        jsonObj[TAG.TAG_LONGITUDE] = getLongitude()
        jsonObj[TAG.TAG_TYPE] = type
        jsonObj[TAG.TAG_STATUS] = status._value
        jsonObj[TAG.TAG_ADDRSTR] = addrStr
        jsonObj[TAG.TAG_UPDATETIME] = updateTime
        jsonObj[TAG.TAG_NIMADDRESS] = nimAddress.toJSONObject()
        return jsonObj.toJSONString()
    }

    companion object {
        const val AMap_Location = "AMap_location"
        const val System_Location = "system_location"
        const val Just_Point = "just_point"
        private const val DEF_VALUE = -1000.0
    }
}