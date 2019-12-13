package com.youxi.chat.module.main.activity

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.text.TextUtils
import android.view.Menu
import android.view.MenuItem
import androidx.viewpager.widget.ViewPager
import androidx.viewpager.widget.ViewPager.OnPageChangeListener
import com.alibaba.fastjson.JSONException
import com.alibaba.fastjson.JSONObject
import com.netease.nim.avchatkit.AVChatProfile
import com.netease.nim.avchatkit.activity.AVChatActivity
import com.netease.nim.avchatkit.constant.AVChatExtras
import com.netease.nim.uikit.api.model.main.LoginSyncDataStatusObserver
import com.netease.nim.uikit.business.contact.selector.activity.ContactSelectActivity
import com.netease.nim.uikit.common.ToastHelper
import com.netease.nim.uikit.common.activity.ToolBarOptions
import com.netease.nim.uikit.common.activity.UI
import com.netease.nim.uikit.common.ui.dialog.DialogMaker
import com.netease.nim.uikit.common.ui.drop.DropManager
import com.netease.nim.uikit.common.util.log.LogUtil
import com.netease.nim.uikit.support.permission.MPermission
import com.netease.nim.uikit.support.permission.annotation.OnMPermissionDenied
import com.netease.nim.uikit.support.permission.annotation.OnMPermissionGranted
import com.netease.nim.uikit.support.permission.annotation.OnMPermissionNeverAskAgain
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.NimIntent
import com.netease.nimlib.sdk.Observer
import com.netease.nimlib.sdk.msg.MsgService
import com.netease.nimlib.sdk.msg.MsgServiceObserve
import com.netease.nimlib.sdk.msg.SystemMessageObserver
import com.netease.nimlib.sdk.msg.SystemMessageService
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum
import com.netease.nimlib.sdk.msg.model.CustomNotification
import com.netease.nimlib.sdk.msg.model.IMMessage
import com.netease.nimlib.sdk.msg.model.RecentContact
import com.youxi.chat.R
import com.youxi.chat.config.preference.Preferences
import com.youxi.chat.module.login.LoginHelper
import com.youxi.chat.module.main.activity.MainActivity
import com.youxi.chat.module.main.adapter.MainTabPagerAdapter
import com.youxi.chat.module.main.model.MainTab
import com.youxi.chat.module.main.model.MainTab.Companion.fromReminderId
import com.youxi.chat.module.main.reminder.ReminderItem
import com.youxi.chat.module.main.reminder.ReminderManager
import com.youxi.chat.module.main.reminder.ReminderManager.UnreadNumChangedCallback
import com.youxi.chat.module.session.CustomNotificationCache
import com.youxi.chat.module.session.SessionHelper.startP2PSession
import com.youxi.chat.module.session.SessionHelper.startTeamSession
import com.youxi.chat.module.session.SystemMessageUnreadManager
import com.youxi.chat.widget.viewpager.FadeInOutPageTransformer
import com.youxi.chat.widget.viewpager.PagerSlidingTabStrip
import com.youxi.chat.widget.viewpager.PagerSlidingTabStrip.OnCustomTabListener

/**
 * 主界面
 * Created by huangjun on 2015/3/25.
 */
