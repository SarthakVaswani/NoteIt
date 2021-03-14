import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/service/auth.dart';
import 'package:notes_app/ui/register_page.dart';
import 'package:notes_app/ui/screenDecider.dart';
import 'package:transition/transition.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
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
        backgroundColor: Color(0xff283793),
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
                            onEditingComplete: () => node.nextFocus(),
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                Row(
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
                      color: Color(0xffeb6765),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// 