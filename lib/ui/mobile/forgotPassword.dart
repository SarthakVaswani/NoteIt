import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/service/services.dart';
import 'package:notes_app/ui/mobile/login_page.dart';
import 'package:transition/transition.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool showSpinner1 = false;
  TextEditingController _emailField = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.onBackground,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Forgot Password",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 27),
                            )),
                      ),
                      SizedBox(
                        height: 13,
                      ),
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: Colors.white,
                        child: TextField(
                          style: TextStyle(color: Colors.black),
                          onEditingComplete: () => node.nextFocus(),
                          controller: _emailField,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor:     Theme.of(context).colorScheme.onSecondary,
                            focusColor: Colors.black,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            hintText: 'Email',
                            hintStyle: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor:Theme.of(context).colorScheme.primary,
                            backgroundColor:              Theme.of(context).colorScheme.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          // height: 20,

                          onPressed: () async {
                            if (checkValidation()) {
                              setState(() {
                                showSpinner1 = true;
                              });
                              bool shouldNavigate =
                                  await forgotPassword(_emailField.text);
                              if (shouldNavigate) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: Duration(seconds: 2),
                                    content: Text('Password reset link sent'),
                                  ),
                                );
                                Navigator.push(
                                    context,
                                    Transition(
                                        child: Login(),
                                        transitionEffect:
                                            TransitionEffect.FADE));
                              }
                            } else {
                              setState(() {});
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                            child: Text(
                              'Send Link',
                              style:
                                  TextStyle(fontSize: 30, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool checkValidation() {
    if (_emailField.text == null || _emailField.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: Text('Enter Email'),
        ),
      );
      return false;
    }
    return true;
  }
}


// 