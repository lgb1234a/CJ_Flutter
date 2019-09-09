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
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
            ),
            new Image.asset(model.icon),
            new Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
            ),
            new Text(
              model.title,
            ),
            new Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
            ),
            model.tipIcon != null
                ? new Image.asset(model.tipIcon)
                : Divider(height: 0),
            Expanded(
              flex: 1,
              child: SizedBox(),
            ),
            new Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
            ),
          ],
        ),
      ),
      onTap: () {
        model.onTap(this.model);
      },
    );
  }
}

class MineListCellSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      color: MainBgColor,
    );
  }
}

// 用户信息
class MineListProfileHeader extends StatefulWidget {
  final MineModel model;
  MineListProfileHeader(this.model);

  MineListProfileState createState() {
    return MineListProfileState();
  }
}

class MineListProfileState extends State<MineListProfileHeader> {
  String _avatarUrl;
  String _showName;
  String _cajianNo;

  @override
  initState() {
    super.initState();

    fetchInfo();
  }

  fetchInfo() async {
    dynamic info = await widget.model.mineInfo();
    setState(() {
      _avatarUrl = info['avatarUrl'];
      _showName = info['name'];
      _cajianNo = info['cajian_no'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 103,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
            _avatarUrl != null
                ? Image.network(_avatarUrl, width: 56)
                : Container(
                    color: Colors.grey,
                    width: 56,
                    height: 56,
                  ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
            ),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _showName ?? '',
                  style: TextStyle(fontSize: 17, color: BlackColor),
                ),
                Text(
                  '擦肩号：$_cajianNo',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9B9B9B),
                  ),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
              ],
            )),
            Image.asset(
              'images/icon_settings_gray_qr@2x.png',
              width: 14,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
            new Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
            ),
          ],
        ));
  }
}
