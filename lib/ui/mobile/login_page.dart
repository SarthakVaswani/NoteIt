import 'dart:io';
import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/service/services.dart';
import 'package:notes_app/ui/mobile/register_page.dart';
import 'package:notes_app/ui/screenDecider.dart';
import 'package:transition/transition.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'forgotPassword.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _showPassword = true;
  void _togglevisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  Future<bool> _exitApp(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        elevation: 2,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            // side: BorderSide(
            //     color: Colors.white, width: 0.01),
            borderRadius: BorderRadius.circular(10)),
        title: Text(
          'Are you sure want to Exit ?',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        actions: [
          FlatButton(
            splashColor: Colors.blueGrey,
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'No',
              style: TextStyle(color: Colors.black, fontSize: 17),
            ),
          ),
          FlatButton(
            splashColor: Colors.blueGrey,
            onPressed: () => exit(0),
            child: Text(
              'Yes',
              style: TextStyle(color: Colors.black, fontSize: 17),
            ),
          ),
        ],
      ),
    );
  }

  bool showSpinner1 = false;
  TextEditingController _emailField = TextEditingController();
  TextEditingController _passField = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    return WillPopScope(
      onWillPop: () async => _exitApp(context),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: ModalProgressHUD(
          inAsyncCall: showSpinner1,
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 60),
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
                            borderRadius: BorderRadius.circular(20),
                          ),
                          color: Colors.white,
                          child: TextField(
                            style: TextStyle(color: Colors.white),
                            keyboardType: TextInputType.emailAddress,
                            onEditingComplete: () => node.nextFocus(),
                            controller: _emailField,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xff3a3a3c),
                              focusColor: Colors.white,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              hintText: 'Add Email',
                              hintStyle: TextStyle(color: Colors.white),
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
                            onSubmitted: (value) async {
                              setState(() {
                                showSpinner1 = true;
                              });
                              bool shouldNavigate = await login(
                                  _emailField.text, _passField.text);
                              if (shouldNavigate) {
                                Navigator.push(
                                    context,
                                    Transition(
                                        child: ScreenDecider(),
                                        transitionEffect:
                                            TransitionEffect.FADE));
                              } else {
                                setState(() {
                                  showSpinner1 = false;
                                });
                                return ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  action: SnackBarAction(
                                    label: "Enter Again",
                                    onPressed: () {
                                      _emailField.clear();
                                      _passField.clear();
                                    },
                                  ),
                                  content: Text('Enter Valid Login Info'),
                                ));
                              }
                            },
                            style: TextStyle(color: Colors.white),
                            obscureText: _showPassword,
                            controller: _passField,
                            decoration: InputDecoration(
                              suffixIcon: InkWell(
                                onTap: () {
                                  _togglevisibility();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Icon(
                                    _showPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Color(0xff5e5ce6),
                                  ),
                                ),
                              ),
                              filled: true,
                              fillColor: Color(0xff3a3a3c),
                              focusColor: Colors.white,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              hintText: 'Add Password',
                              hintStyle: TextStyle(color: Colors.white),
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
                            color: Color(0xff5e5ce5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onPressed: () async {
                              setState(() {
                                showSpinner1 = true;
                              });
                              bool shouldNavigate = await login(
                                  _emailField.text, _passField.text);
                              if (shouldNavigate) {
                                Navigator.push(
                                    context,
                                    Transition(
                                        child: ScreenDecider(),
                                        transitionEffect:
                                            TransitionEffect.FADE));
                              } else {
                                setState(() {
                                  showSpinner1 = false;
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
                                'Login',
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.21),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      child: Text(
                        'New here? Lets Register ',
                        style: TextStyle(color: Colors.white, fontSize: 17),
                      ),
                    ),
                    SizedBox(
                      width: 70,
                    ),
                    FlatButton(
                      height: 20,
                      color: Color(0xff5e5ce5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          Transition(
                              child: Register(),
                              transitionEffect: TransitionEffect.FADE),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 7),
                        child: Text(
                          'Register',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FlatButton(
                    height: 14,
                    color: Color(0xff5e5ce5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        Transition(
                            child: ForgotPassword(),
                            transitionEffect: TransitionEffect.FADE),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 7),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// 