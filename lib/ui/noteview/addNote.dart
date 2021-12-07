import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddNote extends StatefulWidget {
  @override
  _AddNoteState createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();
  var noteId;
  static var firebaseUser;
  getUser() async {
    firebaseUser = await FirebaseAuth.instance.currentUser;
  }

  List<File> _images = [];
  File _image; // Used only if you need a single picture
  bool imagepicked = false;

  Future getImage(bool gallery) async {
    ImagePicker picker = ImagePicker();
    PickedFile pickedFile;
    // Let user select photo from gallery
    if (gallery) {
      pickedFile = await picker.getImage(
        source: ImageSource.gallery,
      );
    }
    // Otherwise open camera to get new photo
    else {
      pickedFile = await picker.getImage(
        source: ImageSource.camera,
      );
    }

    setState(() {
      if (pickedFile != null) {
        // _images.add(File(pickedFile.path));
        _image = File(pickedFile.path);
        imagepicked = true;
        // uploadFile(_image);

        // Use if you only need a single picture
      } else {
        print('No image selected.');
      }
    });
  }

  Future finalUpload() async {
    await uploadFile(_image);
  }

  String returnURL;
  uploadFile(File _image) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child("image1" + DateTime.now().toString());
    UploadTask uploadTask = ref.putFile(_image);

    await uploadTask.whenComplete(() async {
      await ref.getDownloadURL().then((fileURL) {
        returnURL = fileURL;
        print(returnURL);
      });
      return returnURL;
      // uploadTask.then((res) {
      //   var url = res.ref.getDownloadURL();
      //   print(url);
      // });
    });
  }

  String dateCreated = DateTime.now().toIso8601String();

  Future enterNotes(String title, String content) async {
    try {
      var firebaseUser = FirebaseAuth.instance.currentUser;

      DocumentReference ref = FirebaseFirestore.instance
          .collection('Users')
          .doc(firebaseUser.email)
          .collection('Notes')
          .doc(dateCreated);
      FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(ref);
        if (!snapshot.exists) {
          imagepicked
              ? await finalUpload().then((value) => ref.set({
                    'dateTime': FieldValue.serverTimestamp(),
                    'title': title,
                    'content': content,
                    'sharedTo': null,
                    'createdBy': firebaseUser.email,
                    'images': returnURL
                  }))
              : ref.set({
                  'dateTime': FieldValue.serverTimestamp(),
                  'title': title,
                  'content': content,
                  'sharedTo': null,
                  'createdBy': firebaseUser.email
                });
          print(ref.id);
          // setState(() {
          //   noteId = ref.id;
          // });
          return true;
        }
        return 'true';
      });
    } catch (e) {
      return false;
    }
  }

  @override
  void initState() {
    getUser();
    super.initState();
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
                    onFieldSubmitted: (value) {
                      enterNotes(title.text, content.text)
                          .whenComplete(() => Navigator.pop(context));
                      return ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: Duration(seconds: 2),
                          content: Text('Saved'),
                        ),
                      );
                    },
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
                Icons.close_rounded,
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
              elevation: 2,
              minWidth: MediaQuery.of(context).size.width / 10,
              height: MediaQuery.of(context).size.height / 15,
              shape: CircleBorder(
                  side: BorderSide(
                width: 2,
                color: Color(0xffeb6765),
              )),
              child: Icon(
                Icons.image,
                color: Colors.white,
              ),
              color: Color(0xffeb6765),
              onPressed: () {
                getImage(true);
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
                size: 25,
              ),
              color: Color(0xffeb6765),
              onPressed: () async {
                await enterNotes(title.text, content.text)
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