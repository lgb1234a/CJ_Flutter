import 'package:cajian/Mine/Model/MineInfoModel.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';
import 'package:nim_sdk_util/Model/nim_userInfo.dart';

class MineInfoDao {
  static Future<List> fetchModels() async {
    CurrentUserInfo info = await NimSdkUtil.currentUserInfo();
    final gender = info.gender;
    final genderStr = genderTransString(gender);
    final List models = [];
    models.add(MineInfoModel(MineInfoCellType.HeaderImg, '头像', null, null,
        info.avatarUrlString, (MineInfoModel model) {}));
    models.add(MineInfoModel(MineInfoCellType.Accessory, '手机号', info.mobile,
        null, null, (MineInfoModel model) {}));
    models.add(MineInfoModel(MineInfoCellType.Accessory, '昵称', info.showName,
        null, null, (MineInfoModel model) {}));
    models.add(MineInfoModel(MineInfoCellType.Accessory, '擦肩号', info.cajianNo,
        null, null, (MineInfoModel model) {}));
    models.add(MineInfoModel(MineInfoCellType.HeaderImg, '我的二维码', null, null,
        'images/icon_settings_gray_qr@2x.png', (MineInfoModel model) {},
        needSeparatorLine: false));
    models.add(MineInfoModel(MineInfoCellType.Separator, null, null, null, null,
        (MineInfoModel model) {},
        needSeparatorLine: false));
    models.add(MineInfoModel(MineInfoCellType.Accessory, '性别', genderStr, null,
        null, (MineInfoModel model) {}));
    models.add(MineInfoModel(MineInfoCellType.Accessory, '生日', info.birth, null,
        null, (MineInfoModel model) {}));
    models.add(MineInfoModel(MineInfoCellType.Accessory, '邮箱', info.email, null,
        null, (MineInfoModel model) {}));
    models.add(MineInfoModel(MineInfoCellType.Accessory, '签名', info.sign, null,
        null, (MineInfoModel model) {}));
    return models;
  }
}

String genderTransString(int type) {
  if (type == 0) {
    //未知性别
    return '未知';
  } else if (type == 1) {
    return '男';
  } else {
    return '女';
  }
}
