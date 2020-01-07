package com.youxi.chat.module.main.fragment

import com.idlefish.flutterboost.containers.FlutterFragment
import com.youxi.chat.R
import com.youxi.chat.module.main.model.MainTab

/**
 * 我的主TAB页
 *
 *
 * Created by huangjun on 2015/9/7.
 */
class MineListFragment : MainTabFragment() {
    private var fragment: FlutterFragment? = null
    protected override fun onInit() { // 采用静态集成，这里不需要做什么了

    }

    override fun onCurrent() {
        super.onCurrent()
        createFragment()
        addFragment()
    }

    private fun createFragment() {
        fragment = null
        if (fragment == null) {
            fragment = FlutterFragment.NewEngineFragmentBuilder()
                    .url("mine")
                    .params(mapOf(
                            "bottom_padding" to 0.0
                    )).build()
        }
    }

    private fun addFragment() {
        if (fragment != null) {
            childFragmentManager
                    .beginTransaction()
                    .replace(R.id.fragment_stub, fragment!!)
                    .commit();
        }
    }

    init {
        setContainerId(MainTab.MINE.fragmentId)
    }
}