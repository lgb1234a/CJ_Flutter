package com.youxi.chat.module.main.adapter

import android.content.Context
import androidx.fragment.app.FragmentManager
import androidx.viewpager.widget.ViewPager
import com.youxi.chat.module.main.fragment.MainTabFragment
import com.youxi.chat.module.main.model.MainTab
import com.youxi.chat.widget.viewpager.SlidingTabPagerAdapter

class MainTabPagerAdapter(fm: FragmentManager, context: Context, pager: ViewPager?) :
        SlidingTabPagerAdapter(fm, MainTab.values().size, context.applicationContext, pager!!) {
    override val cacheCount: Int
        get() = MainTab.values().size


    override fun getCount(): Int {
        return MainTab.values().size
    }

    override fun getPageTitle(position: Int): CharSequence {
        val tab: MainTab? = MainTab.fromTabIndex(position)
        val resId = if (tab != null) tab.resId else 0
        return if (resId != 0) context.getText(resId) else ""
    }

    override fun getPageIcon(position: Int): Int {
        val tab: MainTab? = MainTab.fromTabIndex(position)
        val resId = if (tab != null) tab.iconId else 0
        return resId
    }

    init {
        for (tab in MainTab.values()) {
            try {
                var fragment: MainTabFragment? = null
                val fs = fm.fragments
                if (fs != null) {
                    for (f in fs) {
                        if (f.javaClass == tab.clazz) {
                            fragment = f as MainTabFragment
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