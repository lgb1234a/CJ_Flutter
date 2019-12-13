package com.youxi.chat.module.contact

import android.content.Context
import com.netease.nim.uikit.api.NimUIKit
import com.netease.nim.uikit.api.model.contact.ContactEventListener

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
}