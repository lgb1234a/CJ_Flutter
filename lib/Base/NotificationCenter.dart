/**
 *  Created by chenyn on 2019-07-18
 *  通知中心
 */

typedef GetObject = Function(dynamic object);

class NotificationCenter {
  // 工厂模式
  factory NotificationCenter() => _getInstance();

  static NotificationCenter get shared => _getInstance();
  static NotificationCenter _instance;

  NotificationCenter._internal() {
    // 初始化
  }

  static NotificationCenter _getInstance() {
    if (_instance == null) {
      _instance = new NotificationCenter._internal();
    }
    return _instance;
  }

  //创建Map来记录名称
  Map<String, dynamic> postNameMap = Map<String, dynamic>();

  GetObject getObject;

  //添加监听者方法
  addObserver(String postName, object(dynamic object)) {

    postNameMap[postName] = null;
    getObject = object;
  }

  //发送通知传值
  postNotification(String postName, dynamic object) {
    //检索Map是否含有postName
    if (postNameMap.containsKey(postName)) 
    {
      postNameMap[postName] = object;
      getObject(postNameMap[postName]);
    }
  }

  // 移除监听
  removeObserver(String postName) {
    print('remove notification: $postName');
    postNameMap.remove(postName);
  }
}