/**
 *  Created by chenyn on 2019-07-08
 */


enum MineCellType {
  MineCellTypeProfile,
  MineCellTypeSeparator,
  MineCellTypeOthers,
}

typedef GestureTapCallback = void Function();

class MineModel {
  MineCellType type;
  GestureTapCallback onTap;
  String title;
  String icon;

  static MineModel init(MineCellType type, String title, String icon, GestureTapCallback onTap) {
    var model = new MineModel();
    model.type = type;
    model.title = title;
    model.icon = icon;
    model.onTap = onTap;

    return model;
  }
}

final List<MineModel> entries = [
  MineModel.init(MineCellType.MineCellTypeProfile, null, null, ()=>{

  }),

  MineModel.init(MineCellType.MineCellTypeSeparator, null, null, null),

  MineModel.init(MineCellType.MineCellTypeOthers, '扫一扫', '', ()=>{

  }),

  MineModel.init(MineCellType.MineCellTypeSeparator, null, null, null),

  MineModel.init(MineCellType.MineCellTypeOthers, '我的钱包', '', ()=>{

  }),

  MineModel.init(MineCellType.MineCellTypeOthers, '支付宝钱包', '', ()=>{

  }),

  MineModel.init(MineCellType.MineCellTypeSeparator, null, null, null),

  MineModel.init(MineCellType.MineCellTypeOthers, '收藏', '', ()=>{

  }),

  MineModel.init(MineCellType.MineCellTypeOthers, '分享到微信', '', ()=>{

  }),

  MineModel.init(MineCellType.MineCellTypeOthers, '帮助', '', ()=>{

  }),

  MineModel.init(MineCellType.MineCellTypeSeparator, null, null, null),

  MineModel.init(MineCellType.MineCellTypeOthers, '设置', '', ()=>{
    // 跳转设置页面
    
  }),
];