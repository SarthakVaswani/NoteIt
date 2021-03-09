import 'package:flutter/material.dart';
import 'package:notes_app/service/auth.dart';
import 'package:notes_app/ui/homePage.dart';
import 'package:notes_app/ui/register_page.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _emailField = TextEditingController();
  TextEditingController _passField = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(color: Colors.amber),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: TextField(
                  controller: _emailField,
                  decoration: InputDecoration(
                    hintText: 'Add Email',
                    labelText: 'Email',
                  ),
                ),
              ),
              Container(
                child: TextFormField(
                  obscureText: true,
                  controller: _passField,
                  decoration: InputDecoration(
                    hintText: 'Add Password',
                    labelText: 'Password',
                  ),
                ),
              ),
              Container(
                child: MaterialButton(
                  onPressed: () async {
                    bool shouldNavigate =
                        await login(_emailField.text, _passField.text);
                    if (shouldNavigate) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => HomeView()));
                    } else {
                      return ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(
                              action: SnackBarAction(
                                label: "Enter Again",
                                onPressed: () {
                                  _emailField.clear();
                                  _passField.clear();
                                },
                              ),
                              content: Text('Enter Valid Login Info')));
                    }
                  },
                  child: Text('Login'),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                child: MaterialButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Register()));
                  },
                  child: Text('Register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
