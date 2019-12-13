package com.youxi.chat.module.session

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Build
import android.text.TextUtils
import android.view.View
import com.netease.nim.avchatkit.TeamAVChatProfile
import com.netease.nim.uikit.api.NimUIKit
import com.netease.nim.uikit.api.model.recent.RecentCustomization
import com.netease.nim.uikit.api.model.session.SessionCustomization
import com.netease.nim.uikit.api.model.session.SessionCustomization.OptionsButton
import com.netease.nim.uikit.api.model.session.SessionEventListener
import com.netease.nim.uikit.api.wrapper.NimMessageRevokeObserver
import com.netease.nim.uikit.business.session.actions.BaseAction
import com.netease.nim.uikit.business.session.helper.MessageListPanelHelper
import com.netease.nim.uikit.business.session.module.IMultiRetweetMsgCreator
import com.netease.nim.uikit.business.session.module.MsgForwardFilter
import com.netease.nim.uikit.business.session.module.MsgRevokeFilter
import com.netease.nim.uikit.business.team.model.TeamExtras
import com.netease.nim.uikit.business.team.model.TeamRequestCode
import com.netease.nim.uikit.common.ui.dialog.CustomAlertDialog
import com.netease.nim.uikit.common.ui.dialog.EasyAlertDialogHelper
import com.netease.nim.uikit.common.ui.dialog.EasyAlertDialogHelper.OnDialogActionListener
import com.netease.nim.uikit.common.ui.popupmenu.NIMPopupMenu
import com.netease.nim.uikit.common.ui.popupmenu.NIMPopupMenu.MenuItemClickListener
import com.netease.nim.uikit.common.ui.popupmenu.PopupMenuItem
import com.netease.nim.uikit.common.util.sys.TimeUtil
import com.netease.nim.uikit.impl.cache.TeamDataCache
import com.netease.nim.uikit.impl.customization.DefaultRecentCustomization
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.avchat.constant.AVChatRecordState
import com.netease.nimlib.sdk.avchat.constant.AVChatType
import com.netease.nimlib.sdk.avchat.model.AVChatAttachment
import com.netease.nimlib.sdk.msg.MsgService
import com.netease.nimlib.sdk.msg.MsgServiceObserve
import com.netease.nimlib.sdk.msg.attachment.FileAttachment
import com.netease.nimlib.sdk.msg.attachment.MsgAttachment
import com.netease.nimlib.sdk.msg.constant.MsgDirectionEnum
import com.netease.nimlib.sdk.msg.constant.MsgTypeEnum
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum
import com.netease.nimlib.sdk.msg.model.IMMessage
import com.netease.nimlib.sdk.msg.model.RecentContact
import com.netease.nimlib.sdk.robot.model.RobotAttachment
import com.netease.nimlib.sdk.team.constant.TeamTypeEnum
import com.youxi.chat.R
import com.youxi.chat.module.session.action.*
import com.youxi.chat.module.session.activity.AckMsgInfoActivity
import com.youxi.chat.module.session.extension.*
import com.youxi.chat.module.session.viewholder.*
import com.youxi.chat.nim.NimCache
import java.util.*

/**
 * UIKit自定义消息界面用法展示类
 */
