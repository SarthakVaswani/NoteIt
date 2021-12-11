import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/service/services.dart';
import 'package:notes_app/ui/noteview/edtNote.dart';
import 'package:transition/transition.dart';

class SideLayout extends StatefulWidget {
  const SideLayout({Key key}) : super(key: key);

  @override
  State<SideLayout> createState() => _SideLayoutState();
}

class _SideLayoutState extends State<SideLayout> {
  var firebaseUser;
  TextEditingController search = TextEditingController();
  getUser() async {
    firebaseUser = await FirebaseAuth.instance.currentUser;
  }

  QuerySnapshot snapshot;
  bool isExecuted = false;
  @override
  void initState() {
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(width: 2.0, color: Colors.black),
        ),
      ),
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: <Widget>[
          Text(
            'Search',
            style: TextStyle(color: Colors.white, fontSize: 40),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            height: 40,
            width: 280,
            child: TextField(
              autofocus: true,
              controller: search,
              onSubmitted: (value) async => {
                await userNotes(
                        currentUser: firebaseUser.email, keyword: search.text)
                    .then((value) {
                  snapshot = value;
                  setState(() {
                    print(snapshot.docs);
                  });
                })
              },
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                  ),
                  filled: true,
                  hintStyle: TextStyle(color: Colors.grey[800]),
                  hintText: "Search your notes",
                  fillColor: Colors.white70),
            ),
          ),
          // SizedBox(
          //   width: 10,
          // ),
          // CircleAvatar(
          //   child: IconButton(
          //     onPressed: () async {
          //       await userNotes(
          //               currentUser: firebaseUser.email, keyword: search.text)
          //           .then((value) => snapshot = value);
          //       setState(() {
          //         print(snapshot.docs);
          //       });
          //     },
          //     icon: Icon(Icons.search),
          //   ),
          // ),
          Container(
              width: 300,
              height: 200,
              child: snapshot != null
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
                                    transitionEffect: TransitionEffect.FADE));
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
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
                                        snapshot.docs[index].data()["title"],
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 23),
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
                                              color:
                                                  Colors.black.withOpacity(0.5),
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
                    ))
        ],
      ),
    );
  }
}
