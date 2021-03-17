import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jdenticon_dart/jdenticon_dart.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:werewolfjudge/resource/firebase_auth_provider.dart';
import 'package:werewolfjudge/resource/firestore_provider.dart';
import 'package:werewolfjudge/resource/shared_prefs_provider.dart';
import 'package:werewolfjudge/ui/instruction_page.dart';
import 'package:werewolfjudge/ui/room_page.dart';
import 'package:werewolfjudge/ui/settings_page.dart';
import 'package:werewolfjudge/util/phone_number_formatter.dart';

import 'code_verification_page.dart';
import 'components/spring_curve.dart';
import 'config_page.dart';
import 'components/main_page_tile.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String userName;

  ///Banner for showing sign-in progress.
  bool shouldShowBanner = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var childHeight = MediaQuery.of(context).size.width / 2;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
          centerTitle: true,
          title: RichText(
              text: TextSpan(style: TextStyle(color: Colors.black87, fontSize: 18), children: [
            TextSpan(text: '狼杀'),
            TextSpan(text: 'wolf-pack-battalion', style: TextStyle(fontFamily: 'Brands', fontSize: 36)),
            TextSpan(text: '法官')
          ]))),
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (_, AsyncSnapshot<User> snapshot) {
          var user = snapshot.data;

          return SingleChildScrollView(
            child: Column(children: <Widget>[
              if (shouldShowBanner) LinearProgressIndicator(),
              Padding(
                padding: EdgeInsets.all(12),
                child: Material(
                    color: Colors.orange,
                    elevation: 8,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    child: InkWell(
                      onTap: user == null ? showLoginOptionDialog : showLogoutBottomSheet,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      splashColor: Colors.orangeAccent,
                      child: Container(
                        width: double.infinity,
                        child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Row(
                              children: <Widget>[
                                if (user != null)
                                  FutureBuilder(
                                    future: FirestoreProvider.instance.getAvatar(user.uid),
                                    builder: (_, AsyncSnapshot<String> urlSnapshot) {
                                      if (urlSnapshot.hasData) {
                                        var url = urlSnapshot.data;

                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(13),
                                          child: FadeInImage.memoryNetwork(
                                            placeholder: kTransparentImage,
                                            image: url,
                                            fit: BoxFit.cover,
                                            width: 26,
                                            height: 26,
                                          ),
                                        );
                                      } else {
                                        String rawSvg = Jdenticon.toSvg(user.uid);
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(13),
                                          child: Stack(
                                            children: [
                                              Container(
                                                height: 26,
                                                width: 26,
                                                color: Colors.white,
                                              ),
                                              SvgPicture.string(
                                                rawSvg,
                                                fit: BoxFit.contain,
                                                height: 26,
                                                width: 26,
                                              ),
                                            ],
                                          )
                                        );
                                      }
                                    },
                                  ),
                                if (user == null) Container(
                                  height: 26,
                                  width: 26,
                                  child: Icon(FontAwesomeIcons.userCircle),
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                if (user == null) Text("登陆"),
                                if (user != null)
                                  FutureBuilder(
                                    future: FirestoreProvider.instance.fetchPlayerDisplayName(user.uid),
                                    builder: (_, snapshot) {
                                      if (snapshot.hasData) {
                                        userName = snapshot.data;

                                        return Text(userName);
                                      }
                                      return Container();
                                    },
                                  ),
                              ],
                            )),
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(16))),
                      ),
                    )),
              ),
              Table(
                columnWidths: {
                  0: FractionColumnWidth(0.5),
                  1: FractionColumnWidth(0.5),
                },
                children: [
                  TableRow(children: [
                    Container(
                      height: childHeight,
                      child: MainPageTile(
                          title: '进入房间',
                          iconTitle: 'person-booth',
                          onTap: () {
                            if (user == null) {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("请先登陆"),
                                action: SnackBarAction(label: '登陆', onPressed: showLoginOptionDialog),
                              ));
                            } else
                              showEnterRoomDialog();
                          }),
                    ),
                    Container(
                      height: childHeight,
                      child: MainPageTile(
                          title: '创建房间',
                          iconTitle: 'concierge-bell',
                          onTap: () {
                            if (user == null) {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("请先登陆"),
                                action: SnackBarAction(label: '登陆', onPressed: showLoginOptionDialog),
                              ));
                            } else
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ConfigPage()));
                          }),
                    ),
                  ]),
                  TableRow(children: [
                    Container(
                      height: childHeight,
                      child: MainPageTile(
                          title: '返回上局',
                          iconTitle: 'arrow-alt-circle-left',
                          onTap: () {
                            if (user == null) {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("请先登陆"),
                                action: SnackBarAction(label: '登陆', onPressed: showLoginOptionDialog),
                              ));
                            } else {
                              var lastRoomNumber = getLastRoomNumber();
                              FirestoreProvider.instance.checkRoom(lastRoomNumber).then((isValid) {
                                if (isValid) {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => RoomPage(roomNumber: lastRoomNumber)));
                                }
                              });
                            }
                          }),
                    ),
                    Container(
                      height: childHeight,
                      child: MainPageTile(
                          title: '设置',
                          iconTitle: 'sliders-v-square',
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage()));
                          }),
                    )
                  ]),
                ],
              ),
              Container(
                height: childHeight,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Material(
                      color: Colors.orange,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      elevation: 8,
                      child: InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InstructionPage())),
                        splashColor: Colors.orangeAccent,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        child: Container(
                          child: Stack(
                            children: <Widget>[
                              Positioned(
                                left: 12,
                                top: 12,
                                child: Text('使用说明', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              ),
                              Positioned(
                                left: 12,
                                top: 36,
                                right: 12,
                                bottom: 12,
                                child: Text(
                                  '1. 当场上有与普通狼人同时见面的技能狼时，狼人夜由技能狼开刀。\n2. 当场上没有与普通狼人同时见面的技能狼时，狼人夜由座位号最小的普通狼人开刀。\n3. 与普通狼人见面的技能狼（如狼美人，白狼王等），在其单独的回合使用其技能。\n4. 在确认完技能发动的对象或状态后，当前角色的回合会立刻结束，进行到下一个角色的回合。故狼人在狼人夜请先讨论战术后，方可开刀。',
                                  overflow: TextOverflow.fade,
                                ),
                              )
                            ],
                          ),
                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(16))),
                        ),
                      )),
                ),
              ),
              SizedBox(height: 12)
            ]),
          );
        },
      ),
    );
  }

  Future<void> showLoginOptionDialog() async {
    return showGeneralDialog<SignInMethod>(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: Duration(milliseconds: 300),
      context: context,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 300,
            width: double.infinity,
            //child: SizedBox.expand(child: FlutterLogo()),
            margin: EdgeInsets.only(top: 120, left: 12, right: 12, bottom: 0),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Column(
              children: <Widget>[
                SizedBox(height: 24),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Transform.scale(
                      scale: 1.24,
                      child: SignInButton(Buttons.Apple, onPressed: () {
                        Navigator.pop(context, SignInMethod.apple);
                      }),
                    )),
                SizedBox(height: 12),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Transform.scale(
                      scale: 1.24,
                      child: SignInButtonBuilder(
                        text: 'Sign in with Google',
                        icon: FontAwesomeIcons.google,
                        onPressed: () {
                          Navigator.pop(context, SignInMethod.google);
                        },
                        backgroundColor: Colors.blue,
                      ),
                    )),
                SizedBox(height: 12),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Transform.scale(
                      scale: 1.24,
                      child: SignInButtonBuilder(
                        text: 'Sign in with Phone',
                        icon: Icons.phone_iphone,
                        onPressed: () {
                          Navigator.pop(context, SignInMethod.phoneNumber);
                        },
                        backgroundColor: Colors.blueGrey[700],
                      ),
                    )),
                SizedBox(height: 12),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Transform.scale(
                      scale: 1.24,
                      child: SignInButtonBuilder(
                        text: 'Sign in Anonymously',
                        icon: FontAwesomeIcons.user,
                        onPressed: () {
                          Navigator.pop(context, SignInMethod.anonymously);
                        },
                        backgroundColor: Colors.orange,
                      ),
                    )),
                SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(CurvedAnimation(parent: anim, curve: SpringCurve.underDamped)),
          child: child,
        );
      },
    ).then((value) {
      if (value != null) {
        switch (value) {
          case SignInMethod.apple:
            setState(() {
              shouldShowBanner = true;
            });
            FirebaseAuthProvider.instance.signInApple().then(showSignInStatus);
            break;
          case SignInMethod.google:
            setState(() {
              shouldShowBanner = true;
            });
            FirebaseAuthProvider.instance.signInGoogle().then(showSignInStatus);
            break;
          case SignInMethod.phoneNumber:
            takePhoneNumber().then(showSignInStatus);
            break;
          case SignInMethod.anonymously:
            setState(() {
              shouldShowBanner = true;
            });
            FirebaseAuthProvider.instance.signInAnonymously().then(showSignInStatus);
            break;
          default:
            throw Exception();
        }
      }
    });
  }

  void showSignInStatus(User user) {
    setState(() {
      shouldShowBanner = false;
    });
    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('登陆成功'),
        action: SnackBarAction(
          label: '好',
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('登陆失败'),
        action: SnackBarAction(
          label: '好',
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ));
    }
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
                      maxLengthEnforcement: MaxLengthEnforcement.truncateAfterCompositionEnds,
                      maxLength: 40,
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
                      child: ElevatedButton(
                        child: Padding(
                          padding: EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 12),
                          child: Text('改变名称', style: TextStyle(fontSize: 18)),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        onPressed: () {
                          var name = textEditingController.text;
                          FirebaseAuthProvider.instance.changeName(name);
                          Navigator.pop(context);

                          setState(() {
                            userName = name;
                          });
                        },
                      ),
                    ))
              ],
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(CurvedAnimation(parent: anim, curve: SpringCurve.underDamped)),
          child: child,
        );
      },
    ).then((phoneNumber) {
      debugPrint("The phone number is $phoneNumber");
      if (phoneNumber != null) Navigator.push(context, MaterialPageRoute(builder: (_) => CodeVerificationPage(phoneNumber: phoneNumber)));
    });
  }

  Future<User> takePhoneNumber() async {
    final textEditingController = TextEditingController();

    return showGeneralDialog<String>(
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
                      autofillHints: [AutofillHints.telephoneNumber],
                      controller: textEditingController,
                      keyboardType: TextInputType.number,
                      maxLengthEnforcement: MaxLengthEnforcement.truncateAfterCompositionEnds,
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
                      child: ElevatedButton(
                        child: Padding(
                          padding: EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 12),
                          child: Text('发送验证码', style: TextStyle(fontSize: 18)),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        onPressed: () {
                          var number = textEditingController.text.replaceAll('-', '');
                          Navigator.pop(context, number);
                        },
                      ),
                    ))
              ],
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(CurvedAnimation(parent: anim, curve: SpringCurve.underDamped)),
          child: child,
        );
      },
    ).then<User>((phoneNumber) {
      debugPrint("The phone number is $phoneNumber");
      setState(() {
        shouldShowBanner = true;
      });
      if (phoneNumber != null)
        return Navigator.push<User>(context, MaterialPageRoute(builder: (_) => CodeVerificationPage(phoneNumber: phoneNumber)));
      return null;
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
                  child: Material(color: Colors.transparent, child: Text('输入房间号码')),
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
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(CurvedAnimation(parent: anim, curve: SpringCurve.underDamped)),
          child: child,
        );
      },
    );
  }

  void showLoginRequestDialog() {
    Widget continueButton = TextButton(
      child: Text("确定"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("请先登陆"),
      actions: [
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showDeleteAvatarDialog() {
    Widget cancelButton = TextButton(
        child: Text("取消"),
        onPressed: () {
          Navigator.pop(context);
        });

    Widget confirmButton = TextButton(
        child: Text("确定", style: TextStyle(color: Colors.red)),
        onPressed: () {
          var uid = FirebaseAuthProvider.instance.currentUser.uid;

          FirestoreProvider.instance.deleteAvatar(uid).then((value) {
            setState(() {});
          });

          Navigator.pop(context);
        });

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("删除头像"),
            content: Text("确定吗？"),
            elevation: 8,
            actions: [
              cancelButton,
              confirmButton,
            ],
          );
        });
  }

  void showLogoutBottomSheet() {
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
                  child: Text('编辑头像', style: TextStyle(color: Colors.blue)),
                  onPressed: () async {
                    Navigator.pop(context);
                    pickAvatar().then((value) {
                      if(value == null) return;
                      value.onComplete.then((value) {
                        setState(() {});
                      });
                    });
                  },
                ),
                if (FirebaseAuthProvider.instance.currentUser.uid != null)
                  CupertinoActionSheetAction(
                    child: Text('删除头像', style: TextStyle(color: Colors.red)),
                    onPressed: () async {
                      Navigator.pop(context);
                      showDeleteAvatarDialog();
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
  }

  String getLastRoomNumber() {
    return SharedPreferencesProvider.instance.getLastRoom();
  }

  Future<StorageUploadTask> pickAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery, imageQuality: 85);

    if(pickedFile == null) return null;

    File croppedFile = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: '裁剪',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(minimumAspectRatio: 1.0, aspectRatioLockEnabled: true));

    if (croppedFile == null) return null;

    var bytes = await croppedFile.readAsBytes();
    var user = FirebaseAuthProvider.instance.currentUser;

    return FirestoreProvider.instance.uploadAvatar(user.uid, bytes);
  }
}