class MainActivity : UI(), OnPageChangeListener, UnreadNumChangedCallback {
    private var tabs: PagerSlidingTabStrip? = null
    private var pager: ViewPager? = null
    private var scrollState = 0
    private var adapter: MainTabPagerAdapter? = null
    private var isFirstIn = false
    private val sysMsgUnreadCountChangedObserver = Observer { unreadCount: Int? ->
        SystemMessageUnreadManager.instance.sysMsgUnreadCount = unreadCount!!
        ReminderManager.instance!!.updateContactUnreadNum(unreadCount)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.main)
//        setToolBar(R.id.toolbar, R.string.app_name, 0)
        setToolBar(R.id.toolbar, ToolBarOptions().apply { this.titleId = R.string.app_name })
        toolBar.setTitleTextAppearance(this, R.style.title_text_style)
        setTitle(R.string.app_name)
        isFirstIn = true
        //不保留后台活动，从厂商推送进聊天页面，会无法退出聊天页面
        if (savedInstanceState == null && parseIntent()) {
            return
        }
        init()
    }

    private fun init() {
        observerSyncDataComplete()
        findViews()
        setupPager()
        setupTabs()
        registerMsgUnreadInfoObserver(true)
        registerSystemMessageObservers(true)
        registerCustomMessageObservers(true)
        requestSystemMessageUnreadCount()
        initUnreadCover()
        requestBasicPermission()
    }

    private fun parseIntent(): Boolean {
        val intent = intent
        if (intent.hasExtra(EXTRA_APP_QUIT)) {
            intent.removeExtra(EXTRA_APP_QUIT)
            onLogout()
            return true
        }
        if (intent.hasExtra(NimIntent.EXTRA_NOTIFY_CONTENT)) {
            val message = intent.getSerializableExtra(
                    NimIntent.EXTRA_NOTIFY_CONTENT) as IMMessage
            intent.removeExtra(NimIntent.EXTRA_NOTIFY_CONTENT)
            when (message.sessionType) {
                SessionTypeEnum.P2P -> startP2PSession(this, message.sessionId)
                SessionTypeEnum.Team -> startTeamSession(this, message.sessionId)
            }
            return true
        }
        if (intent.hasExtra(AVChatActivity.INTENT_ACTION_AVCHAT) &&
                AVChatProfile.getInstance().isAVChatting) {
            intent.removeExtra(AVChatActivity.INTENT_ACTION_AVCHAT)
            val localIntent = Intent()
            localIntent.setClass(this, AVChatActivity::class.java)
            startActivity(localIntent)
            return true
        }
        val account = intent.getStringExtra(AVChatExtras.EXTRA_ACCOUNT)
        if (intent.hasExtra(AVChatExtras.EXTRA_FROM_NOTIFICATION) && !TextUtils.isEmpty(account)) {
            intent.removeExtra(AVChatExtras.EXTRA_FROM_NOTIFICATION)
            startP2PSession(this, account)
            return true
        }
        return false
    }

    private fun observerSyncDataComplete() {
        val syncCompleted = LoginSyncDataStatusObserver.getInstance()
                .observeSyncDataCompletedEvent(
                        Observer { v: Void? ->
                            DialogMaker
                                    .dismissProgressDialog()
                        })
        //如果数据没有同步完成，弹个进度Dialog
        if (!syncCompleted) {
            DialogMaker.showProgressDialog(this@MainActivity, getString(R.string.prepare_data))
                    .setCanceledOnTouchOutside(false)
        }
    }

    private fun findViews() {
        tabs = findView(R.id.tabs)
        pager = findView(R.id.main_tab_pager)
    }

    private fun setupPager() {
        adapter = MainTabPagerAdapter(supportFragmentManager, this, pager)
        pager!!.offscreenPageLimit = adapter!!.cacheCount
        pager!!.setPageTransformer(true, FadeInOutPageTransformer())
        pager!!.adapter = adapter
        pager!!.addOnPageChangeListener(this)
    }

    private fun setupTabs() {
        // 去掉Tabs的下划线
        tabs!!.indicatorHeight = 0
        tabs!!.underlineHeight = 0
        tabs!!.setOnCustomTabListener(object : OnCustomTabListener() {
            override fun getTabLayoutResId(position: Int): Int {
                return R.layout.tab_layout_main
            }

            override fun screenAdaptation(): Boolean {
                return true
            }
        })
        tabs!!.setViewPager(pager)
        tabs!!.setOnTabClickListener(adapter)
        tabs!!.setOnTabDoubleTapListener(adapter)
    }

    /**
     * 注册未读消息数量观察者
     */
    private fun registerMsgUnreadInfoObserver(register: Boolean) {
        if (register) {
            ReminderManager.instance!!.registerUnreadNumChangedCallback(this)
        } else {
            ReminderManager.instance!!.unregisterUnreadNumChangedCallback(this)
        }
    }

    /**
     * 注册/注销系统消息未读数变化
     */
    private fun registerSystemMessageObservers(register: Boolean) {
        NIMClient.getService(SystemMessageObserver::class.java).observeUnreadCountChange(
                sysMsgUnreadCountChangedObserver, register)
    }

    // sample
    var customNotificationObserver = Observer { notification: CustomNotification ->
        // 处理自定义通知消息
        LogUtil.i("demo", "receive custom notification: " + notification.content + " from :" +
                notification.sessionId + "/" + notification.sessionType +
                "unread=" + notification.config.enableUnreadCount + " " + "push=" +
                notification.config.enablePush + " nick=" +
                notification.config.enablePushNick)
        try {
            val obj = JSONObject.parseObject(notification.content)
            if (obj != null && obj.getIntValue("id") == 2) { // 加入缓存中
                CustomNotificationCache.instance.addCustomNotification(notification)
                // Toast
                val content = obj.getString("content")
                val tip = String.format("自定义消息[%s]：%s", notification.fromAccount, content)
                ToastHelper.showToast(this@MainActivity, tip)
            }
        } catch (e: JSONException) {
            LogUtil.e("demo", e.message)
        }
    } as Observer<CustomNotification>

    private fun registerCustomMessageObservers(register: Boolean) {
        NIMClient.getService(MsgServiceObserve::class.java).observeCustomNotification(
                customNotificationObserver, register)
    }

    /**
     * 查询系统消息未读数
     */
    private fun requestSystemMessageUnreadCount() {
        val unread = NIMClient.getService(SystemMessageService::class.java)
                .querySystemMessageUnreadCountBlock()
        SystemMessageUnreadManager.instance.sysMsgUnreadCount = unread
        ReminderManager.instance!!.updateContactUnreadNum(unread)
    }

    //初始化未读红点动画
    private fun initUnreadCover() {
        DropManager.getInstance().init(this, findView(R.id.unread_cover)) { id: Any?, explosive: Boolean ->
            if (id == null || !explosive) {
                return@init
            }
            if (id is RecentContact) {
                val r = id
                NIMClient.getService(MsgService::class.java).clearUnreadCount(r.contactId,
                        r.sessionType)
                return@init
            }
            if (id is String) {
                if (id.contentEquals("0")) {
                    NIMClient.getService(MsgService::class.java).clearAllUnreadCount()
                } else if (id.contentEquals("1")) {
                    NIMClient.getService(SystemMessageService::class.java)
                            .resetSystemMessageUnreadCount()
                }
            }
        }
    }

    private fun requestBasicPermission() {
        MPermission.printMPermissionResult(true, this, BASIC_PERMISSIONS)
        MPermission.with(this@MainActivity).setRequestCode(BASIC_PERMISSION_REQUEST_CODE)
                .permissions(*BASIC_PERMISSIONS).request()
    }

    private fun onLogout() {
        Preferences.saveUserToken("");
        // 清理缓存&注销监听
        LoginHelper.logout();
        // 启动登录
        LoginHelper.gotoLogin(this);
        finish();
    }

    private fun selectPage() {
        if (scrollState == ViewPager.SCROLL_STATE_IDLE) {
            adapter!!.onPageSelected(pager!!.currentItem)
        }
    }

    /**
     * 设置最近联系人的消息为已读
     *
     *
     * account, 聊天对象帐号，或者以下两个值：
     * [MsgService.MSG_CHATTING_ACCOUNT_ALL] 目前没有与任何人对话，但能看到消息提醒（比如在消息列表界面），不需要在状态栏做消息通知
     * [MsgService.MSG_CHATTING_ACCOUNT_NONE] 目前没有与任何人对话，需要状态栏消息通知
     */
    private fun enableMsgNotification(enable: Boolean) {
        val msg = pager!!.currentItem != MainTab.RECENT_CONTACTS.tabIndex
        if (enable or msg) {
            NIMClient.getService(MsgService::class.java).setChattingAccount(
                    MsgService.MSG_CHATTING_ACCOUNT_NONE, SessionTypeEnum.None)
        } else {
            NIMClient.getService(MsgService::class.java).setChattingAccount(
                    MsgService.MSG_CHATTING_ACCOUNT_ALL, SessionTypeEnum.None)
        }
    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        val inflater = menuInflater
        inflater.inflate(R.menu.main_activity_menu, menu)
        super.onCreateOptionsMenu(menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        when (item.itemId) {
            else -> {
            }
        }
        return super.onOptionsItemSelected(item)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        parseIntent()
    }

    public override fun onResume() {
        super.onResume()
        // 第一次 ， 三方通知唤起进会话页面之类的，不会走初始化过程
        val temp = isFirstIn
        isFirstIn = false
        if (pager == null && temp) {
            return
        }
        //如果不是第一次进 ， eg: 其他页面back
        if (pager == null) {
            init()
        }
        enableMsgNotification(false)
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        outState.clear()
    }

    public override fun onPause() {
        super.onPause()
        if (pager == null) {
            return
        }
        enableMsgNotification(true)
    }

    public override fun onDestroy() {
        registerMsgUnreadInfoObserver(false)
        registerSystemMessageObservers(false)
        registerCustomMessageObservers(false)
        DropManager.getInstance().destroy()
        super.onDestroy()
    }

    public override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode != Activity.RESULT_OK) {
            return
        }
        if (requestCode == REQUEST_CODE_NORMAL) {
            val selected = data!!.getStringArrayListExtra(
                    ContactSelectActivity.RESULT_DATA)
            if (selected != null && !selected.isEmpty()) {
                // TODO 创建群
//                TeamCreateHelper.createNormalTeam(MainActivity.this, selected, false, null);
            } else {
                ToastHelper.showToast(this@MainActivity, "请选择至少一个联系人！")
            }
        } else if (requestCode == REQUEST_CODE_ADVANCED) {
            val selected = data!!.getStringArrayListExtra(
                    ContactSelectActivity.RESULT_DATA)
            // TODO 创建群
//            TeamCreateHelper.createAdvancedTeam(MainActivity.this, selected);
        }
    }

    override fun onPageScrolled(position: Int, positionOffset: Float, positionOffsetPixels: Int) {
        tabs!!.onPageScrolled(position, positionOffset, positionOffsetPixels)
        adapter!!.onPageScrolled(position)
    }

    override fun onPageSelected(position: Int) {
        tabs!!.onPageSelected(position)
        selectPage()
        enableMsgNotification(false)
    }

    override fun onPageScrollStateChanged(state: Int) {
        tabs!!.onPageScrollStateChanged(state)
        scrollState = state
        selectPage()
    }

    //未读消息数量观察者实现
    override fun onUnreadNumChanged(item: ReminderItem?) {
        val tab = fromReminderId(item!!.id)
        if (tab != null) {
            tabs!!.updateTab(tab.tabIndex, item)
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>,
                                            grantResults: IntArray) {
        MPermission.onRequestPermissionsResult(this, requestCode, permissions, grantResults)
    }

    @OnMPermissionGranted(BASIC_PERMISSION_REQUEST_CODE)
    fun onBasicPermissionSuccess() {
        try {
            ToastHelper.showToast(this, "授权成功")
        } catch (e: Exception) {
            e.printStackTrace()
        }
        MPermission.printMPermissionResult(false, this, BASIC_PERMISSIONS)
    }

    @OnMPermissionDenied(BASIC_PERMISSION_REQUEST_CODE)
    @OnMPermissionNeverAskAgain(BASIC_PERMISSION_REQUEST_CODE)
    fun onBasicPermissionFailed() {
        try {
            ToastHelper.showToast(this, "未全部授权，部分功能可能无法正常运行！")
        } catch (e: Exception) {
            e.printStackTrace()
        }
        MPermission.printMPermissionResult(false, this, BASIC_PERMISSIONS)
    }

    override fun displayHomeAsUpEnabled(): Boolean {
        return false
    }

    companion object {
        private const val EXTRA_APP_QUIT = "APP_QUIT"
        private const val REQUEST_CODE_NORMAL = 1
        private const val REQUEST_CODE_ADVANCED = 2
        private const val BASIC_PERMISSION_REQUEST_CODE = 100
        private val BASIC_PERMISSIONS = arrayOf(
                Manifest.permission.WRITE_EXTERNAL_STORAGE,
                Manifest.permission.READ_EXTERNAL_STORAGE,
                Manifest.permission.CAMERA,
                Manifest.permission.READ_PHONE_STATE,
                Manifest.permission.RECORD_AUDIO,
                Manifest.permission.ACCESS_COARSE_LOCATION,
                Manifest.permission.ACCESS_FINE_LOCATION)

        @JvmOverloads
        fun start(context: Context, extras: Intent? = null) {
            val intent = Intent()
            intent.setClass(context, MainActivity::class.java)
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            if (extras != null) {
                intent.putExtras(extras)
            }
            context.startActivity(intent)
        }

        // 注销
        fun logout(context: Context, quit: Boolean) {
            val extra = Intent()
            extra.putExtra(EXTRA_APP_QUIT, quit)
            start(context, extra)
        }
    }
}