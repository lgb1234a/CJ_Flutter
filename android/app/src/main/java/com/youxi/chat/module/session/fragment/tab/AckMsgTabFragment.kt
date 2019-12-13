package com.youxi.chat.module.session.fragment.tab

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.netease.nim.uikit.common.fragment.TabFragment
import com.youxi.chat.R
import com.youxi.chat.module.session.model.AckMsgTab

abstract class AckMsgTabFragment : TabFragment() {
    private var loaded = false
    private var tabData: AckMsgTab? = null
    protected abstract fun onInit()
    protected fun inited(): Boolean {
        return loaded
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.main_tab_fragment_container, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
    }

    fun attachTabData(tabData: AckMsgTab?) {
        this.tabData = tabData
    }

    override fun onCurrent() {
        super.onCurrent()
        if (!loaded && loadRealLayout()) {
            loaded = true
            onInit()
        }
    }

    private fun loadRealLayout(): Boolean {
        val root = view as ViewGroup?
        if (root != null) {
            root.removeAllViewsInLayout()
            View.inflate(root.context, tabData!!.layoutId, root)
        }
        return root != null
    }
}