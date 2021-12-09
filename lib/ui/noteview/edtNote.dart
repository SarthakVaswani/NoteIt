import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes_app/main.dart';
import 'package:notes_app/service/services.dart';
import 'package:notes_app/ui/screenDecider.dart';

class EditNote extends StatefulWidget {
  DocumentSnapshot docToEdit;
  EditNote({this.docToEdit});
  @override
  _EditNoteState createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  static String selectedUser;
  String selectedUserName;
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  var firebaseUser = FirebaseAuth.instance.currentUser;
  bool hasImage = false;
  String imageUrl;
  checkImage() async {
    if (widget.docToEdit.data()['images'] != null) {
      imageUrl = widget.docToEdit.data()['images'];
      hasImage = true;
    }
  }

  @override
  void initState() {
    title = TextEditingController(text: widget.docToEdit.data()['title']);
    content = TextEditingController(text: widget.docToEdit.data()['content']);
    checkImage();

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

  bool desktop = false;

  TextEditingController search = TextEditingController();
  QuerySnapshot snapshot;
  bool isExecuted = false;
  Future<void> saveImages(File image) async {
    String imageURL = await uploadFile(image);
    DocumentReference ref = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser.email)
        .collection('Notes')
        .doc(dateCreated);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(ref);
      if (!snapshot.exists) {
        ref.set({"images": imageURL});
        // print(ref.id);

        return true;
      }
      return true;
      // ref.update({
      //   "images": FieldValue.arrayUnion([imageURL])
      // });
    });
  }

  File _image;
  bool imagepicked = false;
  Future finalUpload() async {
    await uploadFile(_image);
  }

  PickedFile pickedFile;
  Future getImage(bool gallery) async {
    ImagePicker picker = ImagePicker();

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

  String selectedUserToken;
  String returnURL;
  uploadFile(File _image) async {
    Uint8List bytes = await pickedFile.readAsBytes();
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child("image1" + DateTime.now().toString());
    UploadTask uploadTask = desktop
        ? ref.putData(bytes, SettableMetadata(contentType: 'image/png'))
        : ref.putFile(_image);

    await uploadTask.whenComplete(() async {
      await ref.getDownloadURL().then((fileURL) {
        returnURL = fileURL;
        print(returnURL);
      });
      return returnURL;
    });
  }

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
                        selectedUserToken = snapshot.docs[index].get('tokenId');
                        selectedUserName = snapshot.docs[index].get('email');
                        print(selectedUserToken);
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
                            sendNotification(
                                tokenIdi: selectedUserToken,
                                userName: selectedUserName);
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
          physics: ScrollPhysics(),
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
                        hintText: 'Content',
                        hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.7), fontSize: 23),
                      ),
                    ),
                  ),
                ),
                hasImage
                    ? InkWell(
                        onLongPress: () {
                          widget.docToEdit.reference
                              .update({'images': null}).whenComplete(
                                  () => Navigator.pop(context));
                          return ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: Duration(seconds: 2),
                              content: Text('Deleted'),
                            ),
                          );
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.25,
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: InteractiveViewer(
                            panEnabled: false, // Set it to false
                            boundaryMargin: EdgeInsets.all(100),
                            minScale: 0.5,
                            maxScale: 2,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 5,
                      )
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
                onTap: () async {
                  imagepicked
                      ? await finalUpload().then((value) =>
                          widget.docToEdit.reference.update({
                            'title': title.text,
                            'content': content.text,
                            'images': returnURL
                          }).whenComplete(() {
                            Navigator.pop(context);
                            return ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: Duration(seconds: 2),
                                content: Text('Saved'),
                              ),
                            );
                          }))
                      : widget.docToEdit.reference.update({
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
                    imagepicked
                        ? await finalUpload().then((value) => FirebaseFirestore
                                .instance
                                .runTransaction((transaction) async {
                              FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(widget.docToEdit.data()['sharedTo'])
                                  .collection('Notes')
                                  .doc(widget.docToEdit.id)
                                  .update({
                                'title': title.text,
                                'content': content.text,
                                'sharedTo': widget.docToEdit.data()['sharedTo'],
                                'images': returnURL
                              });
                            }).whenComplete(() => Navigator.pop(context)))
                        : FirebaseFirestore.instance
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
                  Icons.image,
                  color: Colors.white,
                ),
                onTap: () {
                  getImage(true);
                }),
          ],
        ),
      );
    } else if ((defaultTargetPlatform == TargetPlatform.windows)) {
      setState(() {
        desktop = true;
      });
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
                    hasImage
                        ? InkWell(
                            onLongPress: () {
                              widget.docToEdit.reference
                                  .update({'images': null}).whenComplete(
                                      () => Navigator.pop(context));
                              return ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: Duration(seconds: 2),
                                  content: Text('Deleted'),
                                ),
                              );
                            },
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.25,
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: InteractiveViewer(
                                panEnabled: false, // Set it to false
                                boundaryMargin: EdgeInsets.all(100),
                                minScale: 0.5,
                                maxScale: 2,
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 5,
                          )
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
                    onTap: () async {
                      imagepicked
                          ? await finalUpload().then((value) =>
                              widget.docToEdit.reference.update({
                                'title': title.text,
                                'content': content.text,
                                'images': returnURL
                              }).whenComplete(() {
                                Navigator.pop(context);
                                return ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    duration: Duration(seconds: 2),
                                    content: Text('Saved'),
                                  ),
                                );
                              }))
                          : widget.docToEdit.reference.update({
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
                        imagepicked
                            ? await finalUpload().then((value) =>
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
                                    'sharedTo':
                                        widget.docToEdit.data()['sharedTo'],
                                    'images': returnURL
                                  });
                                }).whenComplete(() => Navigator.pop(context)))
                            : FirebaseFirestore.instance
                                .runTransaction((transaction) async {
                                FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(widget.docToEdit.data()['sharedTo'])
                                    .collection('Notes')
                                    .doc(widget.docToEdit.id)
                                    .update({
                                  'title': title.text,
                                  'content': content.text,
                                  'sharedTo':
                                      widget.docToEdit.data()['sharedTo']
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
                      Icons.image,
                      color: Colors.white,
                    ),
                    onTap: () {
                      getImage(true);
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
