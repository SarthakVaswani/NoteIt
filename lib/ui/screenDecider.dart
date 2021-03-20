import 'package:flutter/material.dart';
import 'package:notes_app/ui/mobile/homePage.dart';
import 'package:notes_app/ui/mobile/login_page.dart';
import 'package:notes_app/ui/web/loginWeb.dart';

import 'web/homeViewDesktop.dart';

class ScreenDecider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          return HomeViewDesktop();
        } else if (constraints.maxWidth > 800 && constraints.maxWidth < 1200) {
          return HomeViewDesktop();
        } else
          return HomeView();
      },
    );
  }
}

class AuthDecider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          return LoginWeb();
        } else if (constraints.maxWidth > 800 && constraints.maxWidth < 1200) {
          return LoginWeb();
        } else
          return Login();
      },
    );
  }
}
