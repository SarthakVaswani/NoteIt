import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/service/services.dart';
import 'package:transition/transition.dart';
import '../noteview/edtNote.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var firebaseUser;

  TextEditingController search = TextEditingController();
  QuerySnapshot snapshot;
  bool isExecuted = false;

  String selectedUser;
  bool changeView = false;
  getUser() async {
    firebaseUser = await FirebaseAuth.instance.currentUser;
  }

  @override
  void initState() {
    getUser();
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


    return SafeArea(
      child: WillPopScope(
        onWillPop: () async =>  _exitApp(context),
        child: Scaffold(
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color:Theme.of(context).colorScheme.background
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        'Search',
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 40,
                          width: 320,
                          child: PhysicalModel(
                            borderRadius: BorderRadius.circular(25),
                            color: Theme.of(context).colorScheme.primary,
                            elevation: 7.0,
                            shadowColor:Theme.of(context).colorScheme.secondary,
                            child: TextField(
                              onSubmitted: (value) async {
                                await userNotes(
                                        currentUser: firebaseUser.email,
                                        keyword: search.text)
                                    .then((value) => snapshot = value);
                                setState(() {
                                  print(snapshot.docs);
                                });
                              },
                              autofocus: false,
                              controller: search,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(45)),
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(45)),
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
                                  ),
                                  filled: true,
                                  hintStyle: TextStyle(color: Colors.black),
                                  hintText: "Search your notes",
                                  fillColor: Theme.of(context).colorScheme.surfaceVariant),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  snapshot != null
                      ? ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.docs.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    Transition(
                                        child: EditNote(
                                            docToEdit: snapshot.docs[index]),
                                        transitionEffect:
                                            TransitionEffect.FADE));
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                      // side: BorderSide(
                                      //     color: Colors.white, width: 0.01),
                                      borderRadius: BorderRadius.circular(10)),
                                  margin: EdgeInsets.all(10),
                                  color: Color(
                                      snapshot.docs[index].get("noteColor")),
                                  child: Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 10),
                                          child: Text(
                                            snapshot.docs[index]
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
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          child: Container(
                                            child: Text(
                                              snapshot.docs[index]
                                                  .get("content"),
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                  fontSize: 19),
                                              overflow: TextOverflow.ellipsis,
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
                        )
                      : Center(
                          child: Text(
                            'Search your notes',
                            style: TextStyle(color: Colors.white, fontSize: 17),
                          ),
                        )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
