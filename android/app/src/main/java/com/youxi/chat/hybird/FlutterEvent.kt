package com.youxi.chat.hybird

import android.content.Intent
import android.widget.Toast
import com.blankj.utilcode.util.LogUtils
import com.blankj.utilcode.util.ToastUtils
import com.idlefish.flutterboost.FlutterBoost
import com.idlefish.flutterboost.FlutterBoostPlugin
import com.netease.nim.uikit.api.NimUIKit
import com.netease.nim.uikit.business.contact.core.item.ContactIdFilter
import com.netease.nim.uikit.business.contact.selector.activity.ContactSelectActivity
import com.netease.nim.uikit.business.team.helper.TeamHelper
import com.netease.nim.uikit.common.ui.dialog.DialogMaker
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.NIMSDK
import com.netease.nimlib.sdk.RequestCallback
import com.netease.nimlib.sdk.msg.SystemMessageService
import com.netease.nimlib.sdk.msg.constant.SystemMessageStatus
import com.netease.nimlib.sdk.team.model.TeamMember
import com.youxi.chat.R
import com.youxi.chat.module.contact.ContactHelper
import com.youxi.chat.module.contact.activity.CjContactSelectActivity
import com.youxi.chat.module.team.TeamCreateHelper
import com.youxi.chat.nim.NimCache


object FlutterEvent {

