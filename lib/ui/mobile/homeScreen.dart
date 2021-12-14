import 'package:flutter/material.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:notes_app/ui/mobile/homePage.dart';
import 'package:notes_app/ui/mobile/profile.dart';
import 'package:notes_app/ui/mobile/protectedNotes.dart';
import 'package:notes_app/ui/mobile/searchNotes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  PageController _pageController;
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: <Widget>[
            HomeView(),
            SearchPage(),
            ProtectedNotes(),
            Profile(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavyBar(
        curve: Curves.easeIn,
        showElevation: true,
        backgroundColor: Colors.black,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
          _pageController.jumpToPage(index);
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
              title: Text('Home'),
              icon: Icon(Icons.home),
              activeColor: Colors.white),
          BottomNavyBarItem(
              title: Text('Search'),
              icon: Icon(Icons.search_rounded),
              activeColor: Colors.white),
          BottomNavyBarItem(
              title: Text('Protected'),
              icon: Icon(Icons.lock),
              activeColor: Colors.white),
          BottomNavyBarItem(
              title: Text('Profile'),
              icon: Icon(Icons.account_circle),
              activeColor: Colors.white),
        ],
      ),
    );
  }
}
