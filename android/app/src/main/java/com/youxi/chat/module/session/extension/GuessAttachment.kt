package com.youxi.chat.module.session.extension

import com.alibaba.fastjson.JSONObject
import java.util.*

/**
 * Created by zhoujianghua on 2015/4/9.
 */
class GuessAttachment : CustomAttachment(CustomAttachmentType.Guess) {
    enum class Guess(val value: Int, val desc: String) {
        Shitou(1, "石头"), Jiandao(2, "剪刀"), Bu(3, "布");

        companion object {
            fun enumOfValue(value: Int): Guess {
                for (direction in values()) {
                    if (direction.value == value) {
                        return direction
                    }
                }
                return Shitou
            }
        }

    }

    var value: Guess? = null
        private set

    override fun parseData(data: JSONObject) {
        value = Guess.enumOfValue(data.getIntValue("value"))
    }

    protected override fun packData(): JSONObject {
        val data = JSONObject()
        data["value"] = value!!.value
        return data
    }

    private fun random() {
        val value = Random().nextInt(3) + 1
        this.value = Guess.enumOfValue(value)
    }

    init {
        random()
    }
}