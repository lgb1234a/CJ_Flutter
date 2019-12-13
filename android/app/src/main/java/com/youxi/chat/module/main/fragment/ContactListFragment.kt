package com.youxi.chat.module.main.fragment

import android.os.Bundle
import com.idlefish.flutterboost.containers.FlutterFragment
import com.youxi.chat.R
import com.youxi.chat.module.main.model.MainTab
import com.youxi.chat.module.main.viewholder.FuncViewHolder

/**
 * 集成通讯录列表
 *
 *
 * Created by huangjun on 2015/9/7.
 */
class ContactListFragment : MainTabFragment() {
    private var fragment: FlutterFragment? = null
    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        onCurrent() // 触发onInit，提前加载
    }

    protected override fun onInit() {
        addContactFragment() // 集成通讯录页面
    }

    // 将通讯录列表fragment动态集成进来。 开发者也可以使用在xml中配置的方式静态集成。
    private fun addContactFragment() {
        fragment = FlutterFragment.NewEngineFragmentBuilder()
                .url("contacts")
                .params(mapOf(
                        "bottom_padding" to 0.0
                )).build()
        childFragmentManager
                .beginTransaction()
                .replace(R.id.fragment_stub, fragment!!)
                .commit();
    }

    override fun onCurrentTabClicked() {
        // 点击切换到当前TAB
        if (fragment != null) {
            // TODO Flutter滚动置顶, 发送event
//            fragment!!.scrollToTop()
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