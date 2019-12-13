package com.youxi.chat.module.session.adapter

import android.content.Context
import androidx.fragment.app.FragmentManager
import androidx.viewpager.widget.ViewPager
import com.youxi.chat.R
import com.youxi.chat.module.session.fragment.tab.AckMsgTabFragment
import com.youxi.chat.module.session.model.AckMsgTab
import com.youxi.chat.widget.viewpager.SlidingTabPagerAdapter

class AckMsgTabPagerAdapter(fm: FragmentManager, context: Context, pager: ViewPager) :
        SlidingTabPagerAdapter(fm, AckMsgTab.values().size, context.applicationContext, pager) {
    override val cacheCount: Int
        get() = AckMsgTab.values().size

    override fun getCount(): Int {
        return AckMsgTab.values().size
    }

    override fun getPageIcon(position: Int): Int {
        return R.drawable.small_app_icon
//        return AckMsgTab.values().size
    }

    override fun getPageTitle(position: Int): CharSequence {
        val tab: AckMsgTab? = AckMsgTab.fromTabIndex(position)
        val resId = if (tab != null) tab.resId else 0
        return if (resId != 0) context.getText(resId) else ""
    }

    init {
        for (tab in AckMsgTab.values()) {
            try {
                var fragment: AckMsgTabFragment? = null
                val fs = fm.fragments
                if (fs != null) {
                    for (f in fs) {
                        if (f.javaClass == tab.clazz) {
                            fragment = f as AckMsgTabFragment
                            break
                        }
                    }
                }
                if (fragment == null) {
                    fragment = tab.clazz.newInstance()
                }
                fragment?.setState(this)
                fragment?.attachTabData(tab)
                fragments.set(tab.tabIndex, fragment!!)
            } catch (e: InstantiationException) {
                e.printStackTrace()
            } catch (e: IllegalAccessException) {
                e.printStackTrace()
            }
        }
    }
}