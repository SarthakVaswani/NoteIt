import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/service/services.dart';
import 'package:notes_app/ui/mobile/searchNotes.dart';
import 'package:notes_app/ui/screenDecider.dart';
import 'package:notes_app/ui/web/widgets/sidebar.dart';
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

  Future<void> _onPointerDown(PointerDownEvent event) async {
    // Check if right mouse button clicked
    if (event.kind == PointerDeviceKind.mouse &&
        event.buttons == kSecondaryMouseButton) {
      final overlay =
          Overlay.of(context).context.findRenderObject() as RenderBox;
      final menuItem = await showMenu<int>(
          context: context,
          items: [
            PopupMenuItem(child: Text('Copy'), value: 1),
            PopupMenuItem(child: Text('Cut'), value: 2),
          ],
          position: RelativeRect.fromSize(
              event.position & Size(48.0, 48.0), overlay.size));
      // Check if menu item clicked
      switch (menuItem) {
        case 1:
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Copy clicket'),
            behavior: SnackBarBehavior.floating,
          ));
          break;
        case 2:
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Cut clicked'),
              behavior: SnackBarBehavior.floating));
          break;
        default:
      }
    }
  }

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
    // document.onContextMenu.listen((event) => event.preventDefault());
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
                      icon: Icon(
                        Icons.logout,
                        size: 40,
                      ),
                      onPressed: () async {
                        // getUserData();
                        Navigator.pop(context, true);
                        bool shouldNavigate = await logOut();
                        if (shouldNavigate) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AuthDecider()));
                        }
                      },
                    ),
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
                                Listener(
                                  onPointerDown: _onPointerDown,
                                  child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          changeView = !changeView;
                                        });
                                      },
                                      icon: changeView
                                          ? Icon(Icons.list,
                                              color: Colors.white)
                                          : Icon(Icons.grid_view,
                                              color: Colors.white)),
                                ),
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
                                                  crossAxisCount: 2),
                                          itemCount: snapshotPinned.hasData
                                              ? snapshotPinned.data.docs.length
                                              : 0,
                                          itemBuilder: (context, index) {
                                            return Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                splashColor: Colors.redAccent,
                                                onLongPress: () {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                          duration:
                                                              Duration(days: 1),
                                                          backgroundColor:
                                                              Color(0xff131616),
                                                          content: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.35,
                                                                child:
                                                                    MaterialButton(
                                                                  onPressed:
                                                                      () {
                                                                    snapshotPinned
                                                                        .data
                                                                        .docs[
                                                                            index]
                                                                        .reference
                                                                        .update({
                                                                      'Pin':
                                                                          "false"
                                                                    });

                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .hideCurrentSnackBar();
                                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                        duration: Duration(
                                                                            seconds:
                                                                                1),
                                                                        content:
                                                                            Text('The note is unpinned')));
                                                                  },
                                                                  child: Text(
                                                                    "Unpin",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            17),
                                                                  ),
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.8),
                                                                  minWidth: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.8,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              18.0),
                                                                      side: BorderSide(
                                                                          color:
                                                                              Colors.white)),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.35,
                                                                child:
                                                                    MaterialButton(
                                                                  onPressed:
                                                                      () {
                                                                    snapshotPinned
                                                                        .data
                                                                        .docs[
                                                                            index]
                                                                        .reference
                                                                        .delete();
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .hideCurrentSnackBar();
                                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                        duration: Duration(
                                                                            seconds:
                                                                                1),
                                                                        content:
                                                                            Text('Deleted')));
                                                                  },
                                                                  child: Text(
                                                                    "Delete",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            17),
                                                                  ),
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.8),
                                                                  minWidth: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.8,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              18.0),
                                                                      side: BorderSide(
                                                                          color:
                                                                              Colors.white)),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              CircleAvatar(
                                                                backgroundColor:
                                                                    Colors
                                                                        .blueAccent,
                                                                child:
                                                                    IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          ScaffoldMessenger.of(context)
                                                                              .hideCurrentSnackBar();
                                                                        },
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .close,
                                                                        )),
                                                              )
                                                            ],
                                                          )));
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
                                                                      .data()[
                                                                  "title"],
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
                                                                        .data()[
                                                                    "content"],
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
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                          duration:
                                                              Duration(days: 1),
                                                          backgroundColor:
                                                              Color(0xff131616),
                                                          content: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.35,
                                                                child:
                                                                    MaterialButton(
                                                                  onPressed:
                                                                      () {
                                                                    snapshotPinned
                                                                        .data
                                                                        .docs[
                                                                            index]
                                                                        .reference
                                                                        .update({
                                                                      'Pin':
                                                                          "false"
                                                                    });

                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .hideCurrentSnackBar();
                                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                        duration: Duration(
                                                                            seconds:
                                                                                1),
                                                                        content:
                                                                            Text('The note is unpinned')));
                                                                  },
                                                                  child: Text(
                                                                    "Unpin",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            17),
                                                                  ),
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.8),
                                                                  minWidth: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.8,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              18.0),
                                                                      side: BorderSide(
                                                                          color:
                                                                              Colors.white)),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.35,
                                                                child:
                                                                    MaterialButton(
                                                                  onPressed:
                                                                      () {
                                                                    snapshotPinned
                                                                        .data
                                                                        .docs[
                                                                            index]
                                                                        .reference
                                                                        .delete();
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .hideCurrentSnackBar();
                                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                        duration: Duration(
                                                                            seconds:
                                                                                1),
                                                                        content:
                                                                            Text('Deleted')));
                                                                  },
                                                                  child: Text(
                                                                    "Delete",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            17),
                                                                  ),
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.8),
                                                                  minWidth: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.8,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              18.0),
                                                                      side: BorderSide(
                                                                          color:
                                                                              Colors.white)),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              CircleAvatar(
                                                                backgroundColor:
                                                                    Colors
                                                                        .blueAccent,
                                                                child:
                                                                    IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          ScaffoldMessenger.of(context)
                                                                              .hideCurrentSnackBar();
                                                                        },
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .close,
                                                                        )),
                                                              )
                                                            ],
                                                          )));
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
                                                                      .data()[
                                                                  "title"],
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
                                                                        .data()[
                                                                    "content"],
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
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    Transition(
                                                        child: EditNote(
                                                            docToEdit: snapshot
                                                                .data
                                                                .docs[index]),
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: Card(
                                                  elevation: 3,
                                                  shape: RoundedRectangleBorder(
                                                      // side: BorderSide(
                                                      //     color: Colors.white, width: 0.01),
                                                      borderRadius:
                                                          BorderRadius.circular(
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
                                                                  vertical: 10),
                                                          child: Text(
                                                            snapshot.data
                                                                    .docs[index]
                                                                    .data()[
                                                                "title"],
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
                                                                      .data()[
                                                                  "content"],
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.5),
                                                                  fontSize: 19),
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
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    Transition(
                                                        child: EditNote(
                                                            docToEdit: snapshot
                                                                .data
                                                                .docs[index]),
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Card(
                                                  elevation: 3,
                                                  shape: RoundedRectangleBorder(
                                                      // side: BorderSide(
                                                      //     color: Colors.white, width: 0.01),
                                                      borderRadius:
                                                          BorderRadius.circular(
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
                                                                  vertical: 10),
                                                          child: Text(
                                                            snapshot.data
                                                                    .docs[index]
                                                                    .data()[
                                                                "title"],
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
                                                                      .data()[
                                                                  "content"],
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.5),
                                                                  fontSize: 19),
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
