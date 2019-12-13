package com.youxi.chat.module.session.activity

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProviders
import androidx.viewpager.widget.ViewPager
import androidx.viewpager.widget.ViewPager.OnPageChangeListener
import com.netease.nim.uikit.api.wrapper.NimToolBarOptions
import com.netease.nim.uikit.common.activity.ToolBarOptions
import com.netease.nim.uikit.common.activity.UI
import com.netease.nimlib.sdk.msg.model.IMMessage
import com.netease.nimlib.sdk.msg.model.TeamMsgAckInfo
import com.youxi.chat.R
import com.youxi.chat.module.main.model.MainTab
import com.youxi.chat.module.main.reminder.ReminderItem
import com.youxi.chat.module.session.adapter.AckMsgTabPagerAdapter
import com.youxi.chat.module.session.model.AckMsgTab
import com.youxi.chat.module.session.model.AckMsgViewModel
import com.youxi.chat.widget.viewpager.FadeInOutPageTransformer
import com.youxi.chat.widget.viewpager.PagerSlidingTabStrip

/**
 * 消息已读详情界面
 * Created by winnie on 2018/3/14.
 */
class AckMsgInfoActivity : UI(), OnPageChangeListener {
    private var tabs: PagerSlidingTabStrip? = null
    private var pager: ViewPager? = null
    private var scrollState = 0
    private var adapter: AckMsgTabPagerAdapter? = null
    private var viewModel: AckMsgViewModel? = null
    private var unreadItem: ReminderItem? = null
    private var readItem: ReminderItem? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.ack_msg_info_layout)
        val options: ToolBarOptions = NimToolBarOptions()
        options.titleId = R.string.ack_msg_info
        options.navigateId = R.drawable.actionbar_dark_back_icon
        setToolBar(R.id.toolbar, options)
        findViews()
        setupPager()
        setupTabs()
        val message = intent.getSerializableExtra(EXTRA_MESSAGE) as IMMessage
        viewModel = ViewModelProviders.of(this).get(AckMsgViewModel::class.java)
        viewModel?.init(message)
        unreadItem = ReminderItem(AckMsgTab.UNREAD.reminderId)
        readItem = ReminderItem(AckMsgTab.READ.reminderId)
        viewModel?.teamMsgAckInfo?.observe(this, Observer<TeamMsgAckInfo?> { teamMsgAckInfo ->
            unreadItem?.setUnread(teamMsgAckInfo!!.unAckCount)
            updateReminder(unreadItem, AckMsgTab.UNREAD.reminderId)
            readItem?.setUnread(teamMsgAckInfo!!.ackCount)
            updateReminder(readItem, AckMsgTab.READ.reminderId)
        })
    }

    /**
     * 查找页面控件
     */
    private fun findViews() {
        tabs = findView(R.id.tabs)
        tabs?.setFakeDropOpen(false)
        pager = findView(R.id.main_tab_pager)
    }

    /**
     * 设置viewPager
     */
    private fun setupPager() { // CACHE COUNT
        adapter = AckMsgTabPagerAdapter(supportFragmentManager, this, pager!!)
        pager!!.offscreenPageLimit = adapter?.cacheCount!!
        // page swtich animation
        pager!!.setPageTransformer(true, FadeInOutPageTransformer())
        // ADAPTER
        pager!!.adapter = adapter
        // TAKE OVER CHANGE
        pager!!.setOnPageChangeListener(this)
    }

    /**
     * 设置tab条目
     */
    private fun setupTabs() {
        tabs?.setOnCustomTabListener(object : PagerSlidingTabStrip.OnCustomTabListener() {
            override fun getTabLayoutResId(position: Int): Int {
                return R.layout.tab_layout_main
            }

            override fun screenAdaptation(): Boolean {
                return true
            }
        })
        tabs?.setViewPager(pager)
        tabs?.setOnTabClickListener(adapter)
        tabs?.setOnTabDoubleTapListener(adapter)
    }

    override fun onPageScrolled(position: Int, positionOffset: Float, positionOffsetPixels: Int) { // TO TABS
        tabs?.onPageScrolled(position, positionOffset, positionOffsetPixels)
        // TO ADAPTER
        adapter?.onPageScrolled(position)
    }

    override fun onPageSelected(position: Int) { // TO TABS
        tabs?.onPageSelected(position)
        selectPage(position)
        //        enableMsgNotification(false);
    }

    override fun onPageScrollStateChanged(state: Int) { // TO TABS
        tabs?.onPageScrollStateChanged(state)
        scrollState = state
        selectPage(pager!!.currentItem)
    }

    private fun selectPage(page: Int) { // TO PAGE
        if (scrollState == ViewPager.SCROLL_STATE_IDLE) {
            adapter?.onPageSelected(pager!!.currentItem)
        }
    }

    private fun updateReminder(item: ReminderItem?, id: Int) {
        val tab: MainTab? = MainTab.fromReminderId(id)
        if (tab != null) {
            tabs?.updateTab(tab.tabIndex, item)
        }
    }

    companion object {
        const val EXTRA_MESSAGE = "EXTRA_MESSAGE"
        fun start(context: Context, message: IMMessage?) {
            val intent = Intent()
            intent.setClass(context, AckMsgInfoActivity::class.java)
            intent.putExtra(EXTRA_MESSAGE, message)
            context.startActivity(intent)
        }
    }
}