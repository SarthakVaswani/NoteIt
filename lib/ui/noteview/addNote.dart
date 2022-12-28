import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes_app/ui/widgets/colorPicker.dart';
import 'package:notes_app/ui/widgets/drawing/draw_line.dart';
import 'package:notes_app/ui/widgets/drawing/sketcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

import '../../service/encrypt_aes.dart';
import '../screenDecider.dart';

class AddNote extends StatefulWidget {
  @override
  _AddNoteState createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();
  var noteId;
  static var firebaseUser;

  GlobalKey _globalKey = new GlobalKey();
  List<DrawnLine> lines = <DrawnLine>[];
  DrawnLine line;
  Color selectedColor = Colors.black;
  double selectedWidth = 5.0;
  String bs64;
  StreamController<List<DrawnLine>> linesStreamController =
      StreamController<List<DrawnLine>>.broadcast();
  StreamController<DrawnLine> currentLineStreamController =
      StreamController<DrawnLine>.broadcast();
  String path;
  File imageFile;

  Future<void> save() async {
    final status = await Permission.storage.request();
    if (status != PermissionStatus.granted) {
      print('Storage Permission');
    }
    await screenshotController
        .capture(delay: const Duration(milliseconds: 10))
        .then((Uint8List image) async {
      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = await File('${directory.path}/image.png').create();
        await imagePath.writeAsBytes(image);
        setState(() {
          imageFile = imagePath;
          noteAdded = true;
        });

        /// Share Plugin
        await uploadNote(imageFile);
      }
    });
  }

  Widget buildProgress(UploadTask uploadTask) => StreamBuilder<TaskSnapshot>(
      stream: uploadTask.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final snap = snapshot.data;
          final progress = snap.bytesTransferred / snap.totalBytes;
          final percentage = (progress * 100).toStringAsFixed(2);
          return Text(
            '$percentage',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          );
        } else {
          return Container();
        }
      });

  Future<void> clear() async {
    setState(() {
      lines = [];
      line = null;
    });
  }

  bool desktop = false;
  checkPlatfrom() {
    if ((defaultTargetPlatform == TargetPlatform.windows)) {
      setState(() {
        desktop = true;
      });
    }
  }

  ScreenshotController screenshotController = ScreenshotController();

  getUser() async {
    firebaseUser = await FirebaseAuth.instance.currentUser;
  }

  final Map<String, bool> _map = {};
  int _count = 0;
  List<File> _images = [];
  File _image; // Used only if you need a single picture
  bool imagepicked = false;
  bool noteAdded = false;
  Color _color = Color(0xffddf0f7);
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
        print(pickedFile.path);
        imagepicked = true;
        finalUpload();
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

  bool loading = false;
  bool imgLoading = false;
  String returnURL;
  String noteUrl;

  String encryptedTitle;
  UploadTask uploadTask;
  uploadNote(File _image) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child("image1" + DateTime.now().toString());

    uploadTask = ref.putFile(_image);

    await uploadTask.whenComplete(() async {
      await ref.getDownloadURL().then((fileURL) {
        noteUrl = fileURL;
        setState(() {
          loading = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Draw Note Added')));
        print(noteUrl);
      });
      return noteUrl;
    });
  }

  bool uploadedImg = false;
  uploadFile(File _image) async {
    Uint8List bytes = await pickedFile.readAsBytes();
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child("image1" + DateTime.now().toString());

    uploadTask = desktop
        ? ref.putData(bytes, SettableMetadata(contentType: 'image/png'))
        : ref.putFile(_image);
    setState(() {});
    await uploadTask.whenComplete(() async {
      await ref.getDownloadURL().then((fileURL) {
        returnURL = fileURL;
        setState(() {
          imgLoading = false;
          uploadedImg = true;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Image Added')));
        print(returnURL);
      });
      return returnURL;
    });
  }

  encryptUserData(data) {
    String enDAta = EncryptData.encryptAES(data);
    print("Enj=${enDAta}");
    return enDAta;
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
              ? ref.set({
                  'dateTime': FieldValue.serverTimestamp(),
                  'title': title,
                  'content': content,
                  'sharedTo': null,
                  'Pin': "false",
                  'createdBy': firebaseUser.email,
                  'images': returnURL,
                  'noteColor': _color.value,
                  'noteAdded': noteUrl,
                  'lock': false,
                  'listcheck': _todoList.map((e) {
                    return e.toJson();
                  }).toList()
                })
              : ref.set({
                  'dateTime': FieldValue.serverTimestamp(),
                  'title': title,
                  'content': content,
                  'Pin': "false",
                  'sharedTo': null,
                  'createdBy': firebaseUser.email,
                  'noteColor': _color.value,
                  'noteAdded': noteUrl,
                  'lock': false,
                  'listcheck': _todoList.map((e) {
                    return e.toJson();
                  }).toList()
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

  bool drawBoard = false;
  StateSetter _setState;

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
                    _color = value;
                    Navigator.pop(context);
                    print(_color.value);
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

  Future<bool> _changeStroke(BuildContext context) {
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
            'Choose Stroke size',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          content: Container(
            height: 60,
            width: 60,
            child: buildStrokeToolbar(),
          )),
    );
  }

  final TextEditingController _todoTitleController = TextEditingController();
  final List<_TodoItem> _todoList = [];

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
                      _todoList.add(
                        _TodoItem(
                          title: _todoTitleController.text,
                          completed: false,
                        ),
                      );
                      islist = true;
                    });
                    _todoTitleController.clear();
                    FocusScope.of(context).unfocus();
                    Navigator.pop(context);
                  },
                ),
              ],
            ));
  }

  bool islist = false;
  @override
  void initState() {
    getUser();
    checkPlatfrom();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);

    if ((defaultTargetPlatform == TargetPlatform.iOS) ||
        (defaultTargetPlatform == TargetPlatform.android)) {
      return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          title: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Add Note',
                    style: TextStyle(color: Colors.black, fontSize: 28),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.35,
                  ),
                  CircleAvatar(
                      backgroundColor: Colors.black,
                      child: IconButton(
                          onPressed: () async {
                            if (title.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: Duration(seconds: 2),
                                  content: Text('Add title'),
                                ),
                              );
                              return false;
                            }
                            print("encrypted:${encryptedTitle}");
                            await enterNotes(encryptedTitle, content.text)
                                .whenComplete(() => Navigator.pop(context));
                            return ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: Duration(seconds: 2),
                                content: Text('Saved'),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.check,
                            color: Colors.white,
                          )))
                ],
              )
            ],
          ),
        ),
        backgroundColor: _color,
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              // Divider(
              //   color: Colors.black,
              // ),
              Container(
                child: TextFormField(
                  onEditingComplete: () {
                    setState(() {
                      encryptedTitle = encryptUserData(title.text);
                    });
                    print(encryptedTitle);
                    node.nextFocus();
                  },
                  autofocus: false,
                  cursorColor: Color(0xffddf0f7),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 36,
                      fontWeight: FontWeight.bold),
                  controller: title,
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                    hintText: 'Title',
                    hintStyle: TextStyle(color: Colors.black, fontSize: 40),
                  ),
                ),
              ),

              drawBoard
                  ? Expanded(
                      child: Stack(
                        children: [
                          buildAllPaths(context),
                          buildCurrentPath(context),
                          buildColorToolbar(),
                        ],
                      ),
                    )
                  : Expanded(
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
                            border: InputBorder.none,
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            hintText: 'Content',
                            hintStyle: TextStyle(
                                color: Colors.black.withOpacity(0.7),
                                fontSize: 25),
                          ),
                        ),
                      ),
                    ),
              islist ? listTest() : Container(),
              uploadedImg
                  ? Container(
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
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : Container(),
              Container(
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: drawBoard
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: clear,
                            icon: Icon(
                              Icons.clear,
                              color: Colors.white,
                            ),
                          ),
                          loading
                              ? CircularProgressIndicator()
                              : IconButton(
                                  onPressed: () async {
                                    save();
                                    setState(() {
                                      loading = true;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.save_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                          IconButton(
                            onPressed: () {
                              _changeStroke(context);
                            },
                            icon: Icon(
                              Icons.line_weight_rounded,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                drawBoard = !drawBoard;
                                islist = !islist;
                              });
                            },
                            icon: Icon(
                              Icons.create,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                              setState(() {
                                drawBoard = !drawBoard;
                                if (islist) {
                                  islist = false;
                                }
                              });
                            },
                            icon: Icon(
                              Icons.create,
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
                        onEditingComplete: () => node.nextFocus(),
                        autofocus: false,
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
                                color: Colors.black.withOpacity(0.7),
                                fontSize: 25),
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
                  // MaterialButton(
                  //   elevation: 3,
                  //   height: MediaQuery.of(context).size.height / 12,
                  //   shape: CircleBorder(
                  //     side: BorderSide(width: 2, color: Color(0xffeb6765)),
                  //   ),
                  //   child: Icon(
                  //     Icons.check,
                  //     color: Colors.white,
                  //     size: 25,
                  //   ),
                  //   color: Color(0xffeb6765),
                  //   onPressed: () async {
                  //     await enterNotes(title.text, content.text)
                  //         .whenComplete(() => Navigator.pop(context));
                  //     return ScaffoldMessenger.of(context).showSnackBar(
                  //       SnackBar(
                  //         duration: Duration(seconds: 2),
                  //         content: Text('Saved'),
                  //       ),
                  //     );
                  //   },
                  // ),
                ],
              ),
            ),
          ) // ),
          );
    }
  }

  TextEditingController editingController = TextEditingController();
  Widget listTest() {
    return Container(
      height: 200,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _todoList.length,
        itemBuilder: (context, index) {
          return CheckboxListTile(
            value: _todoList[index].completed,
            title: Text(
              _todoList[index].title,
              style: _todoList[index].completed
                  ? TextStyle(decoration: TextDecoration.lineThrough)
                  : TextStyle(decoration: TextDecoration.none),
            ),
            onChanged: (value) => setState(
              () => _todoList[index].completed = value,
            ),
          );
        },
      ),
    );
  }

  Widget buildCurrentPath(BuildContext context) {
    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: RepaintBoundary(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(4.0),
          color: Colors.transparent,
          alignment: Alignment.topLeft,
          child: StreamBuilder<DrawnLine>(
            stream: currentLineStreamController.stream,
            builder: (context, snapshot) {
              return CustomPaint(
                painter: Sketcher(
                  lines: [line],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildAllPaths(BuildContext context) {
    return RepaintBoundary(
      key: _globalKey,
      child: Screenshot(
        controller: screenshotController,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.transparent,
          padding: EdgeInsets.all(4.0),
          alignment: Alignment.topLeft,
          child: StreamBuilder<List<DrawnLine>>(
            stream: linesStreamController.stream,
            builder: (context, snapshot) {
              return CustomPaint(
                painter: Sketcher(
                  lines: lines,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void onPanStart(DragStartDetails details) {
    RenderBox box = context.findRenderObject();
    Offset point = box.globalToLocal(details.localPosition);
    line = DrawnLine([point], selectedColor, selectedWidth);
  }

  void onPanUpdate(DragUpdateDetails details) {
    RenderBox box = context.findRenderObject();
    Offset point = box.globalToLocal(details.localPosition);

    List<Offset> path = List.from(line.path)..add(point);
    line = DrawnLine(path, selectedColor, selectedWidth);
    currentLineStreamController.add(line);
  }

  void onPanEnd(DragEndDetails details) {
    lines = List.from(lines)..add(line);

    linesStreamController.add(lines);
  }

  Widget buildStrokeToolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildStrokeButton(5.0),
        buildStrokeButton(10.0),
        buildStrokeButton(15.0),
      ],
    );
  }

  Widget buildStrokeButton(double strokeWidth) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedWidth = strokeWidth;
          Navigator.pop(context);
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          width: strokeWidth * 2,
          height: strokeWidth * 2,
          decoration: BoxDecoration(
              color: selectedColor, borderRadius: BorderRadius.circular(50.0)),
        ),
      ),
    );
  }

  Widget buildColorToolbar() {
    return Positioned(
      top: 40.0,
      right: 2.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildColorButton(Colors.red),
          buildColorButton(Colors.blueAccent),
          buildColorButton(Colors.deepOrange),
          buildColorButton(Colors.green),
          buildColorButton(Colors.lightBlue),
          buildColorButton(Colors.black),
          buildColorButton(Colors.white),
        ],
      ),
    );
  }

  Widget buildColorButton(Color color) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        height: 35,
        child: FloatingActionButton(
          mini: true,
          backgroundColor: color,
          child: Container(),
          onPressed: () {
            setState(() {
              selectedColor = color;
            });
          },
        ),
      ),
    );
  }

  Widget buildSaveButton() {
    return GestureDetector(
      onTap: save,
      child: CircleAvatar(
        child: Icon(
          Icons.save,
          size: 20.0,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildClearButton() {
    return GestureDetector(
      onTap: clear,
      child: CircleAvatar(
        child: Icon(
          Icons.create,
          size: 20.0,
          color: Colors.white,
        ),
      ),
    );
  }
}

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
