import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/service/services.dart';

import '../screenDecider.dart';

class Profile extends StatefulWidget {
  const Profile({Key key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
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


    return WillPopScope(
      onWillPop: () async => _exitApp(context),
      child: SafeArea(
        child: Scaffold(
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color:  Theme.of(context).colorScheme.background,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.05,
                      ),
                      Text(
                        'Profile',
                        style: TextStyle(
                            fontSize: 27,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.62,
                      ),
                      CircleAvatar(
                        backgroundColor:  Theme.of(context).colorScheme.onTertiaryContainer,
                        child: IconButton(
                          icon: Icon(Icons.logout, color: Colors.white),
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
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('Users')
                          .doc(FirebaseAuth.instance.currentUser.email)
                          .collection('UserDetails')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return Column(children: [
                          Card(
                            shape: RoundedRectangleBorder(
                                // side: BorderSide(
                                //     color: Colors.white, width: 0.01),
                                borderRadius: BorderRadius.circular(10)),
                            margin: EdgeInsets.all(10),
                            color:  Theme.of(context).colorScheme.secondaryContainer,
                            elevation: 3,
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.24,
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  CircleAvatar(
                                    radius: 38,
                                    child: Text(
                                      ("${snapshot.data.docs[0].get('fullname')}")
                                          .substring(0, 1),
                                      style: TextStyle(fontSize: 38),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        snapshot.data.docs[0]
                                            .get('fullname'),
                                        style: TextStyle(fontSize: 35),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 17,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Center(
                              child: Text('Shared Notes',
                                  style: TextStyle(
                                      fontSize: 30, color: Colors.black)),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(FirebaseAuth.instance.currentUser.email)
                                  .collection('Notifications')
                                  .orderBy('dateTime', descending: true)
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                return ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.hasData
                                        ? snapshot.data.docs.length
                                        : 0,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.125,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        child: Card(
                                          color: Color(0xfff2f5f9),
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(
                                              // side: BorderSide(
                                              //     color: Colors.white, width: 0.01),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          margin: EdgeInsets.all(10),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(1.0),
                                                child: Text(
                                                  snapshot.data.docs[index]
                                                      .get('sharedBy'),
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                    "Shared ${snapshot.data.docs[index].get('title')} with you",
                                                    style: TextStyle(
                                                        fontSize: 18)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                              })
                        ]);
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
