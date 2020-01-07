package com.youxi.chat.uikit.business.contact.core.model;

import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum;

import java.io.Serializable;

public class RecentContactData implements Serializable {
    public SessionTypeEnum getSessionTypeEnum() {
        return sessionTypeEnum;
    }

    public void setSessionTypeEnum(SessionTypeEnum sessionTypeEnum) {
        this.sessionTypeEnum = sessionTypeEnum;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    private SessionTypeEnum sessionTypeEnum;
    private String id;

    public RecentContactData(SessionTypeEnum sessionTypeEnum, String id) {
        this.sessionTypeEnum = sessionTypeEnum;
        this.id = id;
    }


}
