import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase/firebase.dart' as firebase;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

import '../main.dart';

// Web
// Future<bool> login(String email, String password) async {
//   try {
//     if ((defaultTargetPlatform == TargetPlatform.iOS) ||
//         (defaultTargetPlatform == TargetPlatform.android)) {
//       await FirebaseAuth.instance
//           .signInWithEmailAndPassword(email: email, password: password);
//       return true;
//     } else if ((defaultTargetPlatform == TargetPlatform.windows)) {
//       await firebase.auth().signInWithEmailAndPassword(email, password);
//       return true;
//     }
//   } catch (e) {
//     print(e);
//     return false;
//   }
// }

Future<bool> login(String email, String password) async {
  try {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    return true;
  } catch (e) {
    print(e);
    return false;
  }
}

Future<bool> register(String email, String password, String fullName) async {
  try {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    var firebaseUser = await FirebaseAuth.instance.currentUser;
    String uid = FirebaseAuth.instance.currentUser.uid;
    String dateCreated = DateTime.now().toIso8601String();
    DocumentReference ref = FirebaseFirestore.instance
        .collection('Users')
        .doc(firebaseUser.email)
        .collection('UserDetails')
        .doc(dateCreated);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(ref);
      if (!snapshot.exists) {
        ref.set({
          'email': email,
          'password': password,
          'fullname': fullName,
          'userId': uid,
          'tokenId': tokenId
        });
        print(ref.id);

        return true;
      }
      return true;
    });
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

Future<bool> forgotPassword(String email) async {
  FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  return true;
}

Future userSearch(String keyword) async {
  return FirebaseFirestore.instance
      .collection("Users")
      .doc(keyword)
      .collection("UserDetails")
      .where("email", isGreaterThanOrEqualTo: keyword)
      .get();
}

Future userNotes({String currentUser, String keyword}) async {
  return FirebaseFirestore.instance
      .collection("Users")
      .doc(currentUser)
      .collection("Notes")
      .where("title", isGreaterThanOrEqualTo: keyword)
      .get();
}

Future checkPinned({String currentUser, String keyword}) async {
  return FirebaseFirestore.instance
      .collection("Users")
      .doc(currentUser)
      .collection("Notes")
      .where("Pin", isGreaterThanOrEqualTo: "true")
      .snapshots();
}

Future<Response> sendNotification(
    {String tokenIdi, String userName, String fullName}) async {
  return await post(
    Uri.parse('https://onesignal.com/api/v1/notifications'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      "app_id":
          kAppId, //kAppId is the App Id that one get from the OneSignal When the application is registered.

      "include_player_ids": [
        tokenIdi
      ], //tokenIdList Is the List of All the Token Id to to Whom notification must be sent.

      // android_accent_color reprsent the color of the heading text in the notifiction
      "android_accent_color": "FF9976D2",
      "isAnyWeb": true,

      "small_icon":
          "https://user-images.githubusercontent.com/55880923/111069791-b516f780-84f4-11eb-8af6-bdb33bdded0a.png",

      "large_icon":
          "https://user-images.githubusercontent.com/55880923/111069791-b516f780-84f4-11eb-8af6-bdb33bdded0a.png",

      "headings": {"en": userName},

      "contents": {"en": "$fullName, shared Notes with you"},
    }),
  );
}

Future checkNote({String currentUser, String keyword}) async {
  return FirebaseFirestore.instance
      .collection("Users")
      .doc(currentUser)
      .collection("Notes")
      .where("noteId", isGreaterThanOrEqualTo: keyword)
      .get();
}
