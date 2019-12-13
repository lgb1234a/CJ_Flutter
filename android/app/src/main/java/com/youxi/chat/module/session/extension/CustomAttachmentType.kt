package com.youxi.chat.module.session.extension

/**
 * Created by zhoujianghua on 2015/4/9.
 */
interface CustomAttachmentType {
    companion object {
        // 多端统一
        const val Guess = 1 //石头剪刀布
        const val SnapChat = 2 //阅后即焚
        const val Sticker = 3 //贴图
        const val RTS = 4 //白板的发起结束消息
        const val RedPacket = 5
        const val OpenedRedPacket = 6
        const val MultiRetweet = 15 //多条消息合并转发
    }
}