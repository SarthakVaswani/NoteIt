import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/foundation.dart';
import 'package:notes_app/service/auth.dart';
import 'package:notes_app/ui/mobile/searchUser.dart';
import 'package:notes_app/ui/screenDecider.dart';

class EditNote extends StatefulWidget {
  DocumentSnapshot docToEdit;
  EditNote({this.docToEdit});
  @override
  _EditNoteState createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  static String selectedUser;
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  var firebaseUser = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    title = TextEditingController(text: widget.docToEdit.data()['title']);
    content = TextEditingController(text: widget.docToEdit.data()['content']);

    super.initState();
  }

  String dateCreated = DateTime.now().toIso8601String();

  checkCollab() {
    var ref = FirebaseFirestore.instance
        .collection('Users')
        .doc(firebaseUser.email)
        .collection('Notes')
        .where('sharedTo', isNull: true);
    print(ref);
    if (ref == null) {
      print('no');
    } else {
      print('yes');
    }
  }

  Future<bool> enterNotes() async {
    try {
      FirebaseFirestore.instance.runTransaction((transaction) async {
        FirebaseFirestore.instance
            .collection('Users')
            .doc(selectedUser)
            .collection('Notes')
            .doc(widget.docToEdit.id)
            .set({
          'dateTime': widget.docToEdit.data()['dateTime'],
          'title': widget.docToEdit.data()['title'],
          'content': widget.docToEdit.data()['content'],
          'sharedTo': widget.docToEdit.data()['sharedTo'],
          'createdBy': widget.docToEdit.data()['createdBy'],
        });
      });
      // FirebaseFirestore.instance.runTransaction((transaction) async {
      //   DocumentSnapshot snapshot = await transaction.get(ref);
      //   if (!snapshot.exists) {
      //     ref.set({
      //       'dateTime': await widget.docToEdit.reference.get().then((title) {
      //         snapshot.data()['dateTime'].toString();
      //       }),
      //       'title': await widget.docToEdit.reference.get().then((title) {
      //         snapshot.data()['dateTime'].toString();
      //       }),
      //       'content': await widget.docToEdit.reference.get().then((title) {
      //         snapshot.data()['dateTime'].toString();
      //       }),
      //       'sharedTo': await widget.docToEdit.reference.get().then((title) {
      //         snapshot.data()['dateTime'].toString();
      //       }),
      //     });
      //     print(widget.docToEdit.data()['title']);
      //     print(ref.id);
      //     // setState(() {
      //     //   noteId = ref.id;
      //     // });
      //     return true;
      //   }
      //   return true;
      // });
    } catch (e) {
      return false;
    }
  }

  TextEditingController search = TextEditingController();
  QuerySnapshot snapshot;
  bool isExecuted = false;
  final Email email = Email(
    body: 'Email body',
    subject: 'Email subject',
    recipients: [selectedUser],
    // cc: ['cc@example.com'],
    // bcc: ['bcc@example.com'],
    // attachmentPaths: ['/path/to/attachment.zip'],
    isHTML: false,
  );
  @override
  Widget build(BuildContext context) {
    Widget searchedData() {
      return Container(
        height: 140,
        width: 200,
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.docs.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: InkWell(
                    onTap: () {
                      setState(() {
                        selectedUser = snapshot.docs[index].get('email');
                        print(selectedUser);
                        setState(() {
                          widget.docToEdit.reference
                              .update({"sharedTo": selectedUser});
                          enterNotes().whenComplete(() async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: Duration(seconds: 2),
                                content:
                                    Text('Notes shared with $selectedUser'),
                              ),
                            );
                            await FlutterEmailSender.send(email);
                          });
                          print(selectedUser);

                          search = TextEditingController(text: "");
                          Navigator.pop(context);
                          isExecuted = true;
                        });
                      });
                    },
                    child: isExecuted
                        ? Text("")
                        : Text(snapshot.docs[index].get('email'))),
              );
            }),
      );
    }

    StateSetter _setState;

    Future<bool> _addPeople(BuildContext context) {
      return showDialog(
        // barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          elevation: 2,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              // side: BorderSide(
              //     color: Colors.white, width: 0.01),
              borderRadius: BorderRadius.circular(10)),
          title: Text(
            'Add people',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              _setState = setState;
              return Builder(builder: (context) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: search,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.white,
                            backgroundColor: Color(0xffeb6765),
                            onSurface: Colors.grey,
                          ),
                          onPressed: () async {
                            isExecuted = false;
                            await userSearch(search.text)
                                .then((value) => snapshot = value);
                            setState(() {});
                          },
                          child: Text(
                            'Search',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          )),
                      SizedBox(
                        height: 20,
                      ),
                      snapshot != null
                          ? searchedData()
                          : Center(
                              child: Text(
                              'Search people by entering their emails',
                              style: TextStyle(
                                  color: Colors.black87.withOpacity(0.7)),
                            ))
                    ],
                  ),
                );
              });
            },
          ),
        ),
      );
    }

    if ((defaultTargetPlatform == TargetPlatform.iOS) ||
        (defaultTargetPlatform == TargetPlatform.android)) {
      return Scaffold(
        backgroundColor: Color(0xffddf0f7),
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.symmetric(horizontal: 15),
                  title: TextFormField(
                    enableInteractiveSelection: true,
                    focusNode: FocusNode(),
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
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(),
                    child: TextFormField(
                      enableInteractiveSelection: true,
                      focusNode: FocusNode(),
                      cursorColor: Color(0xff2c2b4b),
                      style: TextStyle(color: Colors.black, fontSize: 23),
                      controller: content,
                      maxLines: null,
                      expands: true,
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'Content',
                        hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.7), fontSize: 23),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: SpeedDial(
          overlayOpacity: 0.0,
          openCloseDial: isDialOpen,
          overlayColor: Colors.white.withOpacity(.2),
          elevation: 7,
          icon: Icons.edit,
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Color(0xffeb6765),
          children: [
            SpeedDialChild(
                backgroundColor: Color(0xffeb6765),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                ),
                onTap: () {
                  widget.docToEdit.reference.update({
                    'title': title.text,
                    'content': content.text
                  }).whenComplete(() {
                    Navigator.pop(context);
                    return ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 2),
                        content: Text('Saved'),
                      ),
                    );
                  });

                  if (widget.docToEdit.data()['sharedTo'] != null) {
                    FirebaseFirestore.instance
                        .runTransaction((transaction) async {
                      FirebaseFirestore.instance
                          .collection('Users')
                          .doc(widget.docToEdit.data()['sharedTo'])
                          .collection('Notes')
                          .doc(widget.docToEdit.id)
                          .update({
                        'title': title.text,
                        'content': content.text,
                        'sharedTo': widget.docToEdit.data()['sharedTo']
                      });
                    }).whenComplete(() => Navigator.pop(context));
                    return ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 2),
                        content: Text('Saved'),
                      ),
                    );
                  } else {
                    print("no");
                  }
                }),
            SpeedDialChild(
                backgroundColor: Color(0xffeb6765),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                onTap: () {
                  widget.docToEdit.reference
                      .delete()
                      .whenComplete(() => Navigator.pop(context));
                  return ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: Duration(seconds: 2),
                      content: Text('Deleted'),
                    ),
                  );
                }),
            SpeedDialChild(
                backgroundColor: Color(0xffeb6765),
                child: Icon(
                  Icons.add_reaction_sharp,
                  color: Colors.white,
                ),
                onTap: () {
                  _addPeople(context);
                }),
          ],
        ),
      );
    } else if ((defaultTargetPlatform == TargetPlatform.windows)) {
      return WillPopScope(
          onWillPop: () async => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => ScreenDecider())),
          child: Scaffold(
            backgroundColor: Color(0xffddf0f7),
            body: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: EdgeInsets.symmetric(horizontal: 15),
                      title: TextFormField(
                        enableInteractiveSelection: true,
                        focusNode: FocusNode(),
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
                          hintStyle:
                              TextStyle(color: Colors.white, fontSize: 40),
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
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(),
                        child: TextFormField(
                          enableInteractiveSelection: true,
                          focusNode: FocusNode(),
                          cursorColor: Color(0xff2c2b4b),
                          style: TextStyle(color: Colors.black, fontSize: 23),
                          controller: content,
                          maxLines: null,
                          expands: true,
                          decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            hintText: 'Content',
                            hintStyle: TextStyle(
                                color: Colors.black.withOpacity(0.7),
                                fontSize: 23),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: SpeedDial(
              overlayOpacity: 0.0,
              openCloseDial: isDialOpen,
              overlayColor: Colors.white.withOpacity(.2),
              elevation: 7,
              icon: Icons.edit,
              iconTheme: IconThemeData(color: Colors.white),
              backgroundColor: Color(0xffeb6765),
              children: [
                SpeedDialChild(
                    backgroundColor: Color(0xffeb6765),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                    onTap: () {
                      widget.docToEdit.reference.update({
                        'title': title.text,
                        'content': content.text
                      }).whenComplete(() {
                        Navigator.pop(context);
                        return ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: Duration(seconds: 2),
                            content: Text('Saved'),
                          ),
                        );
                      });

                      if (widget.docToEdit.data()['sharedTo'] != null) {
                        FirebaseFirestore.instance
                            .runTransaction((transaction) async {
                          FirebaseFirestore.instance
                              .collection('Users')
                              .doc(widget.docToEdit.data()['sharedTo'])
                              .collection('Notes')
                              .doc(widget.docToEdit.id)
                              .update({
                            'title': title.text,
                            'content': content.text,
                            'sharedTo': widget.docToEdit.data()['sharedTo']
                          });
                        }).whenComplete(() => Navigator.pop(context));
                        return ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: Duration(seconds: 2),
                            content: Text('Saved'),
                          ),
                        );
                      } else {
                        print("no");
                      }
                    }),
                SpeedDialChild(
                    backgroundColor: Color(0xffeb6765),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    onTap: () {
                      widget.docToEdit.reference
                          .delete()
                          .whenComplete(() => Navigator.pop(context));
                      return ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: Duration(seconds: 2),
                          content: Text('Deleted'),
                        ),
                      );
                    }),
                SpeedDialChild(
                    backgroundColor: Color(0xffeb6765),
                    child: Icon(
                      Icons.add_reaction_sharp,
                      color: Colors.white,
                    ),
                    onTap: () {
                      _addPeople(context);
                    }),
                SpeedDialChild(
                    backgroundColor: Color(0xffeb6765),
                    child: Icon(
                      Icons.arrow_back_ios_outlined,
                      color: Colors.white,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    }),
              ],
            ),
          ) // ),
          );
    }
  }
}