object SessionHelper {
    private const val ACTION_HISTORY_QUERY = 0
    private const val ACTION_SEARCH_MESSAGE = 1
    private const val ACTION_CLEAR_MESSAGE = 2
    private const val ACTION_CLEAR_P2P_MESSAGE = 3
    private var p2pCustomization: SessionCustomization? = null
    private var normalTeamCustomization: SessionCustomization? = null
    private var advancedTeamCustomization: SessionCustomization? = null
    private var myP2pCustomization: SessionCustomization? = null
    private var robotCustomization: SessionCustomization? = null
    // 未接通话请求
    private var recentCustomization: RecentCustomization? = null
        private get() {
            if (field == null) {
                field = object : DefaultRecentCustomization() {
                    override fun getDefaultDigest(recent: RecentContact): String {
                        when (recent.msgType) {
                            MsgTypeEnum.avchat -> {
                                val attachment = recent.attachment
                                val avchat: AVChatAttachment = attachment as AVChatAttachment
                                return if (avchat.getState() === AVChatRecordState.Missed && recent.fromAccount != NimUIKit.getAccount()) { // 未接通话请求
                                    val sb = StringBuilder("[未接")
                                    if (avchat.getType() === AVChatType.VIDEO) {
                                        sb.append("视频电话]")
                                    } else {
                                        sb.append("音频电话]")
                                    }
                                    sb.toString()
                                } else if (avchat.getState() === AVChatRecordState.Success) {
                                    val sb = StringBuilder()
                                    if (avchat.getType() === AVChatType.VIDEO) {
                                        sb.append("[视频电话]: ")
                                    } else {
                                        sb.append("[音频电话]: ")
                                    }
                                    sb.append(TimeUtil.secToTime(avchat.getDuration()))
                                    sb.toString()
                                } else {
                                    if (avchat.getType() === AVChatType.VIDEO) {
                                        "[视频电话]"
                                    } else {
                                        "[音频电话]"
                                    }
                                }
                            }
                        }
                        return super.getDefaultDigest(recent)
                    }
                }
            }
            return field
        }
    private var popupMenu: NIMPopupMenu? = null
    private var menuItemList: MutableList<PopupMenuItem>? = null
    const val USE_LOCAL_ANTISPAM = true
    fun init() {
        // 注册自定义消息附件解析器
        NIMClient.getService(MsgService::class.java).registerCustomAttachmentParser(CustomAttachParser())
        // 注册各种扩展消息类型的显示ViewHolder
        registerViewHolders()
        // 设置会话中点击事件响应处理
        setSessionListener()
        // 注册消息转发过滤器
        registerMsgForwardFilter()
        // 注册消息撤回过滤器
        registerMsgRevokeFilter()
        // 注册消息撤回监听器
        registerMsgRevokeObserver()
        NimUIKit.setCommonP2PSessionCustomization(getP2pCustomization())
        NimUIKit.setCommonTeamSessionCustomization(getTeamCustomization(null))
        NimUIKit.setRecentCustomization(recentCustomization)
    }

    @JvmOverloads
    fun startP2PSession(context: Context?, account: String?, anchor: IMMessage? = null) {
        if (!NimCache.getAccount().equals(account)) {
            if (NimUIKit.getRobotInfoProvider().getRobotByAccount(account) != null) {
                NimUIKit.startChatting(context, account, SessionTypeEnum.P2P, getRobotCustomization(), anchor)
            } else {
                NimUIKit.startP2PSession(context, account, anchor)
            }
        } else {
            NimUIKit.startChatting(context, account, SessionTypeEnum.P2P, getMyP2pCustomization(), anchor)
        }
    }

    @JvmOverloads
    fun startTeamSession(context: Context?, tid: String?, anchor: IMMessage? = null) {
        NimUIKit.startTeamSession(context, tid, getTeamCustomization(tid), anchor)
    }

    // 打开群聊界面(用于 UIKIT 中部分界面跳转回到指定的页面)
    fun startTeamSession(context: Context?, tid: String?, backToClass: Class<out Activity?>?,
                         anchor: IMMessage?) {
        NimUIKit.startChatting(context, tid, SessionTypeEnum.Team, getTeamCustomization(tid), backToClass, anchor)
    }

