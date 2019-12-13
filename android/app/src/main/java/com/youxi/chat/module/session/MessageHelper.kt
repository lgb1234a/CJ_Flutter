package com.youxi.chat.module.session

import android.text.TextUtils
import com.netease.nim.uikit.api.NimUIKit
import com.netease.nim.uikit.api.model.CreateMessageCallback
import com.netease.nim.uikit.business.session.actions.PickImageAction
import com.netease.nim.uikit.business.team.helper.SuperTeamHelper
import com.netease.nim.uikit.business.team.helper.TeamHelper
import com.netease.nim.uikit.business.uinfo.UserInfoHelper
import com.netease.nim.uikit.common.util.log.sdk.wrapper.NimLog
import com.netease.nim.uikit.common.util.storage.StorageType
import com.netease.nim.uikit.common.util.storage.StorageUtil
import com.netease.nim.uikit.common.util.string.MD5
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.RequestCallback
import com.netease.nimlib.sdk.friend.model.AddFriendNotify
import com.netease.nimlib.sdk.msg.MessageBuilder
import com.netease.nimlib.sdk.msg.constant.MsgTypeEnum
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum
import com.netease.nimlib.sdk.msg.constant.SystemMessageStatus
import com.netease.nimlib.sdk.msg.constant.SystemMessageType
import com.netease.nimlib.sdk.msg.model.IMMessage
import com.netease.nimlib.sdk.msg.model.SystemMessage
import com.netease.nimlib.sdk.nos.NosService
import com.netease.nimlib.sdk.team.model.Team
import com.netease.nimlib.sdk.uinfo.UserService
import com.youxi.chat.R
import com.youxi.chat.module.session.extension.MultiRetweetAttachment
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.io.OutputStream
import java.security.InvalidKeyException
import java.security.NoSuchAlgorithmException
import java.security.SecureRandom
import javax.crypto.*
import javax.crypto.spec.SecretKeySpec

/**
 * Created by huangjun on 2015/4/9.
 */
object MessageHelper {
    var TAG = "MessageHelper"
    fun getName(account: String, sessionType: SessionTypeEnum): String {
        if (sessionType == SessionTypeEnum.P2P) {
            return UserInfoHelper.getUserDisplayName(account)
        } else if (sessionType == SessionTypeEnum.Team) {
            return TeamHelper.getTeamName(account)
        } else if (sessionType == SessionTypeEnum.SUPER_TEAM) {
            return SuperTeamHelper.getTeamName(account)
        }
        return account
    }

    fun getVerifyNotificationText(message: SystemMessage): String {
        val sb = StringBuilder()
        val fromAccount = UserInfoHelper.getUserDisplayNameEx(message.fromAccount, "你")
        var team = NimUIKit.getTeamProvider().getTeamById(message.targetId)
        if (team == null && message.attachObject is Team) {
            team = message.attachObject as Team
        }
        val teamName = if (team == null) message.targetId else team.name
        if (message.type == SystemMessageType.TeamInvite) {
            sb.append("邀请").append("你").append("加入群 ").append(teamName)
        } else if (message.type == SystemMessageType.DeclineTeamInvite) {
            sb.append(fromAccount).append("拒绝了群 ").append(teamName).append(" 邀请")
        } else if (message.type == SystemMessageType.ApplyJoinTeam) {
            sb.append("申请加入群 ").append(teamName)
        } else if (message.type == SystemMessageType.RejectTeamApply) {
            sb.append(fromAccount).append("拒绝了你加入群 ").append(teamName).append("的申请")
        } else if (message.type == SystemMessageType.AddFriend) {
            val attachData = message.attachObject as AddFriendNotify
            if (attachData != null) {
                if (attachData.event == AddFriendNotify.Event.RECV_ADD_FRIEND_DIRECT) {
                    sb.append("已添加你为好友")
                } else if (attachData.event == AddFriendNotify.Event.RECV_AGREE_ADD_FRIEND) {
                    sb.append("通过了你的好友请求")
                } else if (attachData.event == AddFriendNotify.Event.RECV_REJECT_ADD_FRIEND) {
                    sb.append("拒绝了你的好友请求")
                } else if (attachData.event == AddFriendNotify.Event.RECV_ADD_FRIEND_VERIFY_REQUEST) {
                    sb.append("请求添加好友" + if (TextUtils.isEmpty(message.content)) "" else "：" + message.content)
                }
            }
        }
        return sb.toString()
    }

