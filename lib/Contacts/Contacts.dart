/**
 *  Created by chenyn on 2019-06-28
 *  通讯录
 */

import 'package:flutter/material.dart';

class ContactsWidget extends StatefulWidget {

  ContactsState createState() {
    return new ContactsState();
  }

}

class ContactsState extends State<ContactsWidget> {

  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Center(
        child: Text(
          'Index 1: 通讯录',
          style: optionStyle,
        ),
      ),
    );
  }
}