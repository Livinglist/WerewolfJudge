import 'package:flutter/material.dart';
import 'package:werewolfjudge/resource/shared_prefs_provider.dart';
import 'package:werewolfjudge/ui/main_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    SharedPreferencesProvider.instance.initSharedPrefs();

    return MaterialApp(
      title: '狼杀小法官',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MainPage()
    );
  }
}
