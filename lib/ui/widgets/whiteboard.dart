import 'package:flutter/material.dart';
import 'package:whiteboardkit/whiteboardkit.dart';

class WhiteBoardPage extends StatefulWidget {
  const WhiteBoardPage({Key key}) : super(key: key);

  @override
  _WhiteBoardPageState createState() => _WhiteBoardPageState();
}

class _WhiteBoardPageState extends State<WhiteBoardPage> {
  DrawingController controller;
  @override
  void initState() {
    controller = new DrawingController();
    controller.onChange().listen((draw) {
      //do something with it
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Whiteboard(
                style: WhiteboardStyle(toolboxColor: Colors.amber),
                controller: controller,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
