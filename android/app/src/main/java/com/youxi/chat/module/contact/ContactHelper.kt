package com.youxi.chat.module.contact

import android.content.Context
import com.netease.nim.uikit.api.NimUIKit
import com.netease.nim.uikit.api.model.contact.ContactEventListener
import com.netease.nim.uikit.business.contact.selector.activity.ContactSelectActivity
import com.youxi.chat.module.contact.activity.CjContactSelectActivity


/**
 * UIKit联系人列表定制展示类
 *
 *
 * Created by huangjun on 2015/9/11.
 */
object ContactHelper {
    fun init() {
        setContactEventListener()
    }

    private fun setContactEventListener() {
        NimUIKit.setContactEventListener(object : ContactEventListener {
            override fun onItemClick(context: Context, account: String) {
                // TODO 通讯录个人资料页跳转
//                UserProfileActivity.start(context, account)
            }

            override fun onItemLongClick(context: Context, account: String) {

            }

            override fun onAvatarClick(context: Context, account: String) {
                // TODO 通讯录个人资料页跳转
//                UserProfileActivity.start(context, account)
            }
        })
    }

    /**
     * 打开联系人选择器
     *
     * @param context     上下文（Activity）
     * @param option      联系人选择器可选配置项
     * @param callback    选择器回调
     */
    fun startContactSelector(context: Context, option: ContactSelectActivity.Option, callback: CjContactSelectActivity.Callback) {
        CjContactSelectActivity.startActivityForResult(context, option, callback)
    }
}