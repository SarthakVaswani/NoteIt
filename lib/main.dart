import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/ui/register_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: Register(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final FirebaseAuth auth = FirebaseAuth.instance;
  // User currentUser;
  // @override
  // void initState() {
  //   User currentUser = FirebaseAuth.instance.currentUser;
  //   if (currentUser != null) {
  //     Navigator.push(
  //         context, MaterialPageRoute(builder: (context) => HomeView()));
  //   } else {
  //     Navigator.push(
  //         context, MaterialPageRoute(builder: (context) => Register()));
  //   }
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
