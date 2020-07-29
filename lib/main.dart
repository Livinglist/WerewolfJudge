import 'package:flutter/material.dart';
import 'package:werewolfjudge/ui/main_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '狼杀小法官',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MainPage()
    );
  }
}
