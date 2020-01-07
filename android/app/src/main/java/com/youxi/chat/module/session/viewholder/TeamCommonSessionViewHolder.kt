package com.youxi.chat.module.session.viewholder

import android.text.TextUtils
import com.netease.nim.uikit.api.NimUIKit
import com.netease.nim.uikit.business.recent.TeamMemberAitHelper
import com.netease.nim.uikit.business.team.helper.TeamHelper
import com.netease.nim.uikit.common.ui.recyclerview.adapter.BaseQuickAdapter
import com.netease.nimlib.sdk.msg.attachment.NotificationAttachment
import com.netease.nimlib.sdk.msg.model.RecentContact

class TeamCommonSessionViewHolder(adapter: BaseQuickAdapter<*, *>?) : CommonSessionViewHolder(adapter) {
    override fun getContent(recent: RecentContact): String? {
        var content = descOfMsg(recent)
        val fromId = recent.fromAccount
        if (!TextUtils.isEmpty(fromId)
                && fromId != NimUIKit.getAccount()
                && recent.attachment !is NotificationAttachment) {
            val tid = recent.contactId
            val teamNick = getTeamUserDisplayName(tid, fromId)
            content = "$teamNick: $content"
            if (TeamMemberAitHelper.hasAitExtension(recent)) {
                if (recent.unreadCount == 0) {
                    TeamMemberAitHelper.clearRecentContactAited(recent)
                } else {
                    content = TeamMemberAitHelper.getAitAlertString(content)
                }
            }
        }
        return content
    }

    private fun getTeamUserDisplayName(tid: String, account: String): String {
        return TeamHelper.getTeamMemberDisplayName(tid, account)
    }
}