    // 定制化单聊界面。如果使用默认界面，返回null即可
    private fun getP2pCustomization(): SessionCustomization? {
        if (p2pCustomization == null) {
            p2pCustomization = object : SessionCustomization() {
                // 由于需要Activity Result， 所以重载该函数。
                override fun onActivityResult(activity: Activity, requestCode: Int, resultCode: Int, data: Intent) {
                    super.onActivityResult(activity, requestCode, resultCode, data)
                }

                override fun isAllowSendMessage(message: IMMessage): Boolean {
                    return checkLocalAntiSpam(message)
                }

                override fun createStickerAttachment(category: String, item: String): MsgAttachment {
                    return StickerAttachment(category, item)
                }
            }
            // 背景
//            p2pCustomization.backgroundColor = Color.BLUE;
//            p2pCustomization.backgroundUri = "file:///android_asset/xx/bk.jpg";
//            p2pCustomization.backgroundUri = "file:///sdcard/Pictures/bk.png";
//            p2pCustomization.backgroundUri = "android.resource://com.netease.nim.demo/drawable/bk"
// 定制加号点开后可以包含的操作， 默认已经有图片，视频等消息了
            val actions = ArrayList<BaseAction>()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.ICE_CREAM_SANDWICH) {
                actions.add(AVChatAction(AVChatType.AUDIO))
                actions.add(AVChatAction(AVChatType.VIDEO))
            }
            actions.add(RTSAction())
            actions.add(SnapChatAction())
            actions.add(GuessAction())
            actions.add(FileAction())
            actions.add(TipAction())
            // TODO 添加红包Aciton
//            if (NIMRedPacketClient.isEnable()) {
//                actions.add(RedPacketAction())
//            }
            p2pCustomization?.actions = actions
            p2pCustomization?.withSticker = true
            // 定制ActionBar右边的按钮，可以加多个
            val buttons = ArrayList<OptionsButton>()
            val cloudMsgButton: OptionsButton = object : OptionsButton() {
                override fun onClick(context: Context, view: View, sessionId: String) {
                    initPopuptWindow(context, view, sessionId, SessionTypeEnum.P2P)
                }
            }
            cloudMsgButton.iconId = R.drawable.nim_ic_messge_history
            val infoButton: OptionsButton = object : OptionsButton() {
                override fun onClick(context: Context, view: View, sessionId: String) {
                    // TODO 聊天信息页面
//                    MessageInfoActivity.startActivity(context, sessionId) //打开聊天信息
                }
            }
            infoButton.iconId = R.drawable.nim_ic_message_actionbar_p2p_add
            buttons.add(cloudMsgButton)
            buttons.add(infoButton)
            p2pCustomization?.buttons = buttons
        }
        return p2pCustomization
    }

    private fun getMyP2pCustomization(): SessionCustomization? {
        if (myP2pCustomization == null) {
            myP2pCustomization = object : SessionCustomization() {
                // 由于需要Activity Result， 所以重载该函数。
                override fun onActivityResult(activity: Activity, requestCode: Int, resultCode: Int, data: Intent) {
                    if (requestCode == TeamRequestCode.REQUEST_CODE && resultCode == Activity.RESULT_OK) {
                        val result = data.getStringExtra(TeamExtras.RESULT_EXTRA_REASON) ?: return
                        if (result == TeamExtras.RESULT_EXTRA_REASON_CREATE) {
                            val tid = data.getStringExtra(TeamExtras.RESULT_EXTRA_DATA)
                            if (TextUtils.isEmpty(tid)) {
                                return
                            }
                            startTeamSession(activity, tid)
                            activity.finish()
                        }
                    }
                }

                override fun isAllowSendMessage(message: IMMessage): Boolean {
                    return checkLocalAntiSpam(message)
                }

                override fun createStickerAttachment(category: String, item: String): MsgAttachment {
                    return StickerAttachment(category, item)
                }
            }
            // 定制加号点开后可以包含的操作， 默认已经有图片，视频等消息了
            val actions = ArrayList<BaseAction>()
            actions.add(SnapChatAction())
            actions.add(GuessAction())
            actions.add(FileAction())
            myP2pCustomization?.actions = actions
            myP2pCustomization?.withSticker = true
            // 定制ActionBar右边的按钮，可以加多个
            val buttons = ArrayList<OptionsButton>()
            val cloudMsgButton: OptionsButton = object : OptionsButton() {
                override fun onClick(context: Context, view: View, sessionId: String) {
                    initPopuptWindow(context, view, sessionId, SessionTypeEnum.P2P)
                }
            }
            cloudMsgButton.iconId = R.drawable.nim_ic_messge_history
            buttons.add(cloudMsgButton)
            myP2pCustomization?.buttons = buttons
        }
        return myP2pCustomization
    }

    private fun checkLocalAntiSpam(message: IMMessage): Boolean {
        if (!USE_LOCAL_ANTISPAM) {
            return true
        }
        val result = NIMClient.getService(MsgService::class.java).checkLocalAntiSpam(message.content,
                "**")
        val operator = result?.operator ?: 0
        when (operator) {
            1 -> {
                message.content = result!!.content
                return true
            }
            2 -> return false
            3 -> {
                message.setClientAntiSpam(true)
                return true
            }
            0 -> {
            }
            else -> {
            }
        }
        return true
    }

    private fun getRobotCustomization(): SessionCustomization? {
        if (robotCustomization == null) {
            robotCustomization = object : SessionCustomization() {
                // 由于需要Activity Result， 所以重载该函数。
                override fun onActivityResult(activity: Activity, requestCode: Int, resultCode: Int, data: Intent) {
                    super.onActivityResult(activity, requestCode, resultCode, data)
                }

                override fun createStickerAttachment(category: String, item: String):
                        MsgAttachment? {
                    return null
                }
            }
            // 定制ActionBar右边的按钮，可以加多个
            val buttons = ArrayList<OptionsButton>()
            val cloudMsgButton: OptionsButton = object : OptionsButton() {
                override fun onClick(context: Context, view: View, sessionId: String) {
                    initPopuptWindow(context, view, sessionId, SessionTypeEnum.P2P)
                }
            }
            cloudMsgButton.iconId = R.drawable.nim_ic_messge_history
            val infoButton: OptionsButton = object : OptionsButton() {
                override fun onClick(context: Context, view: View, sessionId: String) {
                    // TODO 机器人资料页
//                    RobotProfileActivity.start(context, sessionId) //打开聊天信息
                }
            }
            infoButton.iconId = R.drawable.nim_ic_actionbar_robot_info
            buttons.add(cloudMsgButton)
            buttons.add(infoButton)
            robotCustomization?.buttons = buttons
        }
        return robotCustomization
    }

    private fun getTeamCustomization(tid: String?): SessionCustomization? {
        if (normalTeamCustomization == null) { // 定制加号点开后可以包含的操作， 默认已经有图片，视频等消息了
            val avChatAction = TeamAVChatAction(AVChatType.VIDEO)
            TeamAVChatProfile.sharedInstance().registerObserver(true)
            val actions = ArrayList<BaseAction>()
            actions.add(avChatAction)
            actions.add(GuessAction())
            actions.add(FileAction())
            // TODO 添加红包Action
//            if (NIMRedPacketClient.isEnable()) {
//                actions.add(RedPacketAction())
//            }
            actions.add(TipAction())
            val listener: SessionTeamCustomization.SessionTeamCustomListener = object : SessionTeamCustomization.SessionTeamCustomListener {
                override fun initPopupWindow(context: Context, view: View, sessionId: String,
                                    sessionTypeEnum: SessionTypeEnum) {
                    initPopuptWindow(context, view, sessionId, sessionTypeEnum)
                }

                override fun onSelectedAccountsResult(selectedAccounts: ArrayList<String>) {
                    avChatAction.onSelectedAccountsResult(selectedAccounts)
                }

                override fun onSelectedAccountFail() {
                    avChatAction.onSelectedAccountFail()
                }
            }
            normalTeamCustomization = object : SessionTeamCustomization(listener) {
                override fun isAllowSendMessage(message: IMMessage): Boolean {
                    return checkLocalAntiSpam(message)
                }
            }
            normalTeamCustomization!!.actions = actions
        }
        if (advancedTeamCustomization == null) { // 定制加号点开后可以包含的操作， 默认已经有图片，视频等消息了
            val avChatAction = TeamAVChatAction(AVChatType.VIDEO)
            TeamAVChatProfile.sharedInstance().registerObserver(true)
            val actions = ArrayList<BaseAction>()
            actions.add(avChatAction)
            actions.add(GuessAction())
            actions.add(FileAction())
            actions.add(AckMessageAction())
            // TODO 添加红包Action
//            if (NIMRedPacketClient.isEnable()) {
//                actions.add(RedPacketAction())
//            }
            actions.add(TipAction())
            val listener: SessionTeamCustomization.SessionTeamCustomListener = object : SessionTeamCustomization.SessionTeamCustomListener {
                override fun initPopupWindow(context: Context, view: View, sessionId: String,
                                    sessionTypeEnum: SessionTypeEnum) {
                    initPopuptWindow(context, view, sessionId, sessionTypeEnum)
                }

                override fun onSelectedAccountsResult(selectedAccounts: ArrayList<String>) {
                    avChatAction.onSelectedAccountsResult(selectedAccounts)
                }

                override fun onSelectedAccountFail() {
                    avChatAction.onSelectedAccountFail()
                }
            }
            advancedTeamCustomization = object : SessionTeamCustomization(listener) {
                override fun isAllowSendMessage(message: IMMessage): Boolean {
                    return checkLocalAntiSpam(message)
                }
            }
            advancedTeamCustomization!!.actions = actions
        }
        if (TextUtils.isEmpty(tid)) {
            return normalTeamCustomization
        } else {
            val team = TeamDataCache.getInstance().getTeamById(tid)
            if (team != null && team.type == TeamTypeEnum.Advanced) {
                return advancedTeamCustomization
            }
        }
        return normalTeamCustomization
    }

    private fun registerViewHolders() {
        NimUIKit.registerMsgItemViewHolder(FileAttachment::class.java, MsgViewHolderFile::class.java)
        NimUIKit.registerMsgItemViewHolder(AVChatAttachment::class.java, MsgViewHolderAVChat::class.java)
        NimUIKit.registerMsgItemViewHolder(GuessAttachment::class.java, MsgViewHolderGuess::class.java)
        NimUIKit.registerMsgItemViewHolder(CustomAttachment::class.java, MsgViewHolderDefCustom::class.java)
        NimUIKit.registerMsgItemViewHolder(StickerAttachment::class.java, MsgViewHolderSticker::class.java)
        NimUIKit.registerMsgItemViewHolder(SnapChatAttachment::class.java, MsgViewHolderSnapChat::class.java)
        NimUIKit.registerMsgItemViewHolder(RTSAttachment::class.java, MsgViewHolderRTS::class.java)
        NimUIKit.registerMsgItemViewHolder(MultiRetweetAttachment::class.java, MsgViewHolderMultiRetweet::class.java)
        NimUIKit.registerTipMsgViewHolder(MsgViewHolderTip::class.java)
        registerRedPacketViewHolder()
        registerMultiRetweetCreator()
    }

    private fun registerRedPacketViewHolder() {
        // TODO 红包消息
//        if (NIMRedPacketClient.isEnable()) {
//            NimUIKit.registerMsgItemViewHolder(RedPacketAttachment::class.java, MsgViewHolderRedPacket::class.java)
//            NimUIKit.registerMsgItemViewHolder(RedPacketOpenedAttachment::class.java, MsgViewHolderOpenRedPacket::class.java)
//        } else {
//            NimUIKit.registerMsgItemViewHolder(RedPacketAttachment::class.java, MsgViewHolderUnknown::class.java)
//            NimUIKit.registerMsgItemViewHolder(RedPacketOpenedAttachment::class.java, MsgViewHolderUnknown::class.java)
//        }
    }

    private fun registerMultiRetweetCreator() {
        val creator = IMultiRetweetMsgCreator { msgList, shouldEncrypt, callback -> MessageHelper.createMultiRetweet(msgList, shouldEncrypt, callback) }
        NimUIKit.registerCustomMsgCreator(creator)
    }

    private fun setSessionListener() {
        // TODO 机器人和用户资料页
        val listener: SessionEventListener = object : SessionEventListener {
            override fun onAvatarClicked(context: Context, message: IMMessage) { // 一般用于打开用户资料页面
                if (message.msgType == MsgTypeEnum.robot && message.direct == MsgDirectionEnum.In) {
                    val attachment = message.attachment as RobotAttachment
                    if (attachment.isRobotSend) {
//                        RobotProfileActivity.start(context, attachment.fromRobotAccount)
                        return
                    }
                }
//                UserProfileActivity.start(context, message.fromAccount)
            }

            override fun onAvatarLongClicked(context: Context, message: IMMessage) { // 一般用于群组@功能，或者弹出菜单，做拉黑，加好友等功能
            }

            override fun onAckMsgClicked(context: Context, message: IMMessage) { // 已读回执事件处理，用于群组的已读回执事件的响应，弹出消息已读详情
                AckMsgInfoActivity.start(context, message)
            }
        }
        NimUIKit.setSessionListener(listener)
    }

    /**
     * 消息转发过滤器
     */
    private fun registerMsgForwardFilter() {
        NimUIKit.setMsgForwardFilter(MsgForwardFilter { message ->
            if (message.msgType == MsgTypeEnum.custom && message.attachment != null &&
                    (message.attachment is SnapChatAttachment ||
                            message.attachment is RTSAttachment ||
                            message.attachment is RedPacketAttachment)) { // 白板消息和阅后即焚消息，红包消息 不允许转发
                return@MsgForwardFilter true
            } else if (message.msgType == MsgTypeEnum.robot && message.attachment != null &&
                    (message.attachment as RobotAttachment).isRobotSend) {
                return@MsgForwardFilter true // 如果是机器人发送的消息 不支持转发
            }
            false
        })
    }

    /**
     * 消息撤回过滤器
     */
    private fun registerMsgRevokeFilter() {
        NimUIKit.setMsgRevokeFilter(MsgRevokeFilter { message ->
            if (message.attachment != null && (message.attachment is AVChatAttachment ||
                            message.attachment is RTSAttachment ||
                            message.attachment is RedPacketAttachment)) { // 视频通话消息和白板消息，红包消息 不允许撤回
                return@MsgRevokeFilter true
            } else if (NimCache.getAccount().equals(message.sessionId)) { // 发给我的电脑 不允许撤回
                return@MsgRevokeFilter true
            }
            false
        })
    }

    private fun registerMsgRevokeObserver() {
        NIMClient.getService(MsgServiceObserve::class.java).observeRevokeMessage(NimMessageRevokeObserver(), true)
    }

    private fun initPopuptWindow(context: Context, view: View, sessionId: String,
                                 sessionTypeEnum: SessionTypeEnum) {
        if (popupMenu == null) {
            menuItemList = ArrayList()
            popupMenu = NIMPopupMenu(context, menuItemList, listener)
        }
        menuItemList!!.clear()
        menuItemList!!.addAll(getMoreMenuItems(context, sessionId, sessionTypeEnum))
        popupMenu!!.notifyData()
        popupMenu!!.show(view)
    }

    private val listener = MenuItemClickListener { item: PopupMenuItem ->
        // TODO 消息漫游,消息搜索
        when (item.tag) {
//            ACTION_HISTORY_QUERY -> MessageHistoryActivity.start(item.context, item.sessionId, item.sessionTypeEnum) // 漫游消息查询
//            ACTION_SEARCH_MESSAGE -> SearchMessageActivity.start(item.context, item.sessionId, item.sessionTypeEnum)
            ACTION_CLEAR_MESSAGE -> EasyAlertDialogHelper.createOkCancelDiolag(item.context, null, "确定要清空吗？", true,
                    object : OnDialogActionListener {
                        override fun doCancelAction() {}
                        override fun doOkAction() {
                            NIMClient.getService(MsgService::class.java)
                                    .clearChattingHistory(
                                            item.sessionId,
                                            item.sessionTypeEnum)
                            MessageListPanelHelper.getInstance()
                                    .notifyClearMessages(
                                            item.sessionId)
                        }
                    }).show()
            ACTION_CLEAR_P2P_MESSAGE -> {
                val title = item.context.getString(R.string.message_p2p_clear_tips)
                val alertDialog = CustomAlertDialog(item.context)
                alertDialog.setTitle(title)
                alertDialog.addItem("确定") {
                    NIMClient.getService(MsgService::class.java).clearServerHistory(item.sessionId,
                            item.sessionTypeEnum)
                    MessageListPanelHelper.getInstance().notifyClearMessages(item.sessionId)
                }
                val itemText = item.context.getString(R.string.sure_keep_roam)
                alertDialog.addItem(itemText) {
                    NIMClient.getService(MsgService::class.java).clearServerHistory(item.sessionId,
                            item.sessionTypeEnum, false)
                    MessageListPanelHelper.getInstance().notifyClearMessages(item.sessionId)
                }
                alertDialog.addItem("取消") { }
                alertDialog.show()
            }
        }
    }

    private fun getMoreMenuItems(context: Context, sessionId: String,
                                 sessionTypeEnum: SessionTypeEnum): List<PopupMenuItem> {
        val moreMenuItems: MutableList<PopupMenuItem> = ArrayList()
        moreMenuItems.add(PopupMenuItem(context, ACTION_HISTORY_QUERY, sessionId, sessionTypeEnum,
                NimCache.getContext().getString(R.string.message_history_query)))
        moreMenuItems.add(PopupMenuItem(context, ACTION_SEARCH_MESSAGE, sessionId, sessionTypeEnum,
                NimCache.getContext().getString(R.string.message_search_title)))
        moreMenuItems.add(PopupMenuItem(context, ACTION_CLEAR_MESSAGE, sessionId, sessionTypeEnum,
                NimCache.getContext().getString(R.string.message_clear)))
        if (sessionTypeEnum == SessionTypeEnum.P2P) {
            moreMenuItems.add(PopupMenuItem(context, ACTION_CLEAR_P2P_MESSAGE, sessionId, sessionTypeEnum,
                    NimCache.getContext().getString(R.string.message_p2p_clear)))
        }
        return moreMenuItems
    }
}