import 'dart:math';

import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

enum SignInMethod { apple, google, phoneNumber, anonymously }

class FirebaseAuthProvider {
  static final instance = FirebaseAuthProvider._();

  User get currentUser => FirebaseAuth.instance.currentUser;

  FirebaseAuthProvider._();

  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
    ],
  );

  Future uploadUser(User firebaseUser) async {
    return FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).set({
      'email': firebaseUser.email,
    });
  }

  Future<User> registerNewUser(String email, String password) async {
    return FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password).then((UserCredential cred) {
      //verify email address
      cred.user.sendEmailVerification();

      var name = getRandomName();

      FirebaseFirestore.instance.collection(usersKey).doc(cred.user.uid).set({
        userNameKey : name
      });
      return cred.user;
    });
  }

  Future<User> signInUser(String email, String password) async {
    return FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).then((UserCredential cred) async {
      if (cred.user.emailVerified || true) {
        var firebaseUser = cred.user;
        return firebaseUser;
      } else {
        var firebaseUser = cred.user;
        return firebaseUser;
        // return Future.value(null);
      }
    }).catchError((Object err) {
      print(err);
      throw err;
    });
  }

  ///Sign in user silently if previously signed in.
  @Deprecated("FirebaseAuth will automatically sign in the user.")
  Future<FirebaseUser> signInUserSilently() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    String email = sharedPrefs.getString('email');
    String password = sharedPrefs.getString('password');
    print(email);
    if (email != null && password != null) {
      print(email);
      return FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).then((UserCredential cred) {
        return cred.user;
      }).catchError((_) {});
    } else {
      return Future.value(null);
    }
  }

  Future signOut() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.remove('email');
    sharedPrefs.remove('password');
    FirebaseAuth.instance.signOut();
  }

  Future forgetPassword(String email) async {
    FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<User> signInApple() async {
    var firebaseAuth = FirebaseAuth.instance;
    var sharedPrefs = await SharedPreferences.getInstance();

    if (await AppleSignIn.isAvailable()) {
      final result = await AppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);

      if (result.status == AuthorizationStatus.authorized) {
        var appleIdCredential = result.credential;

        var userId = appleIdCredential.user;

        var email = appleIdCredential.email;
        var password = appleIdCredential.email;

        if (appleIdCredential.email == null) {
          email = sharedPrefs.getString(emailKey);
          password = sharedPrefs.getString(passwordKey);

          if (email == null) {
            var snapshot = await FirebaseFirestore.instance.collection('appleIdToEmail').doc(userId).get();
            email = snapshot.data()[emailKey];
            password = snapshot.data()[passwordKey];
          }

          return firebaseAuth.signInWithEmailAndPassword(email: email, password: password).then((userCred) {
            return userCred.user;
          }, onError: (Object error) {
            if (error is FirebaseAuthException) {
              if (error.code == 'user-not-found') {
                return registerNewUser(email, password).then((value) {
                  return value;
                }, onError: (_) {
                  print(_);
                });
              }
            }

            return null;
          });
        } else {
          return firebaseAuth.signInWithEmailAndPassword(email: email, password: password).then((authResult) {
            return authResult.user;
          }, onError: (Object error) {
            if (error is FirebaseAuthException) {
              if (error.code == 'user-not-found') {
                return registerNewUser(appleIdCredential.email, appleIdCredential.email).then((firebaseUser) {
                  return firebaseUser;
                }).whenComplete(() {
                  FirebaseFirestore.instance.collection('appleIdToEmail').doc(userId).set({
                    'email': email,
                    'password': password,
                  });
                });
              }
            }
            return null;
          });
        }
      } else {
        return Future.value(null);
      }
    } else {
      print('Apple SignIn is not available for your device');
      return Future.value(null);
    }
  }

  Future<User> signInGoogle() async {
    var firebaseAuth = FirebaseAuth.instance;

    var googleUser = await googleSignIn.signIn().then((value) {
      print("Google Sign In: $value");
      return value;
    }, onError: (_) {
      return null;
    });

    if (googleUser == null) return null;

    var email = googleUser.email;
    var password = email;

    return firebaseAuth.signInWithEmailAndPassword(email: email, password: email).then((cred) {
      print("Firebase Sign In: ${cred.user}");
      return cred.user;
    }, onError: (Object error) {
      print("Firebase Sign In Error");
      if (error is PlatformException) {
        if (error.code == "user-not-found") {
          return registerNewUser(email, password).then((firebaseUser) {
            return firebaseUser;
          });
        }
      }
      return null;
    });
  }

  Future<User> signInAnonymously() async {
    var firebaseAuth = FirebaseAuth.instance;

    return firebaseAuth.signInAnonymously().then((cred) {
      print("Firebase Sign In: ${cred.user}");
      var name = getRandomName();
      FirebaseFirestore.instance.collection(usersKey).doc(cred.user.uid).set({
        userNameKey : name
      }, SetOptions(merge: true));
      return cred.user;
    }, onError: (Object error) {
      return null;
    });
  }

  Future<User> signInPhoneNumber(String phoneNumber, AuthCredential authCredential) async {
    var firebaseAuth = FirebaseAuth.instance;

    var email = phoneNumber;
    var password = phoneNumber;

    return firebaseAuth.signInWithCredential(authCredential).then((cred) {
      return cred.user;
    }, onError: (Object error) {
      if (error is PlatformException) {
        if (error.code == "user-not-found") {
          return registerNewUser(email, password).then((firebaseUser) {
            return firebaseUser;
          });
        } else {
          return null;
        }
      }
      return null;
    });
  }

  Future changeName(String name) {
    this.currentUser.updateProfile(displayName: name);
    this.currentUser.reload();
    return FirebaseFirestore.instance.collection(usersKey).doc(this.currentUser.uid).set({userNameKey: name});
  }

  static String getRandomName(){
    List<String> adjs = [
      '开心',
      '忧郁',
      '犹豫',
      '盲目',
      '失望',
      '伤心',
      '慌张',
      '紧张',
      '迷茫',
      '狂妄',
      '骄傲',
      '愚蠢',
      '怠慢',
      '固执',
      '自私',
      '惆怅',
      '高傲',
      '勇敢',
      '胆小',
      '优秀',
      '心机',
      '抑郁',
      '慌张'
    ];

    List<String> nouns = [
      '狼人',
      '女巫',
      '预言家',
      '白狼王',
      '狼美人',
      '猎人',
      '混子',
      '白痴',
      '守卫',
      '村民',
      '黑商',
      '禁票长老',
      '通灵师',
      '摄梦人'
    ];

    var randomNum = Random(DateTime.now().microsecond).nextInt(adjs.length);
    var left = adjs.elementAt(randomNum);

    randomNum = Random(DateTime.now().microsecond).nextInt(nouns.length);
    var right = nouns.elementAt(randomNum);

    return left + '的' + right;
  }
}
