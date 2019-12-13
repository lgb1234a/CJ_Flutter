package com.youxi.chat.widget.viewpager

import android.annotation.SuppressLint
import android.view.View
import androidx.viewpager.widget.ViewPager.PageTransformer

/**
 * Viewpager 页面切换动画，只支持3.0以上版本
 *
 *
 * [-∞，-1]完全不可见
 * [-1,  0]从不可见到完全可见
 * [0,1]从完全可见到不可见
 * [1,∞]完全不可见
 *
 *
 * Created by doc on 15/1/6.
 */
class FadeInOutPageTransformer : PageTransformer {
    @SuppressLint("NewApi")
    override fun transformPage(page: View, position: Float) {
        if (position < -1) { //页码完全不可见
            page.alpha = 0f
        } else if (position < 0) {
            page.alpha = 1 + position
        } else if (position < 1) {
            page.alpha = 1 - position
        } else {
            page.alpha = 0f
        }
    }
}