import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddNote extends StatefulWidget {
  @override
  _AddNoteState createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();

  Future<bool> enterNotes(String title, String content) async {
    try {
      String uid = FirebaseAuth.instance.currentUser.uid;
      DocumentReference ref = FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .collection('Notes')
          .doc(title);
      FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(ref);
        if (!snapshot.exists) {
          ref.set({'title': title, 'content': content});
          return true;
        }
        return true;
      });
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    return Scaffold(
      backgroundColor: Color(0xffddf0f7),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.symmetric(horizontal: 15),
                title: TextFormField(
                  onEditingComplete: () => node.nextFocus(),
                  autofocus: true,
                  cursorColor: Color(0xffddf0f7),
                  style: TextStyle(color: Colors.white, fontSize: 40),
                  controller: title,
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                    hintText: 'Title',
                    hintStyle: TextStyle(color: Colors.white, fontSize: 40),
                  ),
                ),
              ),
              elevation: 0,
              automaticallyImplyLeading: false,
              backgroundColor: Color(0xff2c2b4b),
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
            ),
          ];
        },
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(),
                  child: TextFormField(
                    cursorColor: Color(0xff2c2b4b),
                    style: TextStyle(color: Colors.black, fontSize: 25),
                    controller: content,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Content',
                      hintStyle: TextStyle(
                          color: Colors.black.withOpacity(0.7), fontSize: 25),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: SingleChildScrollView(
        child: Column(
          children: [
            MaterialButton(
              elevation: 2,
              minWidth: MediaQuery.of(context).size.width / 10,
              height: MediaQuery.of(context).size.height / 15,
              shape: CircleBorder(
                  side: BorderSide(
                width: 2,
                color: Color(0xffeb6765),
              )),
              child: Icon(
                Icons.arrow_back_ios_sharp,
                color: Colors.white,
              ),
              color: Color(0xffeb6765),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            SizedBox(
              height: 10,
            ),
            MaterialButton(
              elevation: 3,
              height: MediaQuery.of(context).size.height / 12,
              shape: CircleBorder(
                side: BorderSide(width: 2, color: Color(0xffeb6765)),
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
              ),
              color: Color(0xffeb6765),
              onPressed: () {
                enterNotes(title.text, content.text)
                    .whenComplete(() => Navigator.pop(context));
                return ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: Duration(seconds: 2),
                    content: Text('Saved'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
