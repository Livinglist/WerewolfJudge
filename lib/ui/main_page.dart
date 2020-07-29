import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:werewolfjudge/resource/firebase_auth_provider.dart';
import 'package:werewolfjudge/resource/firestore_provider.dart';
import 'package:werewolfjudge/ui/room_page.dart';
import 'package:werewolfjudge/util/phone_number_formatter.dart';

import 'code_verification_page.dart';
import 'config_page.dart';
import 'components/main_page_tile.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String userName;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('狼杀小法官'),
      ),
      body: Column(
        children: <Widget>[
          StreamBuilder(
            stream: FirebaseAuth.instance.onAuthStateChanged,
            builder: (_, AsyncSnapshot<FirebaseUser> snapshot) {
              if (snapshot.hasData) {
                var user = snapshot.data;
                userName = userName ?? user.displayName;

                return Padding(
                  padding: EdgeInsets.all(12),
                  child: Material(
                      color: Colors.orangeAccent,
                      elevation: 8,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      child: InkWell(
                        onTap: () {
                          if (Platform.isIOS) {
                            showCupertinoModalPopup(
                                context: context,
                                builder: (BuildContext context) => CupertinoActionSheet(
                                      cancelButton: CupertinoActionSheetAction(
                                        isDefaultAction: true,
                                        child: Text('Cancel'),
                                        onPressed: () {
                                          Navigator.pop(context, null);
                                        },
                                      ),
                                      actions: <Widget>[
                                        CupertinoActionSheetAction(
                                          child: Text('编辑名称', style: TextStyle(color: Colors.blue)),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            changeNameDialog(userName ?? '');
                                          },
                                        ),
                                        CupertinoActionSheetAction(
                                          isDefaultAction: true,
                                          child: Text('登出'),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            FirebaseAuthProvider.instance.signOut();
                                          },
                                        ),
                                      ],
                                    )).then((value) => value ?? null);
                          } else {}
                        },
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        child: Container(
                          width: double.infinity,
                          child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Row(
                                children: <Widget>[
                                  Icon(FontAwesomeIcons.signInAlt),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Text(userName ?? user.uid),
                                ],
                              )),
                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(16))),
                        ),
                      )),
                );
              }

              return Padding(
                padding: EdgeInsets.all(12),
                child: Material(
                    color: Colors.orangeAccent,
                    elevation: 8,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    child: InkWell(
                      onTap: () {
                        if (Platform.isIOS) {
                          showCupertinoModalPopup<SignInMethod>(
                              context: context,
                              builder: (BuildContext context) => CupertinoActionSheet(
                                    cancelButton: CupertinoActionSheetAction(
                                      isDefaultAction: true,
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Navigator.pop(context, null);
                                      },
                                    ),
                                    actions: <Widget>[
                                      CupertinoActionSheetAction(
                                        child: Text('Apple', style: TextStyle(color: Colors.blue)),
                                        onPressed: () {
                                          Navigator.pop(context, SignInMethod.apple);
                                          FirebaseAuthProvider.instance.signInApple();
                                        },
                                      ),
                                      CupertinoActionSheetAction(
                                        child: Text('Gmail', style: TextStyle(color: Colors.blue)),
                                        onPressed: () {
                                          Navigator.pop(context, SignInMethod.google);
                                          FirebaseAuthProvider.instance.signInGoogle();
                                        },
                                      ),
                                      CupertinoActionSheetAction(
                                        child: Text('Phone Number', style: TextStyle(color: Colors.blue)),
                                        onPressed: () {
                                          Navigator.pop(context);

                                          takePhoneNumber();
                                        },
                                      ),
                                    ],
                                  )).then((value) => value ?? null);
                        } else {}
                      },
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      child: Container(
                        width: double.infinity,
                        child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Row(
                              children: <Widget>[
                                Icon(FontAwesomeIcons.signInAlt),
                                SizedBox(
                                  width: 12,
                                ),
                                Text('登陆'),
                              ],
                            )),
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(16))),
                      ),
                    )),
              );
            },
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                MainPageTile(
                    title: '进入房间',
                    onTap: () {
                      ///Todo: Enter room number.
                      ///Navigator.push(context, MaterialPageRoute(builder: (_) => RoomPage()));
                      showEnterRoomDialog();
                    }),
                MainPageTile(
                    title: '创建房间',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ConfigPage()));
                    }),
                MainPageTile(
                    title: '返回上局',
                    onTap: () {
                      //Navigator.push(context, MaterialPageRoute(builder: (_) => RoomPage()));
                    }),
                MainPageTile(
                    title: '历史记录',
                    onTap: () {
                      //Navigator.push(context, MaterialPageRoute(builder: (_) => ConfigPage()));
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> changeNameDialog(String currentName) async {
    final textEditingController = TextEditingController()..text = currentName;

    showGeneralDialog<String>(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 300),
      context: context,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: 240,
            //child: SizedBox.expand(child: FlutterLogo()),
            margin: EdgeInsets.only(top: 120, left: 12, right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Column(
              children: <Widget>[
                SizedBox(height: 24),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: TextField(
                      controller: textEditingController,
                      maxLengthEnforced: true,
                      maxLength: 10,
                      maxLines: 1,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Padding(
                    padding: EdgeInsets.only(top: 12, left: 24, right: 24),
                    child: Material(
                      color: Colors.transparent,
                      child: RaisedButton(
                        child: Padding(
                          padding: EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 12),
                          child: Text('改变名称', style: TextStyle(fontSize: 18)),
                        ),
                        onPressed: () {
                          var name = textEditingController.text;
                          FirebaseAuthProvider.instance.changeName(name);
                          Navigator.pop(context);

                          ///It is not the best practice to update the user name this way, Im doing it this way
                          ///because FirebaseAuth.reload() does not emmit new event to [onAuthStateChanged]
                          setState(() {
                            userName = name;
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                    ))
              ],
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    ).then((phoneNumber) {
      debugPrint("The phone number is $phoneNumber");
      if (phoneNumber != null) Navigator.push(context, MaterialPageRoute(builder: (_) => CodeVerificationPage(phoneNumber: phoneNumber)));
    });
  }

  Future<void> takePhoneNumber() async {
    final textEditingController = TextEditingController();

    showGeneralDialog<String>(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 300),
      context: context,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: 240,
            //child: SizedBox.expand(child: FlutterLogo()),
            margin: EdgeInsets.only(top: 120, left: 12, right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Column(
              children: <Widget>[
                SizedBox(height: 24),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: TextField(
                      controller: textEditingController,
                      keyboardType: TextInputType.number,
                      maxLengthEnforced: true,
                      maxLength: 12,
                      maxLines: 1,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 36),
                      inputFormatters: [PhoneNumberFormatter()],
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Padding(
                    padding: EdgeInsets.only(top: 12, left: 24, right: 24),
                    child: Material(
                      color: Colors.transparent,
                      child: RaisedButton(
                        child: Padding(
                          padding: EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 12),
                          child: Text('发送验证码', style: TextStyle(fontSize: 18)),
                        ),
                        onPressed: () {
                          var number = textEditingController.text.replaceAll('-', '');
                          Navigator.pop(context, number);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                    ))
              ],
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    ).then((phoneNumber) {
      debugPrint("The phone number is $phoneNumber");
      if (phoneNumber != null) Navigator.push(context, MaterialPageRoute(builder: (_) => CodeVerificationPage(phoneNumber: phoneNumber)));
    });
  }

  void showEnterRoomDialog() {
    final TextEditingController textEditingController = TextEditingController();

    StreamController<ErrorAnimationType> errorController = StreamController<ErrorAnimationType>();

    showGeneralDialog<String>(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 300),
      context: context,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: 240,
            //child: SizedBox.expand(child: FlutterLogo()),
            margin: EdgeInsets.only(top: 120, left: 12, right: 12),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Material(color: Colors.transparent,child: Text('输入房间号码')),
                ),
                SizedBox(height: 24),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: PinCodeTextField(
                        length: 4,
                        obsecureText: false,
                        textInputType: TextInputType.number,
                        animationType: AnimationType.fade,
                        autoFocus: true,
                        pinTheme: PinTheme(
                            shape: PinCodeFieldShape.underline,
                            borderRadius: BorderRadius.circular(5),
                            fieldHeight: 50,
                            fieldWidth: 40,
                            activeFillColor: Colors.transparent,
                            inactiveColor: Colors.white,
                            selectedFillColor: Colors.transparent,
                            selectedColor: Colors.deepOrange,
                            activeColor: Colors.orangeAccent,
                            inactiveFillColor: Colors.transparent),
                        animationDuration: Duration(milliseconds: 300),
                        backgroundColor: Colors.transparent,
                        enableActiveFill: true,
                        errorAnimationController: errorController,
                        controller: textEditingController,
                        onCompleted: (roomNum) {
                          FirestoreProvider.instance.checkRoom(roomNum).then((isValid) {
                            if (isValid) {
                              errorController.close();
                              Navigator.pop(context);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => RoomPage(roomNumber: roomNum)));
                            } else {
                              errorController.add(ErrorAnimationType.shake);
                              textEditingController.clear();
                            }
                          });
                        },
                        onChanged: (value) {},
                        beforeTextPaste: (text) {
                          print("Allowing to paste $text");
                          //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                          //but you can show anything you want here, like your pop up saying wrong paste format or etc
                          return true;
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }
}
