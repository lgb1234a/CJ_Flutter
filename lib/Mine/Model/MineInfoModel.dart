
import 'package:flutter/cupertino.dart';

enum MineInfoCellType {
  HeaderImg,    // 头像和图片
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
  String iconTip;
  MineInfoModel(
    this.cellType, 
    this.title, 
    this.subTitle, 
    this.titleColor, 
    this.iconTip,
    this.onTap,
    {this.needSeparatorLine = true}
  );
}

final List<MineInfoModel> mineInfoCellModels = [

  MineInfoModel(MineInfoCellType.HeaderImg, '头像', null, null,'http://pic27.nipic.com/20130321/9678987_225139671149_2.jpg', (MineInfoModel model){
    
  }),
  MineInfoModel(MineInfoCellType.Accessory, '手机号', '15507918906', null, 'images/login_bg@2x.png',(MineInfoModel model){


  }),
  MineInfoModel(MineInfoCellType.Accessory, '昵称', '123', null, null,(MineInfoModel model){


  }),
  MineInfoModel(MineInfoCellType.Accessory, '擦肩号', null, null, null,(MineInfoModel model){


  }),
  MineInfoModel(MineInfoCellType.Accessory, '我的二维码', null, null, null,(MineInfoModel model){


  },needSeparatorLine:false),
  MineInfoModel(MineInfoCellType.Separator, null, null, null, null,(MineInfoModel model){


  },needSeparatorLine:false),
  MineInfoModel(MineInfoCellType.Accessory, '性别', null, null, null,(MineInfoModel model){


  }),
  MineInfoModel(MineInfoCellType.Accessory, '生日', null, null, null,(MineInfoModel model){


  }),
  MineInfoModel(MineInfoCellType.Accessory, '邮箱', null, null, null,(MineInfoModel model){


  }),
  MineInfoModel(MineInfoCellType.Accessory, '签名', null, null, null,(MineInfoModel model){


  }),

];
