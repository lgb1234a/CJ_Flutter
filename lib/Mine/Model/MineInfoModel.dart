
import 'package:flutter/cupertino.dart';

enum MineInfoCellType {
  Function,    // 功能按钮
  Accessory,   // 入口
  Separator,   // 分割
} 

typedef TapCallback = void Function(MineInfoModel model);
class MineInfoModel {
  @required MineInfoCellType cellType;
  String title;
  String subTitle;
  Color  titleColor;
  TapCallback onTap;
  bool needSeparatorLine;
  BuildContext ctx;

  MineInfoModel(
    this.cellType, 
    this.title, 
    this.subTitle, 
    this.titleColor, 
    this.onTap, 
    {this.needSeparatorLine = true}
  );
}

final List<MineInfoModel> mineInfoCellModels = [

  MineInfoModel(MineInfoCellType.Accessory, '头像', null, null, (MineInfoModel model){


  }),
  MineInfoModel(MineInfoCellType.Accessory, '手机号', null, null, (MineInfoModel model){


  }),
  MineInfoModel(MineInfoCellType.Accessory, '昵称', null, null, (MineInfoModel model){


  }),
  MineInfoModel(MineInfoCellType.Accessory, '擦肩号', null, null, (MineInfoModel model){


  }),
  MineInfoModel(MineInfoCellType.Accessory, '我的二维码', null, null, (MineInfoModel model){


  },needSeparatorLine:false),
  MineInfoModel(MineInfoCellType.Separator, null, null, null, (MineInfoModel model){


  },needSeparatorLine:false),
  MineInfoModel(MineInfoCellType.Accessory, '性别', null, null, (MineInfoModel model){


  }),
  MineInfoModel(MineInfoCellType.Accessory, '生日', null, null, (MineInfoModel model){


  }),
  MineInfoModel(MineInfoCellType.Accessory, '邮箱', null, null, (MineInfoModel model){


  }),
  MineInfoModel(MineInfoCellType.Accessory, '签名', null, null, (MineInfoModel model){


  }),

];