package com.youxi.chat.module.main.activity

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.LinearLayout
import android.widget.TextView
import com.netease.nim.uikit.api.wrapper.NimToolBarOptions
import com.netease.nim.uikit.common.activity.ToolBarOptions
import com.netease.nim.uikit.common.activity.UI
import com.netease.nim.uikit.common.framework.infra.Handlers
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.RequestCallback
import com.netease.nimlib.sdk.auth.AuthService
import com.netease.nimlib.sdk.auth.ClientType
import com.netease.nimlib.sdk.auth.OnlineClient
import com.youxi.chat.R
import com.youxi.chat.event.OnlineStateEventManager.publishOnlineStateEvent
import com.youxi.chat.nim.NimCache.getContext
import java.io.Serializable

/**
 * Created by hzxuwen on 2015/7/8.
 */
class MultiportActivity : UI() {
    private var versionLayout: LinearLayout? = null
    private var onlineClients: List<OnlineClient>? = null
    private var count = 0
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.multiport_activity)
        val options: ToolBarOptions = NimToolBarOptions()
        options.titleId = R.string.multiport_manager
        setToolBar(R.id.toolbar, options)
        findViews()
        parseIntent()
        updateView()
    }

    private fun findViews() {
        versionLayout = findView(R.id.versions)
    }

    private fun parseIntent() {
        onlineClients = intent.getSerializableExtra(EXTRA_DATA) as List<OnlineClient>
        count = onlineClients!!.size
    }

    private fun updateView() {
        for (client in onlineClients!!) {
            val clientName = initVersionView(client)
            when (client.clientType) {
                ClientType.Windows, ClientType.MAC -> clientName.setText(R.string.computer_version)
                ClientType.Web -> clientName.setText(R.string.web_version)
                ClientType.Android, ClientType.iOS -> clientName.setText(R.string.mobile_version)
                else -> {
                }
            }
        }
    }

    private fun initVersionView(client: OnlineClient): TextView {
        val view = layoutInflater.inflate(R.layout.multiport_item, null)
        versionLayout!!.addView(view)
        val clientName = view.findViewById<View>(R.id.client_name) as TextView
        val clientLogout = view.findViewById<View>(R.id.client_logout) as TextView
        clientLogout.setOnClickListener { kickOtherOut(client, view, count--) }
        return clientName
    }

    private fun kickOtherOut(client: OnlineClient, layout: View, finished: Int) {
        NIMClient.getService(AuthService::class.java).kickOtherClient(client).setCallback(object : RequestCallback<Void?> {
            override fun onSuccess(param: Void?) {
                hideLayout(layout, finished)
                // 如果双发都是aos，踢掉其他端之后，服务端下发状态不带多端信息，因此这里再次发布一次
                if (client.clientType == ClientType.Android) {
                    val handler = Handlers.sharedHandler(getContext())
                    handler.postDelayed({ publishOnlineStateEvent(true) }, 2500)
                }
            }

            override fun onFailed(code: Int) {}
            override fun onException(exception: Throwable) {}
        })
    }

    private fun hideLayout(layout: View, finished: Int) {
        layout.visibility = View.GONE
        if (finished == 1) {
            finish()
        }
    }

    companion object {
        private const val EXTRA_DATA = "EXTRA_DATA"
        fun startActivity(context: Context, onlineClients: List<OnlineClient?>?) {
            val intent = Intent()
            intent.setClass(context, MultiportActivity::class.java)
            intent.putExtra(EXTRA_DATA, onlineClients as Serializable?)
            context.startActivity(intent)
        }
    }
}