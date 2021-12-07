import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase/firebase.dart' as firebase;
import 'package:flutter/foundation.dart';

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

Future<bool> register(String email, String password) async {
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
        ref.set({'email': email, 'password': password, 'userId': uid});
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
