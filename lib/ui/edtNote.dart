import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditNote extends StatefulWidget {
  DocumentSnapshot docToEdit;
  EditNote({this.docToEdit});
  @override
  _EditNoteState createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();

  @override
  void initState() {
    title = TextEditingController(text: widget.docToEdit.data()['title']);
    content = TextEditingController(text: widget.docToEdit.data()['content']);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
      floatingActionButton: SingleChildScrollView(
        child: Column(
          children: [
            MaterialButton(
              elevation: 2,
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
              height: 18,
            ),
            MaterialButton(
              elevation: 2,
              height: MediaQuery.of(context).size.height / 15,
              shape: CircleBorder(
                  side: BorderSide(
                width: 2,
                color: Color(0xffeb6765),
              )),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
              color: Color(0xffeb6765),
              onPressed: () {
                widget.docToEdit.reference
                    .delete()
                    .whenComplete(() => Navigator.pop(context));
                return ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: Duration(seconds: 2),
                    content: Text('Deleted'),
                  ),
                );
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
                widget.docToEdit.reference.update({
                  'title': title.text,
                  'content': content.text
                }).whenComplete(() => Navigator.pop(context));
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
