import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/service/auth.dart';
import 'package:notes_app/ui/homePage.dart';
import 'package:notes_app/ui/login_page.dart';
import 'package:transition/transition.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool showSpinner = false;
  //  User currentUser;final FirebaseAuth auth = FirebaseAuth.instance;
  // @override
  // void initState() {
  //   User currentUser = FirebaseAuth.instance.currentUser;
  //   if (currentUser != null) {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       Navigator.push(
  //           context, MaterialPageRoute(builder: (context) => HomeView()));
  //     });
  //   }
  //   super.initState();
  // }

  TextEditingController _emailField = TextEditingController();
  TextEditingController _passField = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color(0xff283793),
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: TypewriterAnimatedTextKit(
                    repeatForever: true,
                    text: ['Note IT'],
                    speed: Duration(milliseconds: 200),
                    textStyle: TextStyle(fontSize: 50, color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Column(
                      children: [
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          color: Colors.white,
                          child: TextField(
                            controller: _emailField,
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              focusColor: Colors.white,
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.white)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.white)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.white)),
                              hintText: 'Add Email',
                              hintStyle: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          color: Colors.white,
                          child: TextField(
                            obscureText: true,
                            controller: _passField,
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              focusColor: Colors.white,
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.white)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.white)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.white)),
                              hintText: 'Add Password',
                              hintStyle: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: FlatButton(
                            height: 20,
                            color: Color(0xffeb6765),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            onPressed: () async {
                              setState(() {
                                showSpinner = true;
                              });
                              bool shouldNavigate = await register(
                                  _emailField.text, _passField.text);
                              if (shouldNavigate) {
                                Navigator.push(
                                  context,
                                  Transition(
                                      child: HomeView(),
                                      transitionEffect: TransitionEffect.FADE),
                                );
                              } else {
                                setState(() {
                                  showSpinner = false;
                                });
                                return ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    action: SnackBarAction(
                                      label: "Enter Again",
                                      onPressed: () {
                                        _emailField.clear();
                                        _passField.clear();
                                      },
                                    ),
                                    content: Text('Enter Valid Login Info'),
                                  ),
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 7),
                              child: Text(
                                'Register',
                                style: TextStyle(
                                    fontSize: 30, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      child: Text(
                        'Already Registered? Lets Login ',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    SizedBox(
                      width: 70,
                    ),
                    FlatButton(
                      height: 20,
                      color: Color(0xffeb6765),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          Transition(
                              child: Login(),
                              transitionEffect: TransitionEffect.FADE),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 7),
                        child: Text(
                          'Login',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
