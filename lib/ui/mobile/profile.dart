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
    Future<bool> _willPopCallback() async {
      // await showDialog or Show add banners or whatever
      // then
      return true; // return true if the route to be popped
    }

    return WillPopScope(
      onWillPop: () async => _willPopCallback(),
      child: SafeArea(
        child: Scaffold(
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
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back_ios_new_outlined,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Profile',
                        style: TextStyle(fontSize: 27, color: Colors.white),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.55,
                      ),
                      IconButton(
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
                    ],
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
                            color: Color(0xffddf0f7),
                            elevation: 3,
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.24,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  CircleAvatar(
                                    radius: 38,
                                    child: Text(
                                      ("${snapshot.data.docs[0].data()['fullname']}")
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
                                            .data()['fullname'],
                                        style: TextStyle(fontSize: 35),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Center(
                              child: Text('Notifications',
                                  style: TextStyle(
                                      fontSize: 30, color: Colors.white)),
                            ),
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
                                        child: Card(
                                          color: Color(0xffddf0f7),
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
                                                      .data()['sharedBy'],
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                    "Shared ${snapshot.data.docs[index].data()['title']} with you",
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
