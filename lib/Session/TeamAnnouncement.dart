/// Created by chenyn 2019-12-09
/// 群公告
///
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Base/CJUtils.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';

class TeamAnnouncementPage extends StatefulWidget {
  final Map params;
  TeamAnnouncementPage({Key key, this.params}) : super(key: key);

  @override
  _TeamAnnouncementPageState createState() => _TeamAnnouncementPageState();
}

class _TeamAnnouncementPageState extends State<TeamAnnouncementPage> {
  TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() { 
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(widget.params['announcement'] != null) {
      _controller.text = widget.params['announcement'];
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: new IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              FlutterBoost.singleton.closeCurrent();
            },
          ),
          title: Text(
            '群公告',
            style: TextStyle(color: blackColor),
          ),
          actions: <Widget>[
            CupertinoButton(
              child: Text('确定'),
              onPressed: () => NimSdkUtil.updateAnnouncement(
                  _controller.text, widget.params['teamId']),
            )
          ],
          backgroundColor: mainBgColor,
          elevation: 0.01,
          iconTheme: IconThemeData.fallback(),
        ),
        body: Container(
          margin: EdgeInsets.all(12),
          constraints: BoxConstraints(minHeight: 180),
          child: CupertinoTextField(
            maxLines: 50,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(3.0))),
            placeholder: widget.params['announcement'] == null
                ? '还未设置群公告呢～'
                : widget.params['announcement'],
          ),
        ),
      ),
    );
  }
}