    fun addEventListener() {
        javaClass.declaredMethods.forEach { action ->
            if (action.name == "addEventListener") {
                return@forEach
            }
            LogUtils.d("addEventListener = ${action.name}")
            FlutterBoostPlugin.singleton().addEventListener(action.name) { name: String?, args: MutableMap<Any?, Any?>? ->
                LogUtils.d("onEvent = ${action.name}")
                val params = args ?: mapOf<Any, Any?>()
                try {
                    action.isAccessible = true
                    action.invoke(FlutterEvent, params)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
    }

    /**
     * 提示框
     */
    private fun showTip(params: Map<*, *>) {
        val text = params.getOrDefault("text", "") as String
        ToastUtils.showShort(text)
    }

    /**
     * 进入易钱包
     */
    private fun showYeePayWallet(params: Map<*, *>) {
        // TODO showYeePayWallet
        ToastUtils.showShort("showYeePayWallet")
    }

    /**
     * 进入云钱包
     */
    private fun onTouchMFWallet(params: Map<*, *>) {
        // TODO onTouchMFWallet
        ToastUtils.showShort("onTouchMFWallet")
    }

    /**
     * 回到根视图
     */
    private fun popToRootPage(params: Map<*, *>) {
        // TODO popToRootPage
        ToastUtils.showShort("popToRootPage")
    }

    /**
     * 创建群聊
     */
    private fun createGroupChat(params: Map<*, *>) {
        val accounts = (params.get("user_ids") ?: arrayListOf<String>()) as ArrayList<String>
        val option = TeamHelper.getCreateContactSelectOption(accounts, 50)
        option.title = "创建群聊"
        ContactHelper.startContactSelector(FlutterBoost.instance().currentActivity(), option,
                object: CjContactSelectActivity.Callback {
                    override fun onSelect(data: Intent) {
                        val selected = data.getStringArrayListExtra(ContactSelectActivity.RESULT_DATA)
                        if (selected != null && !selected.isEmpty()) {
                            TeamCreateHelper.createAdvancedTeam(FlutterBoost.instance().currentActivity(), selected, null)
                        } else {
                            Toast.makeText(NimCache.getContext(), "请选择至少一个联系人！", Toast.LENGTH_SHORT).show()
                        }
                    }
                })
    }

    /**
     * 踢出群聊
     */
    private fun kickUserOutTeam(params: Map<*, *>) {
        val teamId = params["team_id"] as String
        val option = ContactSelectActivity.Option()
        option.title = "移除群成员"
        option.type = ContactSelectActivity.ContactSelectType.TEAM_MEMBER
        option.teamId = teamId
        option.multi = true

        ContactHelper.startContactSelector(FlutterBoost.instance().currentActivity(), option,
                object: CjContactSelectActivity.Callback {
                    override fun onSelect(data: Intent) {
                        val selected = data.getStringArrayListExtra(ContactSelectActivity.RESULT_DATA)
                        if (selected != null && !selected.isEmpty()) {
                            val context = FlutterBoost.instance().currentActivity()
                            DialogMaker.showProgressDialog(context, context.getString(R.string.empty), true)

                            NIMSDK.getTeamService().removeMembers(teamId, selected)
                                    .setCallback(object : RequestCallback<Void> {

                                        override fun onSuccess(param: Void?) {
                                            DialogMaker.dismissProgressDialog()
                                            ToastUtils.showLong("移除成功")
                                            // 群成员变动记录
                                            TeamCreateHelper.groupMemberChange(selected, teamId, NimUIKit.getAccount(), "out")
                                        }

                                        override fun onFailed(code: Int) {
                                            DialogMaker.dismissProgressDialog()
                                            ToastUtils.showLong(if (code == 403) "移除失败,没有权限" else "移除失败")
                                        }

                                        override fun onException(exception: Throwable?) {
                                            DialogMaker.dismissProgressDialog()
                                            ToastUtils.showLong("移除失败")
                                        }
                                    })
                        } else {
                            Toast.makeText(NimCache.getContext(), "请选择至少一个联系人！", Toast.LENGTH_SHORT).show()
                        }
                    }
                })
    }

    /**
     * 添加群成员
     */
    private fun addTeamMember(params: Map<*, *>) {
        val teamId = params["team_id"] as String
        val fitlerIds = (params.get("filter_ids") ?: arrayListOf<String>()) as ArrayList<String>
        val option = ContactSelectActivity.Option()
        option.title = "邀请新成员"
        option.type = ContactSelectActivity.ContactSelectType.BUDDY
        option.multi = true
        option.itemFilter = ContactIdFilter(fitlerIds, true)

        ContactHelper.startContactSelector(FlutterBoost.instance().currentActivity(), option,
                object: CjContactSelectActivity.Callback {
                    override fun onSelect(data: Intent) {
                        val selected = data.getStringArrayListExtra(ContactSelectActivity.RESULT_DATA)
                        if (selected != null && !selected.isEmpty()) {
                            val context = FlutterBoost.instance().currentActivity()
                            DialogMaker.showProgressDialog(context, context.getString(R.string.empty), true)

                            NIMSDK.getTeamService().addMembers(teamId, selected)
                                    .setCallback(object : RequestCallback<List<String>> {

                                        override fun onSuccess(param: List<String>?) {
                                            DialogMaker.dismissProgressDialog()
                                            ToastUtils.showLong("邀请成功")

                                            FlutterBoostPlugin.singleton().sendEvent("updateTeamMember", mapOf("name" to "邀请成功"))
                                        }

                                        override fun onFailed(code: Int) {
                                            DialogMaker.dismissProgressDialog()
                                            ToastUtils.showLong(if (code == 403) "邀请失败,没有权限" else "邀请失败")
                                        }

                                        override fun onException(exception: Throwable?) {
                                            DialogMaker.dismissProgressDialog()
                                            ToastUtils.showLong("邀请失败")
                                        }
                                    })
                        } else {
                            Toast.makeText(NimCache.getContext(), "请选择至少一个联系人！", Toast.LENGTH_SHORT).show()
                        }
                    }
                })
    }

    /**
     * 群转让
     */
    private fun teamTransform(params: Map<*, *>) {
        val teamId = params["teamId"] as String
        val option = ContactSelectActivity.Option()
        option.title = "转让群组"
        option.type = ContactSelectActivity.ContactSelectType.TEAM_MEMBER
        option.teamId = teamId
        option.multi = false
        ContactHelper.startContactSelector(FlutterBoost.instance().currentActivity(), option,
                object: CjContactSelectActivity.Callback {
                    override fun onSelect(data: Intent) {
                        val selected = data.getStringArrayListExtra(ContactSelectActivity.RESULT_DATA)
                        if (selected != null && !selected.isEmpty()) {
                            val context = FlutterBoost.instance().currentActivity()
                            DialogMaker.showProgressDialog(context, context.getString(R.string.empty), true)

                            NIMSDK.getTeamService().transferTeam(teamId, selected.first(), false)
                                    .setCallback(object : RequestCallback<List<TeamMember>> {

                                        override fun onSuccess(param: List<TeamMember>?) {
                                            DialogMaker.dismissProgressDialog()
                                            ToastUtils.showLong("转让成功")
                                        }

                                        override fun onFailed(code: Int) {
                                            DialogMaker.dismissProgressDialog()
                                            ToastUtils.showLong(if (code == 403) "转让失败,没有权限" else "转让失败")
                                        }

                                        override fun onException(exception: Throwable?) {
                                            DialogMaker.dismissProgressDialog()
                                            ToastUtils.showLong("转让失败")
                                        }
                                    })
                        } else {
                            Toast.makeText(NimCache.getContext(), "请选择至少一个联系人！", Toast.LENGTH_SHORT).show()
                        }
                    }
                })
    }

    /**
     * 设置群管理员
     */
    private fun setTeamManager(params: Map<*, *>) {
        val teamId = params["teamId"] as String
        val managerIds = (params.get("managerIds") ?: arrayListOf<String>()) as ArrayList<String>

        val option = ContactSelectActivity.Option()
        option.title = "设置群管理员"
        option.type = ContactSelectActivity.ContactSelectType.TEAM_MEMBER
        option.teamId = teamId
        option.multi = true
        option.alreadySelectedAccounts = managerIds
        option.allowSelectEmpty = true
        ContactHelper.startContactSelector(FlutterBoost.instance().currentActivity(), option,
                object: CjContactSelectActivity.Callback {
                    override fun onSelect(data: Intent) {
                        val selected = data.getStringArrayListExtra(ContactSelectActivity.RESULT_DATA)
                        if (selected != null && !selected.isEmpty()) {
                            // 筛选出要新增的管理员
                            val newIds = selected.filter { !managerIds.contains(it) }.toList()
                            // 筛选出要删除的管理员
                            val removeIds = managerIds.filter { !selected.contains(it) }.toList()

                            // 新增的调用add
                            if (!newIds.isNullOrEmpty()) {
                                NIMSDK.getTeamService().addManagers(teamId, newIds).setCallback(null)
                            }
                            // 移除的调用remove
                            if (!removeIds.isNullOrEmpty()) {
                                NIMSDK.getTeamService().removeManagers(teamId, removeIds).setCallback(null)
                            }
                        }
                    }
                })
    }

    /**
     * 保存图片到相册
     */
    private fun saveImageToAlbum(params: Map<*, *>) {
        // TODO 保存图片到相册
        val text = params.getOrDefault("text", "") as String
        ToastUtils.showShort(text)
//        val imgData = params["img_data"] as Array<Byte>
    }

    /**
     * 分享
     */
    private fun share(params: Map<*, *>) {
        // TODO 会话选择器
        val type = params.get("type") as Int
        if (type == 0 || type == 1) {
            // TODO ...

        } else if (type == 2) {
            // TODO ...
        }
        val text = params.getOrDefault("text", "") as String
        ToastUtils.showShort(text)
    }

    /**
     * 通知处理
     */
    private fun handledNotification(params: Map<*, *>) {
        val notificationId = params.get("notificationId") as Long
        val handleStatus = params.get("handleStatus") as Int

        val message = NIMClient.getService(SystemMessageService::class.java)
                .querySystemMessagesBlock(0, Int.MAX_VALUE)
                .filter {
                    it.messageId == notificationId
                }
                .first()
        message.status = SystemMessageStatus.statusOfValue(handleStatus)
    }

    /**
     * 创建通知
     */
    private fun newNotification(params: Map<*, *>) {
        // TODO 创建通知
        val text = params.getOrDefault("text", "") as String
        ToastUtils.showShort(text)
    }

}