import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:werewolfjudge/resource/shared_prefs_provider.dart';
import 'package:werewolfjudge/ui/main_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SharedPreferencesProvider.instance.initSharedPrefs();

    return MaterialApp(
        title: '萌狼',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: FutureBuilder(
          future: Firebase.initializeApp(),
          builder: (_, snapshot) {
            if (!snapshot.hasData) return Container();
            return MainPage();
          },
        ));
  }
}
