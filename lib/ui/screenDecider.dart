import 'package:flutter/material.dart';
import 'package:notes_app/ui/homePage.dart';

import 'homeViewDesktop.dart';

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
