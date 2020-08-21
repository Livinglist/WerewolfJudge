import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'package:werewolfjudge/resource/shared_prefs_provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool showArtwork, shouldVibrate = false;

  @override
  void initState() {
    Vibration.hasCustomVibrationsSupport().then((hasCoreHaptics) {
      setState(() {
        shouldVibrate = hasCoreHaptics;
      });
    });

    showArtwork = SharedPreferencesProvider.instance.getArtworkEnabled();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            height: 250,
            child: Center(
              child: Text("¯\\_(ツ)_/¯"),
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
            applicationVersion: "v0.0.7",
            aboutBoxChildren: <Widget>[
              RaisedButton(
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
              RaisedButton(
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
}