    /**
     * 是否验证消息需要处理（需要有同意拒绝的操作栏）
     */
    fun isVerifyMessageNeedDeal(message: SystemMessage): Boolean {
        return if (message.type == SystemMessageType.AddFriend) {
            if (message.attachObject != null) {
                val attachData = message.attachObject as AddFriendNotify
                if (attachData.event == AddFriendNotify.Event.RECV_ADD_FRIEND_DIRECT || attachData.event == AddFriendNotify.Event.RECV_AGREE_ADD_FRIEND || attachData.event == AddFriendNotify.Event.RECV_REJECT_ADD_FRIEND) {
                    return false // 对方直接加你为好友，对方通过你的好友请求，对方拒绝你的好友请求
                } else if (attachData.event == AddFriendNotify.Event.RECV_ADD_FRIEND_VERIFY_REQUEST) {
                    return true // 好友验证请求
                }
            }
            false
        } else if (message.type == SystemMessageType.TeamInvite || message.type == SystemMessageType.ApplyJoinTeam) {
            true
        } else {
            false
        }
    }

    fun getVerifyNotificationDealResult(message: SystemMessage): String {
        return if (message.status == SystemMessageStatus.passed) {
            "已同意"
        } else if (message.status == SystemMessageStatus.declined) {
            "已拒绝"
        } else if (message.status == SystemMessageStatus.ignored) {
            "已忽略"
        } else if (message.status == SystemMessageStatus.expired) {
            "已过期"
        } else {
            "未处理"
        }
    }

    /**
     * 合并发送消息，并通过ActivityResult回传合并后的消息 (this->上层Activity->MessageListPanelEx)；最后由接收方发送
     */
    fun createMultiRetweet(toBeSent: List<IMMessage>, shouldEncrypt: Boolean, callback: CreateMessageCallback) {
        if (toBeSent.isEmpty()) {
            return
        }
        //将多条消息合并成文件
//现在是明文字节码，加密后存储密文字节码
        val fileBytes = MessageBuilder.createForwardMessageListFileDetail(toBeSent).toByteArray()
        val key: ByteArray
        val encryptedFileBytes: ByteArray
        if (shouldEncrypt) { //RC4加密
            key = genRC4Key()
            encryptedFileBytes = encryptByRC4(fileBytes, key)
        } else {
            key = ByteArray(0)
            encryptedFileBytes = fileBytes
        }
        //encryptedFileBytes是否是已加密字节码
        val isEncrypted = encryptedFileBytes != fileBytes
        if (isEncrypted != shouldEncrypt) {
            NimLog.d(TAG, "failed to encrypt file with RC4")
        }
        //将字节码的16进制String类型写入文件
        val fileName = TAG + System.currentTimeMillis()
        val file = File(StorageUtil.getDirectoryByDirType(StorageType.TYPE_FILE),
                fileName)
        try {
            if (file.exists() || file.createNewFile()) {
                val outputStream: OutputStream = FileOutputStream(file, false)
                outputStream.write(encryptedFileBytes)
                outputStream.close()
            }
        } catch (e: IOException) {
            e.printStackTrace()
        }
        //将文件上传到Nos，如果成功，将得到该文件的下载链接
        NIMClient.getService(NosService::class.java).upload(file, PickImageAction.MIME_JPEG).setCallback(object : RequestCallback<String> {
            override fun onSuccess(url: String) {
                NimLog.d(TAG, "NosService.upload/onSuccess, url=$url")
                file.delete()
                if (TextUtils.isEmpty(url)) {
                    return
                }
                val firstMsg = toBeSent[0]
                val secondMsg = if (toBeSent.size > 1) toBeSent[1] else null
                //第一条消息的展示内容
                val firstContent = getContent(firstMsg)
                //绘画类型
                val sessionType = firstMsg.sessionType
                //标题的sessionID部分
                val sessionId = firstMsg.sessionId
                var sessionName: String? = null
                when (sessionType) {
                    SessionTypeEnum.P2P -> sessionName = getStoredNameFromSessionId(NimUIKit.getAccount(), SessionTypeEnum.P2P)
                    SessionTypeEnum.Team, SessionTypeEnum.SUPER_TEAM -> sessionName = getStoredNameFromSessionId(sessionId, sessionType)
                    else -> {
                    }
                }
                if (sessionName == null) {
                    sessionName = sessionId
                }
                val nick1 = getStoredNameFromSessionId(firstMsg.fromAccount, SessionTypeEnum.P2P)
                var nick2: String? = null
                if (secondMsg != null) {
                    nick2 = getStoredNameFromSessionId(secondMsg.fromAccount, SessionTypeEnum.P2P)
                }
                //创建附件
                val attachment = MultiRetweetAttachment(
                        sessionId, sessionName, url, MD5.getMD5(encryptedFileBytes), false, isEncrypted,
                        String(key), nick1, firstContent, nick2, getContent(secondMsg)
                )
                val pushContent = NimUIKit.getContext().getString(R.string.msg_type_multi_retweet)
                //创建MultiRetweet类型自定义信息
                val packedMsg = MessageBuilder.createCustomMessage(firstMsg.sessionId, sessionType, pushContent, attachment)
                packedMsg.pushContent = pushContent
                callback.onFinished(packedMsg)
            }

            override fun onFailed(code: Int) {
                NimLog.d(TAG, "NosService.upload/onFailed, code=$code")
                file.delete()
                callback.onFailed(code)
            }

            override fun onException(exception: Throwable) {
                NimLog.d(TAG, "NosService.upload/onException, exception=" + exception.message)
                file.delete()
                callback.onException(exception)
            }
        })
    }

