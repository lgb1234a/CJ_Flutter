package com.youxi.chat.widget.viewpager

import android.content.Context
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentPagerAdapter
import androidx.viewpager.widget.ViewPager
import com.netease.nim.uikit.common.fragment.TabFragment
import com.youxi.chat.widget.viewpager.PagerSlidingTabStrip.OnTabClickListener
import com.youxi.chat.widget.viewpager.PagerSlidingTabStrip.OnTabDoubleTapListener

abstract class SlidingTabPagerAdapter(fm: FragmentManager?, count: Int, context: Context, pager: ViewPager) : FragmentPagerAdapter(fm!!), TabFragment.State, OnTabClickListener, OnTabDoubleTapListener {
    protected val fragments: Array<TabFragment?>
    protected val context: Context
    private val pager: ViewPager
    abstract val cacheCount: Int
    private var lastPostion = 0
    override fun getItem(pos: Int): TabFragment {
        return fragments[pos]!!
    }

    abstract override fun getCount(): Int
    abstract override fun getPageTitle(position: Int): CharSequence
    abstract fun getPageIcon(position: Int): Int
    override fun isCurrent(f: TabFragment): Boolean { // FROM PAGER
        val current = pager.currentItem
        // TRAVEL
        for (index in fragments.indices) { // CATCH
            if (f === fragments[index]) { // MATCH
                if (index == current) {
                    return true
                }
            }
        }
        // ANY PROBLEM
        return false
    }

    fun onPageSelected(position: Int) {
        val fragment = getFragmentByPosition(position) ?: return
        // INSTANCE
        fragment.onCurrent()
        onLeave(position)
    }

    private fun onLeave(position: Int) {
        val fragment = getFragmentByPosition(lastPostion)
        lastPostion = position
        // INSTANCE
        if (fragment == null) {
            return
        }
        fragment.onLeave()
    }

    fun onPageScrolled(position: Int) {
        val fragment = getFragmentByPosition(position) ?: return
        // INSTANCE
        fragment.onCurrentScrolled()
        onLeave(position)
    }

    private fun getFragmentByPosition(position: Int): TabFragment? { // IDX
        return if (position < 0 || position >= fragments.size) {
            null
        } else fragments[position]
    }

    override fun onCurrentTabClicked(position: Int) {
        val fragment = getFragmentByPosition(position) ?: return
        // INSTANCE
        fragment.onCurrentTabClicked()
    }

    override fun onCurrentTabDoubleTap(position: Int) {
        val fragment = getFragmentByPosition(position) ?: return
        // INSTANCE
        fragment.onCurrentTabDoubleTap()
    }

    init {
        fragments = arrayOfNulls(getCount())
        this.context = context
        this.pager = pager
        lastPostion = 0
    }
}