import 'package:cajian/Base/CJUtils.dart';
import 'package:cajian/Mine/Model/MineInfoModel.dart';
import 'package:flutter/material.dart';

class MineInfoAccessoryCell extends StatelessWidget{

  final MineInfoModel model;
  MineInfoAccessoryCell(this.model);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
     Size screenSize = getSize(context);
    return GestureDetector(
      child: Container(
        height: 48,
        width: screenSize.width,
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(padding: EdgeInsets.symmetric(horizontal: 10),),
            Text(model.title),
            Expanded(flex: 1, child: SizedBox(),),
            Text(model.subTitle??''),
            Padding(padding: EdgeInsets.symmetric(horizontal: 4),),
            Icon(Icons.arrow_forward_ios, size: 16,),
            Padding(padding: EdgeInsets.symmetric(horizontal: 6),),
          ],
        ),
      ),
      onTap: (){
        model.onTap(model);
      });
  }
}

class MineInfoSeparatorCell extends StatelessWidget {
  MineInfoSeparatorCell(MineInfoModel model);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      color: MainBgColor,
    );
  }
}