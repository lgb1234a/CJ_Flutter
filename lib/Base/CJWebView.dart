/// Created by chenyn 2019-12-09
/// webView

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../Base/CJUtils.dart';
import 'package:flutter_boost/flutter_boost.dart';

class CJWebView extends StatefulWidget {
  final Map params;
  CJWebView({Key key, this.params}) : super(key: key);

  @override
  _CJWebViewState createState() => _CJWebViewState(params);
}

class _CJWebViewState extends State<CJWebView> {
  final String _url;
  final String _title;

  factory _CJWebViewState(Map params) {
    return _CJWebViewState._a(params['url'], params['title']);
  }

  _CJWebViewState._a(this._url, this._title);

  @override
  Widget build(BuildContext context) {
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
            _title == null? '' : _title,
            style: TextStyle(color: blackColor),
          ),
          backgroundColor: mainBgColor,
          elevation: 0.01,
          iconTheme: IconThemeData.fallback(),
        ),
        body: Container(
          child: WebView(
            initialUrl: _url,
            javascriptMode: JavascriptMode.unrestricted,
          ),
        ),
      ),
    );
  }
}
