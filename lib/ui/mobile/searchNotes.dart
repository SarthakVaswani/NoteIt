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
    Future<bool> _willPopCallback() async {
      // await showDialog or Show add banners or whatever
      // then
      return true; // return true if the route to be popped
    }

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async => _willPopCallback(),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
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
                        Container(
                          height: 40,
                          width: 300,
                          child: TextField(
                            autofocus: true,
                            controller: search,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(40)),
                                ),
                                filled: true,
                                hintStyle: TextStyle(color: Colors.grey[800]),
                                hintText: "Search your notes",
                                fillColor: Colors.white70),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        CircleAvatar(
                          child: IconButton(
                            onPressed: () async {
                              await userNotes(
                                      currentUser: firebaseUser.email,
                                      keyword: search.text)
                                  .then((value) => snapshot = value);
                              setState(() {
                                print(snapshot.docs);
                              });
                            },
                            icon: Icon(Icons.search),
                          ),
                        )
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
                                  color: Color(0xffddf0f7),
                                  child: Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 10),
                                          child: Text(
                                            snapshot.docs[index]
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
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          child: Container(
                                            child: Text(
                                              snapshot.docs[index]
                                                  .data()["content"],
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
