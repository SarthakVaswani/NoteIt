import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/ui/widgets/toggleBar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../noteview/addNote.dart';
import 'package:transition/transition.dart';
import '../noteview/edtNote.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  var firebaseUser = FirebaseAuth.instance.currentUser;

  bool isPinned = false;
  bool changeView = true;
  bool confirmPin = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> _exitApp(BuildContext context) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          elevation: 2,
          // backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              // side: BorderSide(
              //     color: Colors.white, width: 0.01),
              borderRadius: BorderRadius.circular(10)),
          title: Text(
            'Are you sure want to Exit ?',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          actions: [
            TextButton(
              style: ButtonStyle(
                // overlayColor: MaterialStateProperty.all(Colors.blueGrey),
              ),
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'No',
                // style: TextStyle(color: Colors.black, fontSize: 17),
              ),
            ),
            TextButton(
              style: ButtonStyle(
                // overlayColor: MaterialStateProperty.all(Colors.blueGrey),
              ),
              onPressed: () => exit(0),
              child: Text(
                'Yes',
                // style: TextStyle(color: Colors.black, fontSize: 17),
              ),
            ),
          ],
        ),
      );
    }

    int _toggleValue = 0;
    const _url = 'https://noteit.live';
    void _launchURL() async => await canLaunch(_url)
        ? await launch(_url)
        : throw 'Could not launch $_url';
    return WillPopScope(
      onWillPop: () async => _exitApp(context),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Column(
            children: [
              Row(
                children: [
                  Text(
                    'NoteIt',
                    style: TextStyle(color: Colors.black, fontSize: 28),
                  )
                ],
              ),
            ],
          ),
          elevation: 0,
          // backgroundColor: Theme.of(context).colorScheme.onSecondary,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedToggle(
                      values: ['My Notes', 'Pinned'],
                      onToggleCallback: (value) {
                        setState(() {
                          isPinned = !isPinned;
                        });
                      },
                      buttonColor: Theme.of(context).colorScheme.tertiary,
                   backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      textColor: Color(0xFFFFFFFF),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Align(
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          changeView = !changeView;
                                        });
                                      },
                                      icon: changeView
                                          ? Icon(Icons.list,)
                                          : Icon(Icons.grid_view,
                                             )),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ],
                ),
                isPinned
                    ? StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('Users')
                            .doc(FirebaseAuth.instance.currentUser.email)
                            .collection('Notes')
                            .where(
                              "Pin",
                              isGreaterThanOrEqualTo: "true",
                            )
                            .where('lock', isEqualTo: false)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshotPinned) {
                          if (!snapshotPinned.hasData) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return changeView
                              ? GridView.builder(
                                  physics: NeverScrollableScrollPhysics(),
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
                                        splashColor: Theme.of(context).colorScheme.onTertiaryContainer,
                                        onLongPress: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  duration: Duration(days: 1),
                                                  // backgroundColor:
                                                  //     Color(0xff131616),
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
                                                        child: MaterialButton(
                                                          onPressed: () {
                                                            snapshotPinned
                                                                .data
                                                                .docs[index]
                                                                .reference
                                                                .update({
                                                              'Pin': "false"
                                                            });

                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .hideCurrentSnackBar();
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(SnackBar(
                                                                    duration: Duration(
                                                                        seconds:
                                                                            1),
                                                                    content: Text(
                                                                        'The note is unpinned')));
                                                          },
                                                          child: Text(
                                                            "Unpin",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 17),
                                                          ),
                                                            color: Theme.of(context).colorScheme.surface,
                                                          minWidth: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.8,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          18.0),
                                                              // side: BorderSide(
                                                              //     color: Colors
                                                              //         .white)),
                                                          )
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
                                                        child: MaterialButton(
                                                          onPressed: () {
                                                            snapshotPinned
                                                                .data
                                                                .docs[index]
                                                                .reference
                                                                .delete();
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .hideCurrentSnackBar();
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(SnackBar(
                                                                    duration: Duration(
                                                                        seconds:
                                                                            1),
                                                                    content: Text(
                                                                        'Deleted')));
                                                          },
                                                          child: Text(
                                                            "Delete",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 17),
                                                          ),
                                                          color: Theme.of(context).colorScheme.surface,
                                                          minWidth: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.8,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          18.0),
                                                              // side: BorderSide(
                                                              //     color: Colors
                                                              //         .white)
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      CircleAvatar(
                                                        backgroundColor:
                                                        Theme.of(context).colorScheme.tertiaryContainer,
                                                        child: IconButton(
                                                            onPressed: () {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .hideCurrentSnackBar();
                                                            },
                                                            icon: Icon(
                                                              Icons.close,
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
                                                      docToEdit: snapshotPinned
                                                          .data.docs[index]),
                                                  transitionEffect:
                                                      TransitionEffect.FADE)
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
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Card(
                                            elevation: 3,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            margin: EdgeInsets.all(10),
                                            color: Color(
                                              snapshotPinned.data.docs[index]
                                                  .get("noteColor"),
                                            ),
                                            child: Column(
                                              children: [
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15,
                                                        vertical: 10),
                                                    child: Text(
                                                      snapshotPinned
                                                          .data.docs[index]
                                                          .get("title"),
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 25),
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 16,
                                                    ),
                                                    child: Container(
                                                      child: Text(
                                                        snapshotPinned
                                                            .data.docs[index]
                                                            .get("content"),
                                                        style: TextStyle(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.5),
                                                            fontSize: 19),
                                                        overflow: TextOverflow
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
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: snapshotPinned.hasData
                                      ? snapshotPinned.data.docs.length
                                      : 0,
                                  itemBuilder: (context, index) {
                                    return Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        splashColor: Theme.of(context).colorScheme.onTertiaryContainer,
                                        onLongPress: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  duration: Duration(days: 1),
                                                  // backgroundColor:
                                                  //     Color(0xff131616),
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
                                                        child: MaterialButton(
                                                          onPressed: () {
                                                            snapshotPinned
                                                                .data
                                                                .docs[index]
                                                                .reference
                                                                .update({
                                                              'Pin': "false"
                                                            });

                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .hideCurrentSnackBar();
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(SnackBar(
                                                                    duration: Duration(
                                                                        seconds:
                                                                            1),
                                                                    content: Text(
                                                                        'The note is unpinned')));
                                                          },
                                                          child: Text(
                                                            "Unpin",
                                                            style: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: 17),
                                                          ),
                                                          color:Theme.of(context).colorScheme.surface,
                                                          minWidth: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.8,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          18.0),
                                                              // side: BorderSide(
                                                              //     color: Colors
                                                              //         .white)
                                                          ),
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
                                                        child: MaterialButton(
                                                          onPressed: () {
                                                            snapshotPinned
                                                                .data
                                                                .docs[index]
                                                                .reference
                                                                .delete();
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .hideCurrentSnackBar();
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(SnackBar(
                                                                    duration: Duration(
                                                                        seconds:
                                                                            1),
                                                                    content: Text(
                                                                        'Deleted')));
                                                          },
                                                          child: Text(
                                                            "Delete",
                                                            style: TextStyle( color: Colors.black,
                                                                fontSize: 17),
                                                          ),
                                                          color: Theme.of(context).colorScheme.surface,
                                                          minWidth: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.8,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          18.0),
                                                              // side: BorderSide(
                                                              //     color: Colors
                                                              //         .white)
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      CircleAvatar(
                                                        backgroundColor:
                                                        Theme.of(context).colorScheme.tertiaryContainer,

                                                        child: IconButton(
                                                            onPressed: () {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .hideCurrentSnackBar();
                                                            },
                                                            icon: Icon(
                                                              Icons.close,
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
                                                      docToEdit: snapshotPinned
                                                          .data.docs[index]),
                                                  transitionEffect:
                                                      TransitionEffect.FADE)
                                              // MaterialPageRoute(
                                              //   builder: (context) => EditNote(
                                              //     docToEdit: snapshot.data.docs[index],
                                              //   ),
                                              // ),
                                              );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Card(
                                            elevation: 3,
                                            shape: RoundedRectangleBorder(
                                                // side: BorderSide(
                                                //     color: Colors.white, width: 0.01),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            margin: EdgeInsets.all(10),
                                            color: Color(
                                              snapshotPinned.data.docs[index]
                                                  .get("noteColor"),
                                            ),
                                            child: Column(
                                              children: [
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15,
                                                        vertical: 10),
                                                    child: Text(
                                                      snapshotPinned
                                                          .data.docs[index]
                                                          .get("title"),
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 23),
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 16,
                                                    ),
                                                    child: Container(
                                                      child: Text(
                                                        snapshotPinned
                                                            .data.docs[index]
                                                            .get("content"),
                                                        style: TextStyle(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.5),
                                                            fontSize: 19),
                                                        overflow: TextOverflow
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
                            .doc(FirebaseAuth.instance.currentUser.email)
                            .collection('Notes')
                            .where('lock', isEqualTo: false)
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
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisSpacing: 0.09,
                                          crossAxisCount: 2),
                                  itemCount: snapshot.hasData
                                      ? snapshot.data.docs.length
                                      : 0,
                                  itemBuilder: (context, index) {
                                    return Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        splashColor: Theme.of(context).colorScheme.onTertiaryContainer,
                                        onLongPress: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  duration: Duration(days: 1),
                                                  // backgroundColor:
                                                  //     Color(0xff131616),
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
                                                        child: MaterialButton(
                                                          onPressed: () {
                                                            snapshot
                                                                .data
                                                                .docs[index]
                                                                .reference
                                                                .update({
                                                              'Pin': "true"
                                                            });

                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .hideCurrentSnackBar();
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(SnackBar(
                                                                    duration: Duration(
                                                                        seconds:
                                                                            1),
                                                                    content: Text(
                                                                        'The note is pinned')));
                                                          },
                                                          child: Text(
                                                            "Pin",
                                                            style: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: 17),
                                                          ),
                                                          color: Theme.of(context).colorScheme.surface,
                                                          minWidth: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.8,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          18.0),
                                                              // side: BorderSide(
                                                              //     color: Colors
                                                              //         .white)
                                                          ),
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
                                                        child: MaterialButton(
                                                          onPressed: () {
                                                            snapshot
                                                                .data
                                                                .docs[index]
                                                                .reference
                                                                .delete();
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .hideCurrentSnackBar();
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(SnackBar(
                                                                    duration: Duration(
                                                                        seconds:
                                                                            1),
                                                                    content: Text(
                                                                        'Deleted')));
                                                          },
                                                          child: Text(
                                                            "Delete",
                                                            style: TextStyle(
                                                                color:Colors.black,
                                                                fontSize: 17),
                                                          ),
                                                          color: Theme.of(context).colorScheme.surface,
                                                          minWidth: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.8,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          18.0),
                                                              // side: BorderSide(
                                                              //     color: Colors
                                                              //         .white)
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      CircleAvatar(
                                                        backgroundColor:
                                                        Theme.of(context).colorScheme.tertiaryContainer,

                                                        child: IconButton(
                                                            onPressed: () {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .hideCurrentSnackBar();
                                                            },
                                                            icon: Icon(
                                                              Icons.close,
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
                                                      docToEdit: snapshot
                                                          .data.docs[index]),
                                                  transitionEffect:
                                                      TransitionEffect.FADE));
                                          ScaffoldMessenger.of(context)
                                              .hideCurrentSnackBar();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Card(
                                            elevation: 3,
                                            shape: RoundedRectangleBorder(
                                                // side: BorderSide(
                                                //     color: Colors.white, width: 0.01),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            margin: EdgeInsets.all(10),
                                            color: Color(
                                              snapshot.data.docs[index]
                                                  .get("noteColor"),
                                            ),
                                            child: Column(
                                              children: [
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15,
                                                        vertical: 10),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 20),
                                                      child: Text(
                                                        snapshot
                                                            .data.docs[index]
                                                            .get("title"),
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 23),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 16,
                                                    ),
                                                    child: Container(
                                                      child: Text(
                                                        snapshot
                                                            .data.docs[index]
                                                            .get("content"),
                                                        style: TextStyle(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.5),
                                                            fontSize: 19),
                                                        overflow: TextOverflow
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
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: snapshot.hasData
                                      ? snapshot.data.docs.length
                                      : 0,
                                  itemBuilder: (context, index) {
                                    return Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        splashColor: Theme.of(context).colorScheme.onTertiaryContainer,
                                        onLongPress: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  duration: Duration(days: 1),
                                                  // backgroundColor:
                                                  //     Color(0xff131616),
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
                                                        child: MaterialButton(
                                                          onPressed: () {
                                                            snapshot
                                                                .data
                                                                .docs[index]
                                                                .reference
                                                                .update({
                                                              'Pin': "true"
                                                            });

                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .hideCurrentSnackBar();
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(SnackBar(
                                                                    duration: Duration(
                                                                        seconds:
                                                                            1),
                                                                    content: Text(
                                                                        'The note is pinned')));
                                                          },
                                                          child: Text(
                                                            "Pin",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 17),
                                                          ),
                                                          color: Theme.of(context).colorScheme.surface,
                                                          minWidth: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.8,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          18.0),
                                                              // side: BorderSide(
                                                              //     color: Colors
                                                              //         .white)
                                                          ),
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
                                                        child: MaterialButton(
                                                          onPressed: () {
                                                            snapshot
                                                                .data
                                                                .docs[index]
                                                                .reference
                                                                .delete();
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .hideCurrentSnackBar();
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(SnackBar(
                                                                    duration: Duration(
                                                                        seconds:
                                                                            1),
                                                                    content: Text(
                                                                        'Deleted')));
                                                          },
                                                          child: Text(
                                                            "Delete",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 17),
                                                          ),
                                                          color:Theme.of(context).colorScheme.surface,
                                                          minWidth: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.8,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          18.0),
                                                              // side: BorderSide(
                                                              //     color: Colors
                                                              //         .white)
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      CircleAvatar(
                                                        backgroundColor:
                                                        Theme.of(context).colorScheme.tertiaryContainer,

                                                        child: IconButton(
                                                            onPressed: () {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .hideCurrentSnackBar();
                                                            },
                                                            icon: Icon(
                                                              Icons.close,
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
                                                      docToEdit: snapshot
                                                          .data.docs[index]),
                                                  transitionEffect:
                                                      TransitionEffect.FADE)
                                              // MaterialPageRoute(
                                              //   builder: (context) => EditNote(
                                              //     docToEdit: snapshot.data.docs[index],
                                              //   ),
                                              // ),
                                              );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Card(
                                            elevation: 3,
                                            shape: RoundedRectangleBorder(
                                                // side: BorderSide(
                                                //     color: Colors.white, width: 0.01),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            margin: EdgeInsets.all(10),
                                            color: Color(
                                              snapshot.data.docs[index]
                                                  .get("noteColor"),
                                            ),
                                            child: Column(
                                              children: [
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15,
                                                        vertical: 10),
                                                    child: Text(
                                                      snapshot.data.docs[index]
                                                          .get("title"),
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 23),
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 16,
                                                    ),
                                                    child: Container(
                                                      child: Text(
                                                        snapshot
                                                            .data.docs[index]
                                                            .get("content"),
                                                        style: TextStyle(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.5),
                                                            fontSize: 19),
                                                        overflow: TextOverflow
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
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor:Theme.of(context).colorScheme.secondary,
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
      ),
    );
  }
}
