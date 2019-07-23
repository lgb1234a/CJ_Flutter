/**
 *  Created by chenyn on 2019-07-23
 *  设置cell
 */
import 'package:flutter/material.dart';
import 'package:cajian/Base/CJUtils.dart';
import 'package:cajian/Mine/Model/SettingModel.dart';
class SettingFuncitonCell extends StatelessWidget
{
  final SettingModel model;

  SettingFuncitonCell(this.model);
  @override
  Widget build(BuildContext context) {
    Size screenSize = getSize(context);
    return GestureDetector(
      child: Container(
        height: 48,
        width: screenSize.width,
        color: Color(0x00000000),
        child: Center(
          child: Text(model.title, style: TextStyle(color: model.titleColor),),
        ),
      ),
      onTap: (){
        model.onTap(context);
      },
    );
  }
}

class SettingSeparatorCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8
    );
  }
}

class SettingAccessoryCell extends StatelessWidget {
  final SettingModel model;
  SettingAccessoryCell(this.model);
  @override
  Widget build(BuildContext context) {
    Size screenSize = getSize(context);
    return GestureDetector(
      child: Container(
        height: 48,
        width: screenSize.width,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(model.title),
            Expanded(flex: 1, child: SizedBox(),),
            Text(model.subTitle??''),
            Icon(Icons.arrow_forward_ios, size: 16,)
          ],
        ),
      ),
      onTap: (){
        model.onTap(context);
      },
    );
  }
}

