import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/service/auth.dart';
import 'package:notes_app/ui/register_page.dart';
import 'addNote.dart';
import 'edtNote.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List colors = [Colors.red, Colors.green, Colors.yellow];
  Random random = new Random();

  int index = 0;

  void changeIndex() {
    setState(() => index = random.nextInt(3));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   actions: [
        //     TextButton(
        //       onPressed: () async {
        //         bool shouldNavigate = await logOut();
        //         if (shouldNavigate) {
        //           Navigator.push(context,
        //               MaterialPageRoute(builder: (context) => Register()));
        //         }
        //       },
        //       child: Text('LogOut'),
        //       style: TextButton.styleFrom(primary: Colors.white),
        //     ),
        //   ],
        // ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: Color(0xff171c26)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Text(
                        'Notes',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(FirebaseAuth.instance.currentUser.uid)
                      .collection('Notes')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2),
                      itemCount:
                          snapshot.hasData ? snapshot.data.docs.length : 0,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditNote(
                                  docToEdit: snapshot.data.docs[index],
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                // side: BorderSide(
                                //     color: Colors.white, width: 0.01),
                                borderRadius: BorderRadius.circular(10)),
                            margin: EdgeInsets.all(10),
                            color: Color(0xff272636),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 10),
                                    child: Text(
                                      snapshot.data.docs[index].data()["title"],
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 25),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      snapshot.data.docs[index]
                                          .data()["content"],
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 19),
                                    ),
                                  ),
                                ),
                              ],
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
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => AddNote()));
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
