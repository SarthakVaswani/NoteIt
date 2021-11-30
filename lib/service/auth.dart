import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase/firebase.dart' as firebase;
import 'package:flutter/foundation.dart';

//Web
Future<bool> login(String email, String password) async {
  try {
    if ((defaultTargetPlatform == TargetPlatform.iOS) ||
        (defaultTargetPlatform == TargetPlatform.android)) {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return true;
    } else if ((defaultTargetPlatform == TargetPlatform.windows)) {
      await firebase.auth().signInWithEmailAndPassword(email, password);
      return true;
    }
  } catch (e) {
    print(e);
    return false;
  }
}

// Future<bool> login(String email, String password) async {
//   try {
//     await FirebaseAuth.instance
//         .signInWithEmailAndPassword(email: email, password: password);
//     return true;
//   } catch (e) {
//     print(e);
//     return false;
//   }
// }

Future<bool> register(String email, String password) async {
  try {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    return true;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      print('password is weak');
    } else if (e.code == 'email-already-in-use') {
      print('Enter new email Id');
    }
    return false;
  } catch (e) {
    print(e.toString());
  }
  return false;
}

Future<bool> logOut() async {
  await FirebaseAuth.instance.signOut();
  return true;
}
