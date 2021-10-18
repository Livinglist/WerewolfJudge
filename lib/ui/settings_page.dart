import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'package:werewolfjudge/resource/constants.dart';
import 'package:werewolfjudge/resource/shared_prefs_provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool showArtwork, shouldVibrate = false;
  String funFact;

  @override
  void initState() {
    Vibration.hasCustomVibrationsSupport().then((hasCoreHaptics) {
      setState(() {
        shouldVibrate = hasCoreHaptics;
      });
    });

    showArtwork = SharedPreferencesProvider.instance.getArtworkEnabled();

    funFact = funFacts.elementAt(Random(DateTime.now().microsecond).nextInt(funFacts.length));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('设置'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('报告Bug'),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                        content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          child: Row(
                            children: <Widget>[
                              Icon(FontAwesomeIcons.github),
                              SizedBox(
                                width: 12,
                              ),
                              Text("Github"),
                            ],
                          ),
                          onPressed: () => launch('https://github.com/Livinglist/WerewolfJudge/issues/new'),
                        ),
                        ElevatedButton(
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.email),
                              SizedBox(
                                width: 12,
                              ),
                              Text("Email"),
                            ],
                          ),
                          onPressed: onSendEmailTapped,
                        ),
                      ],
                    ));
                  });
            },
          ),
          Divider(height: 0),
          Container(
            height: 240,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("¯\\_(ツ)_/¯", textAlign: TextAlign.center),
                  Text(funFact, textAlign: TextAlign.center,),
                ],
              )
            ),
          ),
          Divider(height: 0),
          SwitchListTile(
              title: Text('展示角色画像'),
              value: showArtwork,
              onChanged: (val) {
                Vibration.cancel().then((_) {
                  Vibration.vibrate(pattern: [0, 5], intensities: [125]);
                });

                SharedPreferencesProvider.instance.setArtworkEnabled(val);
                setState(() {
                  showArtwork = val;
                });
              }),
          Divider(height: 0),
          AboutListTile(
            applicationIcon: Container(
              height: 50,
              width: 50,
              child: Image.asset(
                'assets/app_icon.png',
                fit: BoxFit.contain,
              ),
            ),
            applicationName: "萌狼",
            applicationVersion: "v0.1.4",
            aboutBoxChildren: <Widget>[
              ElevatedButton(
                onPressed: () {
                  launch("https://livinglist.github.io");
                },
                child: Row(
                  children: <Widget>[
                    Icon(FontAwesomeIcons.addressCard),
                    SizedBox(
                      width: 12,
                    ),
                    Text("作者"),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  launch("https://github.com/Livinglist/WerewolfJudge");
                },
                child: Row(
                  children: <Widget>[
                    Icon(FontAwesomeIcons.github),
                    SizedBox(
                      width: 12,
                    ),
                    Text("源代码"),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void onSendEmailTapped() async {
    final Uri emailUri = Uri(
        scheme: 'mailto', path: 'werewolfJudgeBug@gmail.com', queryParameters: {'subject': '什么垃圾app，又找到了一个bug！', 'body': '请大致描述bug发生的场景及激发bug的行为：'});

    var res = await canLaunch(emailUri.toString());

    if (res) {
      launch(emailUri.toString());
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('出现了未知的问题'),
        action: SnackBarAction(label: '这真是太棒了', onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar()),
      ));
    }
  }
}
