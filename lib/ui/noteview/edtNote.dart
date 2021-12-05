import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/foundation.dart';
import 'package:notes_app/ui/mobile/searchUser.dart';
import 'package:notes_app/ui/screenDecider.dart';

class EditNote extends StatefulWidget {
  DocumentSnapshot docToEdit;
  EditNote({this.docToEdit});
  @override
  _EditNoteState createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  @override
  void initState() {
    title = TextEditingController(text: widget.docToEdit.data()['title']);
    content = TextEditingController(text: widget.docToEdit.data()['content']);

    super.initState();
  }

  Future<bool> enterNotes() async {
    try {
      String dateCreated = DateTime.now().toIso8601String();
      DocumentReference ref = FirebaseFirestore.instance
          .collection('Users')
          .doc("project90@gmail.com")
          .collection('Notes')
          .doc(dateCreated);

      FirebaseFirestore.instance.runTransaction((transaction) async {
        FirebaseFirestore.instance
            .collection('Users')
            .doc("project90@gmail.com")
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

  @override
  Widget build(BuildContext context) {
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
                  widget.docToEdit.reference
                      .update({'title': title.text, 'content': content.text});
                  FirebaseFirestore.instance
                      .runTransaction((transaction) async {
                    FirebaseFirestore.instance
                        .collection('Users')
                        .doc("project90@gmail.com")
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
                }),
            SpeedDialChild(
                backgroundColor: Color(0xffeb6765),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                onTap: () {
                  widget.docToEdit.reference.update({"sharedTo": selectedUser});
                  print(selectedUser);

                  // print(widget.docToEdit.reference.id);
                  enterNotes();
                  // widget.docToEdit.reference
                  //     .delete()
                  //     .whenComplete(() => Navigator.pop(context));
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
                  Icons.arrow_back_ios_outlined,
                  color: Colors.white,
                ),
                onTap: () {
                  Navigator.of(context).pop();
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
                      widget.docToEdit.reference.update(
                          {'title': title.text, 'content': content.text});
                      FirebaseFirestore.instance
                          .runTransaction((transaction) async {
                        FirebaseFirestore.instance
                            .collection('Users')
                            .doc("project90@gmail.com")
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
                    }),
                SpeedDialChild(
                    backgroundColor: Color(0xffeb6765),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    onTap: () {
                      String dateCreated = DateTime.now().toIso8601String();
                      widget.docToEdit.reference
                          .update({"sharedTo": "project90@gmail.com"});
                      String noteId = widget.docToEdit.reference.id;
                      // print(widget.docToEdit.reference.id);
                      enterNotes();
                      // widget.docToEdit.reference
                      //     .delete()
                      //     .whenComplete(() => Navigator.pop(context));
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
