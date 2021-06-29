import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ProjectEditing extends StatefulWidget {
  const ProjectEditing({Key? key}) : super(key: key);

  @override
  _ProjectEditingState createState() => _ProjectEditingState();
}

class _ProjectEditingState extends State<ProjectEditing> {
  Future<void> updateData() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection("projects")
        .doc()
        .set({"body": _bodyController.text, "title": _titleController.text},
            SetOptions(merge: false));
  }

  TextEditingController _titleController = TextEditingController();
  TextEditingController _bodyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white10,
        leading: IconButton(
            splashRadius: .5,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Tooltip(
              message: "Exit Without Saving",
              child: Icon(
                Icons.cancel,
                color: Colors.black,
              ),
            )),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "Add Notes",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
            ),
            Container(
              width: screenWidth,
              height: screenHeight * .2,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 25, right: 15, top: 8, bottom: 8),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (String? value) {
                        return value == null || value.trim().isEmpty
                            ? "Title cannot be empty"
                            : null;
                      },
                      controller: _titleController,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      decoration: InputDecoration(
                        hintText: "Title",
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                    )),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.1),
                        blurRadius: 100,
                        spreadRadius: 2,
                        offset: Offset(0, 3),
                      ),
                    ]
                    //borderRadius: BorderRadius.circular(10),
                    ),
                width: screenWidth,
                height: screenHeight * .8,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 25, right: 15, top: 8, bottom: 8),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: TextFormField(
                        maxLines: 10,
                        controller: _bodyController,
                        textCapitalization: TextCapitalization.sentences,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (String? value) {
                          return value == null || value.trim().isEmpty
                              ? "Title cannot be empty"
                              : null;
                        },
                        style: TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                          hintText: "Content",
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                      )),
                ),
              ),
            ),
            SizedBox(
              height: screenHeight * .15,
            ),
            Container(
              height: 40,
              width: screenWidth * .4,
              child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                  ),
                  onPressed: () {
                    if (_titleController.text.trim().isNotEmpty &&
                        _bodyController.text.trim().isNotEmpty) {
                      updateData();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    "Add Note",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )),
            ),
            SizedBox(
              height: screenHeight * .3,
            )
          ],
        ),
      ),
    );
  }
}
