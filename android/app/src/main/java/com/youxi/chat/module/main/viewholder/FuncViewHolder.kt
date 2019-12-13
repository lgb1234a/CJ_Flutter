package com.youxi.chat.module.main.viewholder

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.netease.nim.uikit.business.contact.core.item.AbsContactItem
import com.netease.nim.uikit.business.contact.core.item.ItemTypes
import com.netease.nim.uikit.business.contact.core.model.ContactDataAdapter
import com.netease.nim.uikit.business.contact.core.viewholder.AbsContactViewHolder
import com.youxi.chat.R
import com.youxi.chat.module.main.reminder.ReminderId
import com.youxi.chat.module.main.reminder.ReminderItem
import com.youxi.chat.module.main.reminder.ReminderManager
import com.youxi.chat.module.main.viewholder.FuncViewHolder.FuncItem
import java.lang.ref.WeakReference
import java.util.*

class FuncViewHolder : AbsContactViewHolder<FuncItem?>(), ReminderManager.UnreadNumChangedCallback {
    private var image: ImageView? = null
    private var funcName: TextView? = null
    private var unreadNum: TextView? = null
    private val callbacks: Set<ReminderManager.UnreadNumChangedCallback> = HashSet<ReminderManager.UnreadNumChangedCallback>()
    override fun inflate(inflater: LayoutInflater): View {
        val view: View = inflater.inflate(R.layout.func_contacts_item, null)
        image = view.findViewById(R.id.img_head)
        funcName = view.findViewById(R.id.tv_func_name)
        unreadNum = view.findViewById(R.id.tab_new_msg_label)
        return view
    }

    override fun refresh(contactAdapter: ContactDataAdapter, position: Int, item: FuncItem?) {
        // TODO 功能区点击事件
//        if (item == FuncItem.VERIFY) {
//            funcName!!.text = "验证提醒"
//            image!!.setImageResource(R.drawable.icon_verify_remind)
//            image!!.scaleType = ImageView.ScaleType.FIT_XY
//            val unreadCount: Int = SystemMessageUnreadManager.getInstance().getSysMsgUnreadCount()
//            updateUnreadNum(unreadCount)
//            ReminderManager.instance?.registerUnreadNumChangedCallback(this)
//            sUnreadCallbackRefs.add(WeakReference<ReminderManager.UnreadNumChangedCallback>(this))
//        } else if (item == FuncItem.ROBOT) {
//            funcName!!.text = "智能机器人"
//            image!!.setImageResource(R.drawable.ic_robot)
//        } else if (item == FuncItem.NORMAL_TEAM) {
//            funcName!!.text = "讨论组"
//            image!!.setImageResource(R.drawable.ic_secretary)
//        } else if (item == FuncItem.ADVANCED_TEAM) {
//            funcName!!.text = "高级群"
//            image!!.setImageResource(R.drawable.ic_advanced_team)
//        } else if (item == FuncItem.BLACK_LIST) {
//            funcName!!.text = "黑名单"
//            image!!.setImageResource(R.drawable.ic_black_list)
//        } else if (item == FuncItem.MY_COMPUTER) {
//            funcName!!.text = "我的电脑"
//            image!!.setImageResource(R.drawable.ic_my_computer)
//        }
        if (item != FuncItem.VERIFY) {
            image!!.scaleType = ImageView.ScaleType.FIT_XY
            unreadNum!!.visibility = View.GONE
        }
    }

    private fun updateUnreadNum(unreadCount: Int) { // 2.*版本viewholder复用问题
        if (unreadCount > 0 && funcName!!.text.toString() == "验证提醒") {
            unreadNum!!.visibility = View.VISIBLE
            unreadNum!!.text = "" + unreadCount
        } else {
            unreadNum!!.visibility = View.GONE
        }
    }

    override fun onUnreadNumChanged(item: ReminderItem?) {
        if (item?.id !== ReminderId.CONTACT) {
            return
        }
        updateUnreadNum(item.getUnread())
    }

    class FuncItem : AbsContactItem() {
        override fun getItemType(): Int {
            return ItemTypes.FUNC
        }

        override fun belongsGroup(): String? {
            return null
        }

        companion object {
            val VERIFY = FuncItem()
            val ROBOT = FuncItem()
            val NORMAL_TEAM = FuncItem()
            val ADVANCED_TEAM = FuncItem()
            val BLACK_LIST = FuncItem()
            val MY_COMPUTER = FuncItem()
            fun provide(): List<AbsContactItem> {
                val items: MutableList<AbsContactItem> = ArrayList()
                items.add(VERIFY)
                //items.add(ROBOT);
                items.add(NORMAL_TEAM)
                items.add(ADVANCED_TEAM)
                items.add(BLACK_LIST)
                items.add(MY_COMPUTER)
                return items
            }

            fun handle(context: Context?, item: AbsContactItem) {
                // TODO 功能区点击事件
//                if (item === VERIFY) {
//                    SystemMessageActivity.start(context)
//                } else if (item === ROBOT) {
//                    RobotListActivity.start(context)
//                } else if (item === NORMAL_TEAM) {
//                    TeamListActivity.start(context, ItemTypes.TEAMS.NORMAL_TEAM)
//                } else if (item === ADVANCED_TEAM) {
//                    TeamListActivity.start(context, ItemTypes.TEAMS.ADVANCED_TEAM)
//                } else if (item === MY_COMPUTER) {
//                    SessionHelper.startP2PSession(context, NimHelper.getAccount())
//                } else if (item === BLACK_LIST) {
//                    BlackListActivity.start(context)
//                }
            }
        }
    }

    companion object {
        private val sUnreadCallbackRefs: ArrayList<WeakReference<ReminderManager.UnreadNumChangedCallback>> = ArrayList<WeakReference<ReminderManager.UnreadNumChangedCallback>>()
        fun unRegisterUnreadNumChangedCallback() {
            val iter: MutableIterator<WeakReference<ReminderManager.UnreadNumChangedCallback>> = sUnreadCallbackRefs.iterator()
            while (iter.hasNext()) {
                ReminderManager.instance?.unregisterUnreadNumChangedCallback(iter.next().get())
                iter.remove()
            }
        }
    }
}