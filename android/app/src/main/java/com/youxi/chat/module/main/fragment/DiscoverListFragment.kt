package com.youxi.chat.module.main.fragment

import android.os.Bundle
import com.netease.nim.uikit.api.model.contact.ContactsCustomization
import com.netease.nim.uikit.business.contact.ContactsFragment
import com.netease.nim.uikit.business.contact.core.item.AbsContactItem
import com.netease.nim.uikit.business.contact.core.viewholder.AbsContactViewHolder
import com.netease.nim.uikit.common.activity.UI
import com.youxi.chat.R
import com.youxi.chat.module.main.model.MainTab
import com.youxi.chat.module.main.viewholder.FuncViewHolder

/**
 * 发现主TAB页
 *
 *
 * Created by huangjun on 2015/9/7.
 */
class DiscoverListFragment : MainTabFragment() {
    private var fragment: ContactsFragment? = null
    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        onCurrent() // 触发onInit，提前加载
    }

    protected override fun onInit() {
        addContactFragment() // 集成通讯录页面
    }

    // 将通讯录列表fragment动态集成进来。 开发者也可以使用在xml中配置的方式静态集成。
    private fun addContactFragment() {
        fragment = ContactsFragment()
        fragment!!.containerId = R.id.contact_fragment
        val activity = getActivity() as UI
        // 如果是activity从堆栈恢复，FM中已经存在恢复而来的fragment，此时会使用恢复来的，而new出来这个会被丢弃掉
        fragment = activity.addFragment(fragment) as ContactsFragment
        // 功能项定制
        fragment!!.setContactsCustomization(object : ContactsCustomization {
            override fun onGetFuncViewHolderClass(): Class<out AbsContactViewHolder<out AbsContactItem>?> {
                return FuncViewHolder::class.java as Class<out AbsContactViewHolder<out AbsContactItem>?>
            }

            override fun onGetFuncItems(): List<AbsContactItem> {
                return FuncViewHolder.FuncItem.provide()
            }

            override fun onFuncItemClick(item: AbsContactItem) {
                FuncViewHolder.FuncItem.handle(getActivity(), item)
            }
        })
    }

    override fun onCurrentTabClicked() { // 点击切换到当前TAB
        if (fragment != null) {
            fragment!!.scrollToTop()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        FuncViewHolder.unRegisterUnreadNumChangedCallback()
    }

    init {
        setContainerId(MainTab.CONTACT.fragmentId)
    }
}