/// Created by Chenyn 2019-12-18
/// flutter消息总线
/// 

import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

/// 删除了联系人
class DeletedContact {}

/// 更新了用户信息
class UpdatedUserInfo {}