import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:notes_app/service/services.dart';
import 'package:notes_app/ui/screenDecider.dart';
import 'package:notes_app/ui/web/loginWeb.dart';
import 'package:transition/transition.dart';

class RegisterWeb extends StatefulWidget {
  @override
  _RegisterWebState createState() => _RegisterWebState();
}

class _RegisterWebState extends State<RegisterWeb> {
  bool _showPassword = false;
  void _togglevisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  bool showSpinner = false;

  TextEditingController _emailField = TextEditingController();
  TextEditingController _passField = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
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
                  padding: const EdgeInsets.only(top: 60),
                  child: TypewriterAnimatedTextKit(
                    repeatForever: true,
                    text: ['Note IT'],
                    speed: Duration(milliseconds: 200),
                    textStyle: TextStyle(fontSize: 50, color: Colors.white),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 2,
                  child: Padding(
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
                              onEditingComplete: () => node.nextFocus(),
                              controller: _emailField,
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                focusColor: Colors.white,
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide:
                                        BorderSide(color: Colors.white)),
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
                                  showSpinner = true;
                                });
                                bool shouldNavigate = await register(
                                    _emailField.text, _passField.text);
                                if (shouldNavigate) {
                                  Navigator.push(
                                    context,
                                    Transition(
                                        child: ScreenDecider(),
                                        transitionEffect:
                                            TransitionEffect.FADE),
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
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                                fillColor: Colors.white,
                                focusColor: Colors.white,
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide:
                                        BorderSide(color: Colors.white)),
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
                                        child: ScreenDecider(),
                                        transitionEffect:
                                            TransitionEffect.FADE),
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
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.21),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                              child: LoginWeb(),
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
