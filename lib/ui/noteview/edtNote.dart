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
import 'package:notes_app/service/local_authS/localauthS.dart';
import 'package:notes_app/service/services.dart';
import 'package:notes_app/ui/screenDecider.dart';
import 'package:notes_app/ui/widgets/colorPicker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class _TodoItem {
  String title;
  bool completed;

  _TodoItem({
    @required this.title,
    @required this.completed,
  });
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "completed": completed,
    };
  }
}

class _NewTODO {
  String title;
  bool completed;

  _NewTODO({
    @required this.title,
    @required this.completed,
  });
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "completed": completed,
    };
  }
}

class EditNote extends StatefulWidget {
  DocumentSnapshot docToEdit;
  EditNote({this.docToEdit});
  @override
  _EditNoteState createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  static String selectedUser;
  String SelctedUserFullame;
  String selectedUserName;
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  var firebaseUser = FirebaseAuth.instance.currentUser;
  bool hasImage = false;
  bool hasNotes = false;
  bool hasList = false;
  String returnURL;
  var notesUrl;
  checkImage() async {
    if (widget.docToEdit.get('images') != null) {
      returnURL = widget.docToEdit.get('images');
      hasImage = true;
    }
  }

  checkNotes() async {
    if (widget.docToEdit.get('noteAdded') != null) {
      notesUrl = widget.docToEdit.get('noteAdded');
      hasNotes = true;
    }
  }

  bool hasLock = false;
  checkLock() async {
    if (widget.docToEdit.get('lock') == true) {
      setState(() {
        hasLock = true;
      });
    }
  }

  final List<_TodoItem> _todoList = [];
  final List<_NewTODO> _newTodo = [];
  var pp = [];
  final Map<String, bool> _map = {};
  checkList() async {
    if (widget.docToEdit.get('listcheck').toString().isNotEmpty) {
      // notesUrl = widget.docToEdit.data()['listcheck'];
      hasList = true;
      pp = widget.docToEdit.get('listcheck');
      for (int i = 0; i < pp.length; i++) {
        _todoList.add(
            _TodoItem(title: pp[i]['title'], completed: pp[i]['completed']));
      }
    }
  }

  @override
  void initState() {
    title = TextEditingController(text: widget.docToEdit.get('title'));
    content = TextEditingController(text: widget.docToEdit.get('content'));
    newColor = Color(widget.docToEdit.get('noteColor'));
    checkImage();
    checkNotes();
    checkList();
    checkLock();
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

  final TextEditingController _todoTitleController = TextEditingController();

  bool islist = false;
  Future<bool> _txtchange(BuildContext context) {
    return showDialog(
        // barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Add Todo Item'),
              content: TextField(
                controller: _todoTitleController,
              ),
              actions: [
                TextButton(
                  child: const Text('Add'),
                  onPressed: () {
                    setState(() {
                      _newTodo.add(
                        _NewTODO(
                          title: _todoTitleController.text,
                          completed: false,
                        ),
                      );
                      islist = true;
                      if (islist) {
                        for (int k = 0; k < _newTodo.length; k++) {
                          _todoList.add(_TodoItem(
                            title: _newTodo[k].title,
                            completed: _newTodo[k].completed,
                          ));
                        }
                      }
                    });
                    _todoTitleController.clear();
                    FocusScope.of(context).unfocus();
                    Navigator.pop(context);
                  },
                ),
              ],
            ));
  }

