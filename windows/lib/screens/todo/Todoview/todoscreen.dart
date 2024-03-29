
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:windows/screens/todo/TodoEdit/todo_edits.dart';
import 'package:windows/screens/todo/Todoview/todo_griddataview.dart';

class PersonalScreen extends StatefulWidget {
  const PersonalScreen({Key? key}) : super(key: key);

  @override
  _PersonalScreenState createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        // physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(
              left: screenWidth * .0277,
              right: screenWidth * .0277,
              top: screenHeight * .08 > 60 ? screenHeight * .08 : 60),
          child: Container(
            width: screenWidth,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left:
                            screenWidth * .055 > 20 ? screenWidth * .055 : 20),
                    child: Container(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Your\nTodo",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 40),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left:
                            screenWidth * .055 > 20 ? screenWidth * .055 : 20),
                    child: Container(
                      width: screenWidth,
                      height: 20,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Add and edit your todo tasks",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: screenWidth * .055 > 20 ? screenWidth * .055 : 20,
                      right: screenWidth * .055 > 20 ? screenWidth * .055 : 20),
                  child: Container(
                    height: 100,
                    width: screenWidth,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.1),
                            blurRadius: 80,
                            spreadRadius: 2,
                            offset: Offset(0, 3),
                          ),
                        ]
                        //borderRadius: BorderRadius.circular(10),
                        ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          child: Lottie.network(
                              "https://assets3.lottiefiles.com/packages/lf20_jy1bgnpp.json"),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Have A New One?",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            Text(
                              "Add New Todo   ->",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => TodoEdits()));
                            },
                            icon: Icon(Icons.add),
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                    height:
                        screenHeight * .473 > 360 ? screenHeight * .473 : 360,
                    child: ListViewTodo()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