    /**
     * 获取消息的简略提示 [MsgTypeEnum]
     * txt: 显示content
     * 其他：有pushContent，则显示；否则查看是否有content，如果还没有，则显示"[" + MsgTypeEnum.getSendMessageTip() + "]"
     *
     * @param msg 消息体
     * @return 提示文本
     */
    fun getContent(msg: IMMessage?): String {
        if (msg == null) {
            return ""
        }
        val type = msg.msgType
        return if (type == MsgTypeEnum.text) {
            msg.content
        } else {
            var content = msg.pushContent
            if (!TextUtils.isEmpty(content)) {
                return content
            }
            content = msg.content
            if (!TextUtils.isEmpty(content)) {
                return content
            }
            content = "[" + type.sendMessageTip + "]"
            content
        }
    }

    /**
     * 通过id和type，从本地存储中查询对应的群名或用户名
     *
     * @param id          群或用户的id
     * @param sessionType 会话类型
     * @return id对应的昵称
     */
    fun getStoredNameFromSessionId(id: String?, sessionType: SessionTypeEnum?): String? {
        return when (sessionType) {
            SessionTypeEnum.P2P -> {
                //读取对方用户名称
                val userInfo = NIMClient.getService(UserService::class.java).getUserInfo(id)
                        ?: return null
                userInfo.name
            }
            SessionTypeEnum.Team -> {
                //获取群信息
                val team = NimUIKit.getTeamProvider().getTeamById(id) ?: return null
                team.name
            }
            SessionTypeEnum.SUPER_TEAM -> {
                //获取群信息
                val superTeam = NimUIKit.getSuperTeamProvider().getTeamById(id) ?: return null
                superTeam.name
            }
            else -> null
        }
    }

    /**
     * 生成可用于RC4加解密的秘钥
     *
     * @return 秘钥
     */
    fun genRC4Key(): ByteArray {
        val selectionList = byteArrayOf('0'.toByte(), '1'.toByte(), '2'.toByte(), '3'.toByte(), '4'.toByte(), '5'.toByte(), '6'.toByte(), '7'.toByte(), '8'.toByte(), '9'.toByte(), 'a'.toByte(), 'b'.toByte(), 'c'.toByte(), 'd'.toByte(), 'e'.toByte(), 'f'.toByte())
        val keyLen = 16
        val random = SecureRandom(SecureRandom.getSeed(32))
        val key = ByteArray(keyLen)
        random.nextBytes(key)
        for (i in key.indices) {
            key[i] = selectionList[Math.abs(key[i] % selectionList.size)]
        }
        return key
    }

    /**
     * RC4加密
     *
     * @param src 原始内容
     * @param key 秘钥
     * @return 加密后内容
     */
    fun encryptByRC4(src: ByteArray, key: ByteArray): ByteArray {
        try {
            val cipher = Cipher.getInstance("RC4")
            cipher.init(Cipher.ENCRYPT_MODE, RC4SecretKey(key))
            return cipher.doFinal(src)
        } catch (e: NoSuchAlgorithmException) {
            e.printStackTrace()
        } catch (e: NoSuchPaddingException) {
            e.printStackTrace()
        } catch (e: InvalidKeyException) {
            e.printStackTrace()
        } catch (e: BadPaddingException) {
            e.printStackTrace()
        } catch (e: IllegalBlockSizeException) {
            e.printStackTrace()
        }
        return src
    }

    /**
     * RC4解密
     *
     * @param src 密文
     * @param key 秘钥
     * @return 解密后内容
     */
    fun decryptByRC4(src: ByteArray?, key: ByteArray): ByteArray? {
        try {
            val cipher = Cipher.getInstance("RC4")
            cipher.init(Cipher.DECRYPT_MODE, RC4SecretKey(key))
            return cipher.doFinal(src)
        } catch (e: NoSuchAlgorithmException) {
            e.printStackTrace()
        } catch (e: NoSuchPaddingException) {
            e.printStackTrace()
        } catch (e: InvalidKeyException) {
            e.printStackTrace()
        } catch (e: BadPaddingException) {
            e.printStackTrace()
        } catch (e: IllegalBlockSizeException) {
            e.printStackTrace()
        }
        return null
    }

    private class RC4SecretKey constructor(key: ByteArray) : SecretKey {
        private val spec: SecretKeySpec
        override fun getAlgorithm(): String {
            return spec.algorithm
        }

        override fun getFormat(): String {
            return spec.format
        }

        override fun getEncoded(): ByteArray {
            return spec.encoded
        }

        init {
            spec = SecretKeySpec(key, "RC4")
        }
    }
}