  Future<bool> _showImage(BuildContext context, String url) {
    return showDialog(
      // barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        content: Container(
          height: 300,
          width: 300,
          child: InteractiveViewer(
              panEnabled: false, // Set it to false
              boundaryMargin: EdgeInsets.all(55),
              minScale: 0.5,
              maxScale: 2,
              child: Image.network(url, fit: BoxFit.contain)),
        ),
      ),
    );
  }

  Widget listTest() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _newTodo.length,
      itemBuilder: (context, index) {
        return CheckboxListTile(
          value: _newTodo[index].completed,
          title: Text(_newTodo[index].title),
          onChanged: (value) => setState(
            () => _newTodo[index].completed = value,
          ),
        );
      },
    );
  }

  Future<bool> enterNotesToshared() async {
    try {
      FirebaseFirestore.instance.runTransaction((transaction) async {
        FirebaseFirestore.instance
            .collection('Users')
            .doc(selectedUser)
            .collection('Notes')
            .doc(widget.docToEdit.id)
            .set({
          'dateTime': widget.docToEdit.get('dateTime'),
          'title': widget.docToEdit.get('title'),
          'content': widget.docToEdit.get('content'),
          'sharedTo': widget.docToEdit.get('sharedTo'),
          'createdBy': widget.docToEdit.get('createdBy'),
          'noteColor': widget.docToEdit.get('noteColor'),
          'images': widget.docToEdit.get('images'),
          'noteAdded': widget.docToEdit.get('noteAdded'),
          'lock': false,
          'listcheck': _todoList.map((e) {
            return e.toJson();
          }).toList()
        });
      });
    } catch (e) {
      return false;
    }
  }

  bool desktop = false;
  TextEditingController search = TextEditingController();
  QuerySnapshot snapshot;
  bool isExecuted = false;
  Future<void> saveImages(File image) async {
    DocumentReference ref = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser.email)
        .collection('Notes')
        .doc(dateCreated);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(ref);
      if (!snapshot.exists) {
        ref.set({"images": returnURL});
        // print(ref.id);

        return true;
      }
      return true;
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
        finalUpload();
        // Use if you only need a single picture
      } else {
        print('No image selected.');
      }
    });
  }

  bool imgLoading = false;
  Color newColor;
  String selectedUserToken;
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
        setState(() {
          imgLoading = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Image Added')));
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
                        SelctedUserFullame =
                            snapshot.docs[index].get('fullname');
                        selectedUserName = firebaseUser.email;
                        print(selectedUserToken);
                        setState(() {
                          widget.docToEdit.reference
                              .update({"sharedTo": selectedUser});
                          enterNotesToshared().whenComplete(() async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: Duration(seconds: 2),
                                content:
                                    Text('Notes shared with $selectedUser'),
                              ),
                            );
                            sendNotification(
                                fullName: SelctedUserFullame,
                                tokenIdi: selectedUserToken,
                                userName: selectedUserName);
                          });
                          print(selectedUser);

                          search = TextEditingController(text: "");
                          Navigator.pop(context);
                          isExecuted = true;
                          var firebaseUser = FirebaseAuth.instance.currentUser;
                          String dateCreated = DateTime.now().toIso8601String();
                          DocumentReference ref = FirebaseFirestore.instance
                              .collection('Users')
                              .doc(selectedUser)
                              .collection('Notifications')
                              .doc(dateCreated);
                          FirebaseFirestore.instance
                              .runTransaction((transaction) async {
                            DocumentSnapshot snapshot =
                                await transaction.get(ref);
                            if (!snapshot.exists) {
                              ref.set({
                                'sharedBy': firebaseUser.email,
                                'SharedTo': selectedUser,
                                'title': title.text,
                                'contents': "Shared Notes with you",
                                'dateTime': dateCreated
                              });
                              print(ref.id);
                            }
                          });
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

    ScreenshotController screenshotController = ScreenshotController();

    File sharedFile;
    Future<void> shareTo() async {
      final status = await Permission.storage.request();
      if (status != PermissionStatus.granted) {
        print('Storage Permission');
      }
      await screenshotController
          .capture(delay: const Duration(milliseconds: 3))
          .then((Uint8List image) async {
        if (image != null) {
          final directory = await getApplicationDocumentsDirectory();
          sharedFile = await File('${directory.path}/image.png').create();
          await sharedFile.writeAsBytes(image);
          await Share.shareFiles([sharedFile.path], text: title.text);

          /// Share Plugin
        }
      });
    }

    StateSetter _setState;
    Color _color = Color(0xffddf0f7);
    Future<bool> _changeColor(BuildContext context) {
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
              'Choose Note Color',
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            content: Container(
              height: 200,
              width: 200,
              child: MyColorPicker(
                  onSelectColor: (value) {
                    setState(() {
                      newColor = value;

                      print(newColor.toString());
                      Navigator.pop(context);
                    });
                  },
                  availableColors: [
                    Color(0xffe8a87c),
                    Color(0xffd8f3dc),
                    Colors.greenAccent,
                    Color(0xfff1dca7),
                    Color(0xffcad2c5),
                    Colors.limeAccent.shade100,
                    Colors.cyanAccent.shade100,
                    Colors.redAccent.shade100,
                    Colors.purpleAccent.shade100,
                    Colors.indigoAccent.shade100
                  ],
                  initialColor: Colors.white),
            )),
      );
    }

    bool isUpdated = false;
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
                            backgroundColor: Colors.black,
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
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          title: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Edit Note',
                    style: TextStyle(color: Colors.black, fontSize: 28),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                  ),
                  IconButton(
                      onPressed: () async {
                        shareTo();
                      },
                      icon: Icon(Icons.share_rounded)),
                  SizedBox(
                    width: 5,
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.black,
                    child: IconButton(
                      onPressed: () async {
                        imagepicked
                            ? widget.docToEdit.reference.update({
                                'title': title.text,
                                'content': content.text,
                                'images': returnURL,
                                'noteColor': newColor.value,
                                'listcheck': _todoList.map((e) {
                                  return e.toJson();
                                }).toList()
                              }).whenComplete(() {
                                Navigator.pop(context);
                                return ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    duration: Duration(seconds: 2),
                                    content: Text('Saved'),
                                  ),
                                );
                              })
                            : widget.docToEdit.reference.update({
                                'title': title.text,
                                'content': content.text,
                                'noteColor': newColor.value,
                                'listcheck': _todoList.map((e) {
                                  return e.toJson();
                                }).toList()
                              }).whenComplete(() {
                                Navigator.pop(context);
                                return ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    duration: Duration(seconds: 2),
                                    content: Text('Saved'),
                                  ),
                                );
                              });

                        if (widget.docToEdit.get('sharedTo') != null) {
                          imagepicked
                              ? await finalUpload().then((value) =>
                                  FirebaseFirestore.instance
                                      .runTransaction((transaction) async {
                                    FirebaseFirestore.instance
                                        .collection('Users')
                                        .doc(
                                            widget.docToEdit.get('sharedTo'))
                                        .collection('Notes')
                                        .doc(widget.docToEdit.id)
                                        .update({
                                      'title': title.text,
                                      'content': content.text,
                                      'sharedTo':
                                          widget.docToEdit.get('sharedTo'),
                                      'images': returnURL,
                                      'noteColor': newColor.value,
                                      'listcheck': _todoList.map((e) {
                                        return e.toJson();
                                      }).toList()
                                    });
                                  }).whenComplete(() => Navigator.pop(context)))
                              : FirebaseFirestore.instance
                                  .runTransaction((transaction) async {
                                  FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(widget.docToEdit.get('sharedTo'))
                                      .collection('Notes')
                                      .doc(widget.docToEdit.id)
                                      .update({
                                    'title': title.text,
                                    'content': content.text,
                                    'sharedTo':
                                        widget.docToEdit.get('sharedTo'),
                                    'noteColor': newColor.value,
                                    'listcheck': _todoList.map((e) {
                                      return e.toJson();
                                    }).toList()
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
                      },
                      icon: Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        backgroundColor: newColor,
        body: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Expanded(
                child: Screenshot(
                  controller: screenshotController,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    color: newColor,
                    child: Column(children: [
                      Container(
                        child: TextFormField(
                          enableInteractiveSelection: true,
                          focusNode: FocusNode(),
                          cursorColor: Color(0xffddf0f7),
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 36,
                              fontWeight: FontWeight.bold),
                          controller: title,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 6),
                            hintText: 'Title',
                            hintStyle:
                                TextStyle(color: Colors.black, fontSize: 40),
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.black,
                        thickness: 0.5,
                      ),
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
                                  color: Colors.black.withOpacity(0.7),
                                  fontSize: 23),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          hasImage
                              ? Expanded(
                                  flex: 2,
                                  child: InkWell(
                                    onTap: () {
                                      _showImage(context, returnURL);
                                    },
                                    onLongPress: () {
                                      widget.docToEdit.reference.update({
                                        'images': null
                                      }).whenComplete(
                                          () => Navigator.pop(context));
                                      return ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          duration: Duration(seconds: 2),
                                          content: Text('Deleted'),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.25,
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      child: InteractiveViewer(
                                        panEnabled: false, // Set it to false
                                        boundaryMargin: EdgeInsets.all(100),
                                        minScale: 0.5,
                                        maxScale: 2,
                                        child: Image.network(
                                          returnURL,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
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
                                  ),
                                )
                              : Container(),
                          hasNotes
                              ? Expanded(
                                  flex: 2,
                                  child: InkWell(
                                    onTap: () {
                                      _showImage(context, notesUrl);
                                    },
                                    onLongPress: () {
                                      widget.docToEdit.reference.update({
                                        'noteAdded': null
                                      }).whenComplete(
                                          () => Navigator.pop(context));
                                      return ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          duration: Duration(seconds: 2),
                                          content: Text('Deleted'),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.25,
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      child: InteractiveViewer(
                                        panEnabled: false, // Set it to false
                                        boundaryMargin: EdgeInsets.all(100),
                                        minScale: 0.5,
                                        maxScale: 2,
                                        child: Image.network(
                                          notesUrl,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
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
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                      islist ? listTest() : Container(),
                      hasList
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Padding(
                                //   padding: const EdgeInsets.symmetric(horizontal: 7),
                                //   child: Text(
                                //     'Previous Todo',
                                //     style: TextStyle(
                                //         fontSize: 17, fontWeight: FontWeight.bold),
                                //   ),
                                // ),
                                ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: pp.length,
                                    itemBuilder: (context, index) {
                                      return CheckboxListTile(
                                          value: pp[index]['completed'],
                                          title: Text(
                                            pp[index]['title'],
                                            style: pp[index]['completed']
                                                ? TextStyle(
                                                    decoration: TextDecoration
                                                        .lineThrough)
                                                : TextStyle(
                                                    decoration:
                                                        TextDecoration.none),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              isUpdated = true;
                                              pp[index]['completed'] = value;
                                              if (isUpdated) {
                                                _todoList.removeAt(index);
                                                _todoList.add(_TodoItem(
                                                    title: pp[index]['title'],
                                                    completed: pp[index]
                                                        ['completed']));
                                              }
                                            });
                                          });
                                    }),
                              ],
                            )
                          : Container(),
                    ]),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    hasLock
                        ? IconButton(
                            onPressed: () async {
                              final isAuthenticated =
                                  await LocalAuthApi.authenticate();
                              if (isAuthenticated) {
                                widget.docToEdit.reference
                                    .update({'lock': false});
                                setState(() {
                                  hasLock = false;
                                });
                              }
                            },
                            icon: Icon(
                              Icons.lock_open_rounded,
                              color: Colors.white,
                            ),
                          )
                        : IconButton(
                            onPressed: () async {
                              final isAuthenticated =
                                  await LocalAuthApi.authenticate();
                              if (isAuthenticated) {
                                widget.docToEdit.reference
                                    .update({'lock': true});
                                setState(() {
                                  hasLock = true;
                                });
                              }
                            },
                            icon: Icon(
                              Icons.lock_sharp,
                              color: Colors.white,
                            ),
                          ),
                    IconButton(
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
                      icon: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _addPeople(context);
                      },
                      icon: Icon(
                        Icons.add_reaction_sharp,
                        color: Colors.white,
                      ),
                    ),
                    imgLoading
                        ? CircularProgressIndicator()
                        : IconButton(
                            onPressed: () {
                              getImage(true);
                              setState(() {
                                imgLoading = true;
                              });
                            },
                            icon: Icon(
                              Icons.image,
                              color: Colors.white,
                            ),
                          ),
                    IconButton(
                      onPressed: () {
                        _changeColor(context);
                      },
                      icon: Icon(
                        Icons.color_lens_sharp,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _txtchange(context);
                      },
                      icon: Icon(
                        Icons.check_box,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                                  returnURL,
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

                      if (widget.docToEdit.get('sharedTo') != null) {
                        imagepicked
                            ? await finalUpload().then((value) =>
                                FirebaseFirestore.instance
                                    .runTransaction((transaction) async {
                                  FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(widget.docToEdit.get('sharedTo'))
                                      .collection('Notes')
                                      .doc(widget.docToEdit.id)
                                      .update({
                                    'title': title.text,
                                    'content': content.text,
                                    'sharedTo':
                                        widget.docToEdit.get('sharedTo'),
                                    'images': returnURL
                                  });
                                }).whenComplete(() => Navigator.pop(context)))
                            : FirebaseFirestore.instance
                                .runTransaction((transaction) async {
                                FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(widget.docToEdit.get('sharedTo'))
                                    .collection('Notes')
                                    .doc(widget.docToEdit.id)
                                    .update({
                                  'title': title.text,
                                  'content': content.text,
                                  'sharedTo':
                                      widget.docToEdit.get('sharedTo')
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
