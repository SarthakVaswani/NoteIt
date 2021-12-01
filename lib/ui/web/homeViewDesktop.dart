import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/service/auth.dart';
import 'package:notes_app/ui/screenDecider.dart';
import 'package:transition/transition.dart';
import '../noteview/addNote.dart';
import '../noteview/edtNote.dart';

class HomeViewDesktop extends StatefulWidget {
  @override
  _HomeViewDesktopState createState() => _HomeViewDesktopState();
}

class _HomeViewDesktopState extends State<HomeViewDesktop> {
  final _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scrollbar(
        thickness: 10,
        showTrackOnHover: true,
        controller: _scrollController,
        isAlwaysShown: true,
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 27),
                    child: IconButton(
                      icon: Icon(
                        Icons.logout,
                        size: 40,
                      ),
                      onPressed: () async {
                        Navigator.pop(context, true);
                        bool shouldNavigate = await logOut();
                        if (shouldNavigate) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AuthDecider()));
                        }
                      },
                    ),
                  ),
                  // IconButton(
                  //     icon: Icon(Icons.web_asset),
                  //     onPressed: () {
                  //       _launchURL();
                  //     }),
                ],
                elevation: 0,
                automaticallyImplyLeading: false,
                backgroundColor: Color(0xff2c2b4b),
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.symmetric(horizontal: 15),
                  title: Text(
                    'Notes',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ];
          },
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Color(0xff2c2b4b),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Users')
                        .doc(FirebaseAuth.instance.currentUser.uid)
                        .collection('Notes')
                        .orderBy('dateTime', descending: true)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return GridView.builder(
                        physics: ScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5),
                        itemCount:
                            snapshot.hasData ? snapshot.data.docs.length : 0,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  Transition(
                                      child: EditNote(
                                          docToEdit: snapshot.data.docs[index]),
                                      transitionEffect: TransitionEffect.FADE)
                                  // MaterialPageRoute(
                                  //   builder: (context) => EditNote(
                                  //     docToEdit: snapshot.data.docs[index],
                                  //   ),
                                  // ),
                                  );
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                    // side: BorderSide(
                                    //     color: Colors.white, width: 0.01),
                                    borderRadius: BorderRadius.circular(10)),
                                margin: EdgeInsets.all(10),
                                color: Color(0xffddf0f7),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 10),
                                        child: Text(
                                          snapshot.data.docs[index]
                                              .data()["title"],
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 25),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Container(
                                          child: Text(
                                            snapshot.data.docs[index]
                                                .data()["content"],
                                            style: TextStyle(
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                                fontSize: 19),
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xffeb6765),
        onPressed: () {
          Navigator.push(
            context,
            Transition(
                child: AddNote(), transitionEffect: TransitionEffect.FADE),
          );
        },
        child: Icon(
          Icons.edit,
          color: Colors.white,
        ),
      ),
    );
  }
}
