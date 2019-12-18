/// Created by Chenyn 2019-12-17
/// 系统通知model
/// 

enum NotificationHandleType {
    /// 0:默认
    NotificationHandleTypePending,
    /// 1:操作完成
    NotificationHandleTypeOk,       
    /// 2:拒绝
    NotificationHandleTypeNo,
    /// 3:失效
    NotificationHandleTypeOutOfDate
}

class SystemNotification {
  /// 通知 ID
  int notificationId;

  /// 0:申请入群  1:拒绝入群 2:邀请入群 3:拒绝入群邀请 5:添加好友
  int type;

  /// 时间戳
  double timestamp;

  /// 操作者
  String sourceID;

  /// 目标ID,群ID或者是用户ID
  String targetID;

  /// 附言
  String postscript;

  /// 是否已读
  ///  @discussion 修改这个属性并不会修改 db 中的数据
  bool read;

  /// 消息处理状态 NotificationHandleType
  /// @discussion 修改这个属性,后台会自动更新 db 中对应的数据,SDK 调用者可以使用这个值来持久化他们对消息的处理结果,默认为 0
  /// 
  int handleStatus;

  /// 系统通知下发的自定义扩展信息
  String notifyExt;

  /// 附件
  /// @discussion 额外信息,只有 好友添加 这个通知有附件
  ///              好友添加的 attachment 为 NIMUserAddAttachment
  /// NIMUserAddAttachment.operationType 
  /// 1: 添加好友   @discussion 直接添加为好友,无需验证
  /// 2: 请求添加好友
  /// 3: 通过添加好友请求
  /// 4: 拒绝添加好友请求
  int attachment;

  SystemNotification.fromJson(Map json)
      : notificationId = json['notificationId'],
        type = json['type'],
        timestamp = json['timestamp'],
        sourceID = json['sourceID'],
        targetID = json['targetID'],
        postscript = json['postscript'],
        read = json['read'],
        handleStatus = json['handleStatus'],
        notifyExt = json['notifyExt'],
        attachment = json['attachment'];
}
