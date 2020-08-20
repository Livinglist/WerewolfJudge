import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:werewolfjudge/resource/firebase_auth_provider.dart';

class CodeVerificationPage extends StatefulWidget {
  final String phoneNumber;

  CodeVerificationPage({@required this.phoneNumber}) : assert(phoneNumber != null);

  @override
  _CodeVerificationPageState createState() => _CodeVerificationPageState();
}

class _CodeVerificationPageState extends State<CodeVerificationPage> {
  final TextEditingController textEditingController = TextEditingController();

  StreamController<ErrorAnimationType> errorController = StreamController<ErrorAnimationType>();

  String verificationId;

  @override
  void initState() {
    signIn();

    super.initState();
  }

  @override
  void dispose() {
    errorController.close();
    //textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0),
      backgroundColor: Colors.orange,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          //VerificationCodeInput(key: verCodeInputFieldKey, keyboardType: TextInputType.number, length: 6, onCompleted: (str) => verifyCode(str)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: PinCodeTextField(
              length: 6,
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
              onCompleted: (code) {
                verifyCode(code);
              },
              onChanged: (value) {
//              print(value);
//              setState(() {
//                currentText = value;
//              });
              },
              beforeTextPaste: (text) {
                print("Allowing to paste $text");
                //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                //but you can show anything you want here, like your pop up saying wrong paste format or etc
                return true;
              },
            ),
          ),
          SizedBox(
            height: 12,
          ),
          Padding(
              padding: EdgeInsets.only(top: 12, left: 24, right: 24),
              child: Material(
                color: Colors.transparent,
                child: RaisedButton(
                  child: Padding(
                    padding: EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 12),
                    child: Text('登陆', style: TextStyle(fontSize: 18)),
                  ),
                  onPressed: () {},
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ))
        ],
      ),
    );
  }

  void verifyCode(String smsCode) {
    debugPrint("The code is $smsCode");
    AuthCredential authCredential = PhoneAuthProvider.credential(verificationId: this.verificationId, smsCode: smsCode);

    FirebaseAuthProvider.instance.signInPhoneNumber(widget.phoneNumber, authCredential).then((value) {
      if (value == null) {
        errorController.add(ErrorAnimationType.shake);
        textEditingController.clear();
      } else {
        Navigator.pop(context);
      }
    });
  }

  void signIn() {
    var phoneNumber = widget.phoneNumber;
    final PhoneVerificationCompleted phoneVerificationCompleted = (AuthCredential authCredential) {};

    final PhoneVerificationFailed phoneVerificationFailed = (FirebaseAuthException authExp) {
      print(authExp.message);
    };

    final PhoneCodeSent phoneCodeSent = (String verificationId, [int forceResendingToken]) async {
//      AuthCredential authCredential = PhoneAuthProvider.getCredential(verificationId: verificationId, smsCode: smsCode.toString());
//      firebaseAuth.signInWithCredential(authCredential);
      debugPrint("the verificationId is $verificationId");
      this.verificationId = verificationId;
    };

    final PhoneCodeAutoRetrievalTimeout phoneCodeAutoRetrievalTimeout = (String verificationId) {
      this.verificationId = verificationId;
      debugPrint("time out");
    };

    debugPrint("Verifying +1$phoneNumber");

    ///If you use the device whose phone number is the same number you use for this authentication,
    ///Firebase will actually automatically retrieve the sms code and sign you in without you having
    ///to type in the received sms code.
    FirebaseAuth.instance
        .verifyPhoneNumber(
            phoneNumber: "+1$phoneNumber",
            timeout: Duration(seconds: 60),
            verificationCompleted: phoneVerificationCompleted,
            verificationFailed: phoneVerificationFailed,
            codeSent: phoneCodeSent,
            codeAutoRetrievalTimeout: phoneCodeAutoRetrievalTimeout)
        .whenComplete(() {});
  }
}
