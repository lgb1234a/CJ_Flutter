package com.youxi.chat.module.location.activity

interface LocationExtras {
    companion object {
        const val DEFAULT_ZOOM_LEVEL = 15
        const val LATITUDE = "latitude"
        const val LONGITUDE = "longitude"
        const val ADDRESS = "address"
        const val CALLBACK = "callback"
        const val ZOOM_LEVEL = "zoom_level"
        const val IMG_URL = "img_url"
        const val STATIC_MAP_URL_1 = "http://maps.google.cn/maps/api/staticmap?size=200x100&zoom=13&markers=color:red|label:YourPosition|"
        const val STATIC_MAP_URL_2 = "&maptype=roadmap&sensor=false&format=jpg"
    }
}