import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/ui/mobile/profile.dart';
import 'package:notes_app/ui/widgets/sidebar.dart';
import 'package:transition/transition.dart';
import '../noteview/addNote.dart';
import '../noteview/edtNote.dart';

class HomeViewDesktop extends StatefulWidget {
  @override
  _HomeViewDesktopState createState() => _HomeViewDesktopState();
}

class _HomeViewDesktopState extends State<HomeViewDesktop> {
  bool changeView = true;
  var firebaseUser = FirebaseAuth.instance.currentUser;
  final _scrollController = ScrollController();
  void getUserData() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection("Users")
        .doc(firebaseUser.uid)
        .get()
        .then((value) {
      print(value.id);
    });
  }

  Future<bool> _exitApp(
      {BuildContext context,
      Function call1,
      Function call2,
      String text1,
      String text2}) {
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
          'Choose action',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(),
            onPressed: () => call1(),
            child: Text(
              text1,
              style: TextStyle(color: Colors.black, fontSize: 17),
            ),
          ),
          TextButton(
            // splashColor: Colors.blueGrey,
            onPressed: () => call2(),
            child: Text(
              text2,
              style: TextStyle(color: Colors.black, fontSize: 17),
            ),
          ),
        ],
      ),
    );
  }
  // Future<void> _onPointerDown(PointerDownEvent event) async {
  //   // Check if right mouse button clicked
  //   if (event.kind == PointerDeviceKind.mouse &&
  //       event.buttons == kSecondaryMouseButton) {
  //     final overlay =
  //         Overlay.of(context).context.findRenderObject() as RenderBox;
  //     final menuItem = await showMenu<int>(
  //         context: context,
  //         items: [
  //           PopupMenuItem(child: Text('Copy'), value: 1),
  //           PopupMenuItem(child: Text('Cut'), value: 2),
  //         ],
  //         position: RelativeRect.fromSize(
  //             event.position & Size(48.0, 48.0), overlay.size));
  //     // Check if menu item clicked
  //     switch (menuItem) {
  //       case 1:
  //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //           content: Text('Copy clicket'),
  //           behavior: SnackBarBehavior.floating,
  //         ));
  //         break;
  //       case 2:
  //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //             content: Text('Cut clicked'),
  //             behavior: SnackBarBehavior.floating));
  //         break;
  //       default:
  //     }
  //   }
  // }

  void getUserNotes() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection("Users")
        .doc(firebaseUser.uid)
        .collection('Notes')
        .doc()
        .get()
        .then((value) {
      print(value.id);
    });
  }

  bool isPinned = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scrollbar(
        thickness: 10,
        showTrackOnHover: true,
        controller: _scrollController,
        isAlwaysShown: true,
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 27),
                    child: IconButton(
                        icon: Icon(Icons.account_circle),
                        onPressed: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Profile()));
                        }),
                  ),
                  // IconButton(
                  //     icon: Icon(Icons.web_asset),
                  //     onPressed: () {
                  //       _launchURL();
                  //     }),
                ],
                elevation: 0,
                automaticallyImplyLeading: false,
                backgroundColor: Color(0xff2c2b4b),
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.symmetric(horizontal: 15),
                  title: Text(
                    'Notes',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ];
          },
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Color(0xff2c2b4b),
            ),
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        Align(
                            alignment: Alignment.topRight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        changeView = !changeView;
                                      });
                                    },
                                    icon: changeView
                                        ? Icon(Icons.list, color: Colors.white)
                                        : Icon(Icons.grid_view,
                                            color: Colors.white)),
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isPinned = !isPinned;
                                      });
                                    },
                                    icon: isPinned
                                        ? CircleAvatar(
                                            child: Icon(Icons.bookmark,
                                                color: Colors.white),
                                          )
                                        : Icon(Icons.bookmark,
                                            color: Colors.white)),
                              ],
                            )),
                        isPinned
                            ? StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(
                                        FirebaseAuth.instance.currentUser.email)
                                    .collection('Notes')
                                    .where("Pin",
                                        isGreaterThanOrEqualTo: "true")
                                    .snapshots(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<QuerySnapshot>
                                        snapshotPinned) {
                                  if (!snapshotPinned.hasData) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  return changeView
                                      ? GridView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 5),
                                          itemCount: snapshotPinned.hasData
                                              ? snapshotPinned.data.docs.length
                                              : 0,
                                          itemBuilder: (context, index) {
                                            return Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                splashColor: Colors.redAccent,
                                                onLongPress: () {
                                                  _exitApp(
                                                      text1: 'Unpin',
                                                      text2: 'delete',
                                                      context: context,
                                                      call1: () {
                                                        snapshotPinned
                                                            .data
                                                            .docs[index]
                                                            .reference
                                                            .update({
                                                          'Pin': "false"
                                                        });
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .hideCurrentSnackBar();
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(SnackBar(
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            1),
                                                                content: Text(
                                                                    'The note is unpinned')));
                                                        Navigator.pop(context);
                                                      },
                                                      call2: () {
                                                        snapshotPinned
                                                            .data
                                                            .docs[index]
                                                            .reference
                                                            .delete();
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .hideCurrentSnackBar();
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(SnackBar(
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            1),
                                                                content: Text(
                                                                    'Deleted')));
                                                        Navigator.pop(context);
                                                      });
                                                },
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      Transition(
                                                          child: EditNote(
                                                              docToEdit:
                                                                  snapshotPinned
                                                                          .data
                                                                          .docs[
                                                                      index]),
                                                          transitionEffect:
                                                              TransitionEffect
                                                                  .FADE)
                                                      // MaterialPageRoute(
                                                      //   builder: (context) => EditNote(
                                                      //     docToEdit: snapshot.data.docs[index],
                                                      //   ),
                                                      // ),
                                                      );
                                                  ScaffoldMessenger.of(context)
                                                      .hideCurrentSnackBar();
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10),
                                                  child: Card(
                                                    elevation: 3,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            // side: BorderSide(
                                                            //     color: Colors.white, width: 0.01),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                    margin: EdgeInsets.all(10),
                                                    color: Color(0xffddf0f7),
                                                    child: Column(
                                                      children: [
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        15,
                                                                    vertical:
                                                                        10),
                                                            child: Text(
                                                              snapshotPinned
                                                                      .data
                                                                      .docs[index]
                                                                      .get(
                                                                  "title"),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 25),
                                                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 16,
                                                            ),
                                                            child: Container(
                                                              child: Text(
                                                                snapshotPinned
                                                                        .data
                                                                        .docs[index]
                                                                        .get(
                                                                    "content"),
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.5),
                                                                    fontSize:
                                                                        19),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                softWrap: true,
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
                                          },
                                        )
                                      : ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: snapshotPinned.hasData
                                              ? snapshotPinned.data.docs.length
                                              : 0,
                                          itemBuilder: (context, index) {
                                            return Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                splashColor: Colors.redAccent,
                                                onLongPress: () {
                                                  _exitApp(
                                                      text1: 'Unpin',
                                                      text2: 'delete',
                                                      context: context,
                                                      call1: () {
                                                        snapshotPinned
                                                            .data
                                                            .docs[index]
                                                            .reference
                                                            .update({
                                                          'Pin': "false"
                                                        });
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .hideCurrentSnackBar();
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(SnackBar(
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            1),
                                                                content: Text(
                                                                    'The note is unpinned')));
                                                        Navigator.pop(context);
                                                      },
                                                      call2: () {
                                                        snapshotPinned
                                                            .data
                                                            .docs[index]
                                                            .reference
                                                            .delete();
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .hideCurrentSnackBar();
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(SnackBar(
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            1),
                                                                content: Text(
                                                                    'Deleted')));
                                                      });
                                                },
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      Transition(
                                                          child: EditNote(
                                                              docToEdit:
                                                                  snapshotPinned
                                                                          .data
                                                                          .docs[
                                                                      index]),
                                                          transitionEffect:
                                                              TransitionEffect
                                                                  .FADE)
                                                      // MaterialPageRoute(
                                                      //   builder: (context) => EditNote(
                                                      //     docToEdit: snapshot.data.docs[index],
                                                      //   ),
                                                      // ),
                                                      );
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  child: Card(
                                                    elevation: 3,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            // side: BorderSide(
                                                            //     color: Colors.white, width: 0.01),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                    margin: EdgeInsets.all(10),
                                                    color: Color(0xffddf0f7),
                                                    child: Column(
                                                      children: [
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        15,
                                                                    vertical:
                                                                        10),
                                                            child: Text(
                                                              snapshotPinned
                                                                      .data
                                                                      .docs[index]
                                                                      .get(
                                                                  "title"),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 23),
                                                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 16,
                                                            ),
                                                            child: Container(
                                                              child: Text(
                                                                snapshotPinned
                                                                        .data
                                                                        .docs[index]
                                                                        .get(
                                                                    "content"),
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.5),
                                                                    fontSize:
                                                                        19),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                softWrap: true,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                },
                              )
                            : StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(
                                        FirebaseAuth.instance.currentUser.email)
                                    .collection('Notes')
                                    .orderBy('dateTime', descending: true)
                                    .snapshots(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (!snapshot.hasData) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  return changeView
                                      ? GridView.builder(
                                          physics: ScrollPhysics(),
                                          shrinkWrap: true,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 5),
                                          itemCount: snapshot.hasData
                                              ? snapshot.data.docs.length
                                              : 0,
                                          itemBuilder: (context, index) {
                                            return Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                splashColor: Colors.redAccent,
                                                onLongPress: () {
                                                  _exitApp(
                                                      text1: 'Pin',
                                                      text2: 'delete',
                                                      context: context,
                                                      call1: () {
                                                        snapshot
                                                            .data
                                                            .docs[index]
                                                            .reference
                                                            .update({
                                                          'Pin': "true"
                                                        });
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .hideCurrentSnackBar();
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(SnackBar(
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            1),
                                                                content: Text(
                                                                    'The note is pinned')));
                                                        Navigator.pop(context);
                                                      },
                                                      call2: () {
                                                        snapshot
                                                            .data
                                                            .docs[index]
                                                            .reference
                                                            .delete();
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .hideCurrentSnackBar();
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(SnackBar(
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            1),
                                                                content: Text(
                                                                    'Deleted')));
                                                      });
                                                },
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      Transition(
                                                          child: EditNote(
                                                              docToEdit:
                                                                  snapshot.data
                                                                          .docs[
                                                                      index]),
                                                          transitionEffect:
                                                              TransitionEffect
                                                                  .FADE)
                                                      // MaterialPageRoute(
                                                      //   builder: (context) => EditNote(
                                                      //     docToEdit: snapshot.data.docs[index],
                                                      //   ),
                                                      // ),
                                                      );
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10),
                                                  child: Card(
                                                    elevation: 3,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            // side: BorderSide(
                                                            //     color: Colors.white, width: 0.01),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                    margin: EdgeInsets.all(10),
                                                    color: Color(0xffddf0f7),
                                                    child: Column(
                                                      children: [
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        15,
                                                                    vertical:
                                                                        10),
                                                            child: Text(
                                                              snapshot.data
                                                                      .docs[index]
                                                                      .get(
                                                                  "title"),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 25),
                                                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 16,
                                                            ),
                                                            child: Container(
                                                              child: Text(
                                                                snapshot.data
                                                                        .docs[index]
                                                                        .get(
                                                                    "content"),
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.5),
                                                                    fontSize:
                                                                        19),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                softWrap: true,
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
                                          },
                                        )
                                      : ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: snapshot.hasData
                                              ? snapshot.data.docs.length
                                              : 0,
                                          itemBuilder: (context, index) {
                                            return Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                splashColor: Colors.redAccent,
                                                onLongPress: () {
                                                  _exitApp(
                                                      text1: 'Pin',
                                                      text2: 'delete',
                                                      context: context,
                                                      call1: () {
                                                        snapshot
                                                            .data
                                                            .docs[index]
                                                            .reference
                                                            .update({
                                                          'Pin': "true"
                                                        });
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .hideCurrentSnackBar();
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(SnackBar(
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            1),
                                                                content: Text(
                                                                    'The note is pinned')));
                                                        Navigator.pop(context);
                                                      },
                                                      call2: () {
                                                        snapshot
                                                            .data
                                                            .docs[index]
                                                            .reference
                                                            .delete();
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .hideCurrentSnackBar();
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(SnackBar(
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            1),
                                                                content: Text(
                                                                    'Deleted')));
                                                      });
                                                },
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      Transition(
                                                          child: EditNote(
                                                              docToEdit:
                                                                  snapshot.data
                                                                          .docs[
                                                                      index]),
                                                          transitionEffect:
                                                              TransitionEffect
                                                                  .FADE)
                                                      // MaterialPageRoute(
                                                      //   builder: (context) => EditNote(
                                                      //     docToEdit: snapshot.data.docs[index],
                                                      //   ),
                                                      // ),
                                                      );
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  child: Card(
                                                    elevation: 3,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            // side: BorderSide(
                                                            //     color: Colors.white, width: 0.01),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                    margin: EdgeInsets.all(10),
                                                    color: Color(0xffddf0f7),
                                                    child: Column(
                                                      children: [
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        15,
                                                                    vertical:
                                                                        10),
                                                            child: Text(
                                                              snapshot.data
                                                                      .docs[index]
                                                                      .get(
                                                                  "title"),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 23),
                                                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 16,
                                                            ),
                                                            child: Container(
                                                              child: Text(
                                                                snapshot.data
                                                                        .docs[index]
                                                                        .get(
                                                                    "content"),
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.5),
                                                                    fontSize:
                                                                        19),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                softWrap: true,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                },
                              ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  SideLayout(),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xffeb6765),
        onPressed: () {
          Navigator.push(
            context,
            Transition(
                child: AddNote(), transitionEffect: TransitionEffect.FADE),
          );
        },
        child: Icon(
          Icons.edit,
          color: Colors.white,
        ),
      ),
    );
  }
}
