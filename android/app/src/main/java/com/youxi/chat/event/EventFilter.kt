package com.youxi.chat.event

import com.netease.nimlib.sdk.event.model.Event
import java.util.*

/**
 * Created by hzchenkang on 2017/4/10.
 */
class EventFilter private constructor() {
    private val timeFilter: MutableMap<KeyModel, Long?>

    private object Instance {
        val instance = EventFilter()
    }

    /**
     * 一般地，先发布事件先下发，但是可能存在同一事件先后顺序错乱的情况，因为事件以最后时间为准，因此这里过滤掉无效旧的事件
     *
     * @param events
     * @return
     */
    fun filterOlderEvent(events: List<Event>?): List<Event>? {
        if (events == null || events.isEmpty()) {
            return null
        }
        val results: MutableList<Event> = ArrayList()
        for (event in events) {
            val key = KeyModel(event.eventType, event.publisherAccount)
            val eventTime = event.publishTime
            if (timeFilter.containsKey(key)) {
                val lastEventTime = timeFilter[key]!!
                if (eventTime < lastEventTime) {
                    continue
                }
            }
            timeFilter[key] = eventTime
            results.add(event)
        }
        return results
    }

    private class KeyModel(private val eventType: Int, id: String?) {
        private var id: String? = ""
        override fun hashCode(): Int {
            return if (id == null) {
                eventType
            } else {
                eventType + 32 * id.hashCode()
            }
        }

        override fun equals(o: Any?): Boolean {
            if (o == null || o !is KeyModel) {
                return false
            }
            val other = o
            return if (eventType == other.eventType) {
                if (id == null) {
                    other.id == null
                } else {
                    id == other.id
                }
            } else {
                false
            }
        }

        init {
            this.id = id
        }
    }

    companion object {
        fun getInstance(): EventFilter {
            return Instance.instance
        }
    }

    init {
        timeFilter = HashMap()
    }
}