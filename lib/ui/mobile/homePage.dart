import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/service/services.dart';
import 'package:notes_app/ui/mobile/searchNotes.dart';
import 'package:notes_app/ui/mobile/searchUser.dart';
import 'package:notes_app/ui/screenDecider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../noteview/addNote.dart';
import 'package:transition/transition.dart';
import '../noteview/edtNote.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // var initializationSettingsAndroid =
  //     new AndroidInitializationSettings('noteit');
  var firebaseUser = FirebaseAuth.instance.currentUser;
  // @override
  // void initState() {
  //   super.initState();
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     RemoteNotification notification = message.notification;
  //     AndroidNotification android = message.notification?.android;
  //     if (notification != null && android != null) {
  //       flutterLocalNotificationsPlugin.show(
  //           notification.hashCode,
  //           notification.title,
  //           notification.body,
  //           NotificationDetails(
  //             android: AndroidNotificationDetails(
  //               channel.id,
  //               channel.name,
  //               // channel.description,
  //               color: Colors.blue,
  //               playSound: true,
  //               icon: '@drawable/noteit',
  //             ),
  //           ));
  //     }
  //   });

  //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //     print('A new onMessageOpenedApp event was published!');
  //     RemoteNotification notification = message.notification;
  //     AndroidNotification android = message.notification?.android;
  //     if (notification != null && android != null) {
  //       showDialog(
  //           context: context,
  //           builder: (_) {
  //             return AlertDialog(
  //               title: Text(notification.title),
  //               content: SingleChildScrollView(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [Text(notification.body)],
  //                 ),
  //               ),
  //             );
  //           });
  //     }
  //   });
  // }
  bool changeView = true;
  @override
  Widget build(BuildContext context) {
    Future<bool> _exitApp(BuildContext context) {
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
            'Are you sure want to Exit ?',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          actions: [
            FlatButton(
              splashColor: Colors.blueGrey,
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'No',
                style: TextStyle(color: Colors.black, fontSize: 17),
              ),
            ),
            FlatButton(
              splashColor: Colors.blueGrey,
              onPressed: () => exit(0),
              child: Text(
                'Yes',
                style: TextStyle(color: Colors.black, fontSize: 17),
              ),
            ),
          ],
        ),
      );
    }

    const _url = 'https://noteit.live';
    void _launchURL() async => await canLaunch(_url)
        ? await launch(_url)
        : throw 'Could not launch $_url';
    return WillPopScope(
      onWillPop: () async => _exitApp(context),
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                actions: [
                  IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: () async {
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
                  IconButton(
                      icon: Icon(Icons.web_asset),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchUsers()));
                      }),
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
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: MaterialButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SearchPage()));
                          },
                          child: Text(
                            "Search",
                            style: TextStyle(color: Colors.black, fontSize: 17),
                          ),
                          color: Colors.white.withOpacity(0.8),
                          minWidth: MediaQuery.of(context).size.width * 0.8,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.white)),
                        ),
                      ),
                      Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  changeView = !changeView;
                                });
                              },
                              icon: changeView
                                  ? Icon(Icons.list, color: Colors.white)
                                  : Icon(Icons.grid_view,
                                      color: Colors.white))),
                    ],
                  ),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Users')
                        .doc(FirebaseAuth.instance.currentUser.email)
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
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2),
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
                                                docToEdit:
                                                    snapshot.data.docs[index]),
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
                                        horizontal: 10),
                                    child: Card(
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                          // side: BorderSide(
                                          //     color: Colors.white, width: 0.01),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      margin: EdgeInsets.all(10),
                                      color: Color(0xffddf0f7),
                                      child: Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 10),
                                              child: Text(
                                                snapshot.data.docs[index]
                                                    .data()["title"],
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 25),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                              ),
                                              child: Container(
                                                child: Text(
                                                  snapshot.data.docs[index]
                                                      .data()["content"],
                                                  style: TextStyle(
                                                      color: Colors.black
                                                          .withOpacity(0.5),
                                                      fontSize: 19),
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                              physics: NeverScrollableScrollPhysics(),
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
                                                docToEdit:
                                                    snapshot.data.docs[index]),
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
                                      color: Color(0xffddf0f7),
                                      child: Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 10),
                                              child: Text(
                                                snapshot.data.docs[index]
                                                    .data()["title"],
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 23),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                              ),
                                              child: Container(
                                                child: Text(
                                                  snapshot.data.docs[index]
                                                      .data()["content"],
                                                  style: TextStyle(
                                                      color: Colors.black
                                                          .withOpacity(0.5),
                                                      fontSize: 19),
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
      ),
    );
  }
}