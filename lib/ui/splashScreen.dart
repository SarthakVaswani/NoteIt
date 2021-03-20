import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/ui/mobile/homePage.dart';
import 'package:notes_app/ui/mobile/login_page.dart';
import 'package:notes_app/ui/screenDecider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User _user;
  Future<User> _getUser() async {
    _user = await _auth.currentUser;
    return _user;
  }

  Future startTime() async {
    _user = await _auth.currentUser;
    var _duration = Duration(seconds: 1500);
    return Timer(_duration, changeScreen());
  }

  changeScreen() {
    if (_user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeView()));
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AuthDecider()));
      });
    }
  }

  @override
  void initState() {
    _getUser();
    startTime();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xff2c2b4b),
        body: Center(
          child: Text(
            'Note IT',
            style: TextStyle(fontSize: 70, color: Colors.white),
          ),
          // child: TypewriterAnimatedTextKit(
          //   repeatForever: true,
          //   text: ['Note IT'],
          //   speed: Duration(seconds: 20),
          //   textStyle: TextStyle(fontSize: 50, color: Colors.white),
          // ),
        ));
  }
}
