/**
 *  Created by chenyn on 2019-07-08
 */
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:cajian/Base/CJUtils.dart';
import 'package:cajian/Mine/Model/MineModel.dart';

class MineListCellOthers extends StatelessWidget {

  final MineModel model;
  MineListCellOthers(this.model);

  @override
  Widget build(BuildContext context) {
    Size screenSize = getSize(context);
    return GestureDetector(
        child: Container(
          height: 48,
          width: screenSize.width,
          color: Color(0x00FFFFFF),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Icon(Icons.settings, size: 20),
              new Text(model.title, ),
              Expanded(flex: 1, child: SizedBox(),),
              new Icon(Icons.arrow_forward_ios, size: 16,)
            ],
          ),
        ),
        onTap: (){
          model.onTap(context);
        },
    );
  }
}

class MineListCellSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 8,
    );
  }
}