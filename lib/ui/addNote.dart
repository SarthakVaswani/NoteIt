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
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () {
              enterNotes(title.text, content.text)
                  .whenComplete(() => Navigator.pop(context));
            },
            child: Text('Save'),
            style: TextButton.styleFrom(primary: Colors.white),
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: TextFormField(
                controller: title,
                decoration: InputDecoration(hintText: 'Title'),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: TextFormField(
                  controller: content,
                  maxLines: null,
                  expands: true,
                  decoration: InputDecoration(hintText: 'Content'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
