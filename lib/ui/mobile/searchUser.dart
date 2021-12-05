import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/service/auth.dart';

String selectedUser;

class SearchUsers extends StatefulWidget {
  const SearchUsers({Key key}) : super(key: key);

  @override
  _SearchUsersState createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers> {
  TextEditingController search = TextEditingController();
  QuerySnapshot snapshot;
  bool isExecuted = false;

  @override
  Widget build(BuildContext context) {
    Widget searchedData() {
      return ListView.builder(
          itemCount: snapshot.docs.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedUser = snapshot.docs[index].get('email');
                      print(selectedUser);
                    });
                  },
                  child: Text(snapshot.docs[index].get('email'))),
            );
          });
    }

    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () async {
                await userSearch(search.text).then((value) => snapshot = value);
                setState(() {
                  // isExecuted = true;
                  // print(snapshot.docs[0].data()['email']);
                });
              },
              icon: Icon(Icons.search),
            ),
          ],
          title: TextField(
            controller: search,
          ),
        ),
        body: snapshot != null
            ? searchedData()
            : Center(child: CircularProgressIndicator()));
  }
}
