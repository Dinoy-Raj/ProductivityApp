import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:app/screens/projects/project_edits.dart';
import 'package:app/screens/projects/projectscreen.dart';
import 'package:app/screens/projects/assign_edit_task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'group_voice_call.dart';

class ProjectManagement extends StatefulWidget {
  ProjectManagement({this.project});

  final Project? project;

  @override
  State<StatefulWidget> createState() {
    return _ProjectState(project: project);
  }
}

class _ProjectState extends State<ProjectManagement> {
  _ProjectState({this.project});
  User _user = FirebaseAuth.instance.currentUser!;
  final Project? project;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  double _progress = 0;
  bool _progressClicked = false;
  bool _loading = true;
  bool isCallLive = false;
  List myTasks = [];
  List collabTasks = [];

  listenDB() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(project!.owner!['uid'])
        .collection("owned_projects")
        .doc(project!.id)
        .collection("tasks")
        .snapshots()
        .listen((event) {
      if (event.docs.isEmpty && mounted)
        setState(() {
          _loading = false;
        });
      event.docChanges.forEach((element) {
        if (element.type == DocumentChangeType.added) {
          String deadline;
          Duration? duration = element.doc.get('deadline') != null
              ? element.doc.get('deadline').toDate().difference(DateTime.now())
              : null;

          if (element.doc.get('completed')) deadline = "Completed";
          if (element.doc.get('deadline') == null)
            deadline = "No Deadline";
          else if (duration!.isNegative)
            deadline = "Past Deadline";
          else if (duration.inMinutes <= 24 * 60)
            deadline = "Today";
          else if (duration.inMinutes <= 48 * 60)
            deadline = "Tomorrow";
          else
            deadline = DateFormat.yMEd()
                .add_jms()
                .format(element.doc.get('deadline').toDate());

          if (mounted)
            setState(() {
              if (element.doc.get('collab')['uid'] == _user.uid) {
                myTasks.add({
                  'title': element.doc.get('title'),
                  'body': element.doc.get('body'),
                  'datetime': element.doc.get('deadline') == null
                      ? null
                      : element.doc.get('deadline').toDate(),
                  'deadline': deadline,
                  'completed': element.doc.get('completed'),
                  'collab': element.doc.get('collab'),
                  'id': element.doc.id,
                });
              } else {
                collabTasks.add({
                  'title': element.doc.get('title'),
                  'body': element.doc.get('body'),
                  'datetime': element.doc.get('deadline') == null
                      ? null
                      : element.doc.get('deadline').toDate(),
                  'deadline': deadline,
                  'completed': element.doc.get('completed'),
                  'collab': element.doc.get('collab'),
                  'id': element.doc.id,
                });
              }
              _loading = false;
            });
        } else if (element.type == DocumentChangeType.modified) {
          String deadline;
          Duration? duration = element.doc.get('deadline') != null
              ? element.doc.get('deadline').toDate().difference(DateTime.now())
              : null;

          if (element.doc.get('completed')) deadline = "Completed";
          if (element.doc.get('deadline') == null)
            deadline = "No Deadline";
          else if (duration!.isNegative)
            deadline = "Past Deadline";
          else if (duration.inMinutes <= 24 * 60)
            deadline = "Today";
          else if (duration.inMinutes <= 48 * 60)
            deadline = "Tomorrow";
          else
            deadline = DateFormat.yMEd()
                .add_jms()
                .format(element.doc.get('deadline').toDate());

          if (mounted)
            setState(() {
              if (element.doc.get('collab')['uid'] == _user.uid) {
                myTasks.forEach((task) {
                  if (task['id'] == element.doc.id) {
                    task['title'] = element.doc.get('title');
                    task['body'] = element.doc.get('body');
                    task['datetime'] = element.doc.get('deadline') == null
                        ? null
                        : element.doc.get('deadline').toDate();
                    task['deadline'] = deadline;
                    task['completed'] = element.doc.get('completed');
                  }
                });
              } else {
                collabTasks.forEach((task) {
                  if (task['id'] == element.doc.id) {
                    task['title'] = element.doc.get('title');
                    task['body'] = element.doc.get('body');
                    task['datetime'] = element.doc.get('deadline') == null
                        ? null
                        : element.doc.get('deadline').toDate();
                    task['deadline'] = deadline;
                    task['completed'] = element.doc.get('completed');
                  }
                });
              }
            });
        } else {
          if (mounted)
            setState(() {
              if (element.doc.get('collab')['uid'] == _user.uid) {
                Map? task;
                for (task in myTasks) {
                  if (element.doc.id == task!['id']) break;
                }
                myTasks.remove(task);
              } else {
                Map? task;
                for (task in collabTasks) {
                  if (element.doc.id == task!['id']) break;
                }
                collabTasks.remove(task);
              }
            });
        }
      });
    });
  }

  viewTask(Map<String, dynamic> task) {
    String deadline;
    Color color;
    IconData icon;

    if (task['completed']) {
      deadline = "This task is completed";
      icon = Icons.assignment_turned_in_outlined;
      color = Colors.greenAccent;
    } else if (task['deadline'] == "Today") {
      deadline = "This task is due today";
      icon = Icons.assignment_late_outlined;
      color = Colors.orange;
    } else if (task['deadline'] == "Tomorrow") {
      deadline = "This task is due tomorrow";
      icon = Icons.assignment_late_outlined;
      color = Colors.orange[300]!;
    } else if (task['deadline'] == "Past Deadline") {
      deadline = "This task is late";
      icon = Icons.assignment_late;
      color = Colors.red;
    } else if (task['deadline'] == "No Deadline") {
      deadline = "This task has no deadline";
      icon = Icons.assignment_outlined;
      color = Colors.green;
    } else {
      deadline = "This task is due " + task['deadline'];
      icon = Icons.assignment_outlined;
      color = Colors.brown;
    }
    showDialog(
        context: context,
        builder: (context) => Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            icon,
                            color: color,
                          ),
                          Text(
                            deadline,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontSize: 18,
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ]),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            task['title'],
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800]),
                          ),
                        ),
                      ),
                      if (task['collab']['uid'] != _user.uid)
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                                height: 50,
                                child: Image.network(task['collab']['image'])),
                          ),
                        )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Text(
                      task['body'],
                      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (project!.owner!['uid'] == _user.uid)
                        OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              showDialog(
                                  context: context,
                                  builder: (context) => AssignEditTask(
                                        projectID: project!.id,
                                        ownerUID: project!.owner!['uid'],
                                        task: task,
                                      ));
                            },
                            child: Text(
                              "Edit",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800]),
                            )),
                      if (task['collab']['uid'] == _user.uid)
                        OutlinedButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(project!.owner!['uid'])
                                  .collection("owned_projects")
                                  .doc(project!.id)
                                  .collection("tasks")
                                  .doc(task['id'])
                                  .update({'completed': !task['completed']});
                              Navigator.pop(context);
                            },
                            child: Text(
                              task['completed'] ? "Reopen" : "Completed",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: task['completed']
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            )),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ));
  }

  @override
  void initState() {
    super.initState();
    listenDB();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
          _progressClicked = false;
        }
      },
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(project!.owner!['uid'])
              .collection("owned_projects")
              .doc(project!.id)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData || snapshot.hasError)
              return Scaffold(
                  body: Center(child: CupertinoActivityIndicator()));

            if (snapshot.data!.exists) {
              project!.title = snapshot.data!.get('title');
              project!.type = snapshot.data!.get('type');
              project!.body = snapshot.data!.get('body');
              project!.collab = snapshot.data!.get('collab');
              try {
                _progress = snapshot.data!.get('progress');
              } catch (e) {}
            }

            return Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.white10,
                centerTitle: true,
                leading: IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Tooltip(
                      message: "Exit",
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.grey[700],
                      ),
                    )),
                actions: [
                  IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () {
                      if (!isCallLive)
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text(
                                      "Start a voice call with the collaborators?"),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          "NO",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          setState(() {
                                            isCallLive = true;
                                          });
                                          showModalBottomSheet(
                                              context: context,
                                              builder: (context) {
                                                return Agora();
                                              });
                                        },
                                        child: Text(
                                          "YES",
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )),
                                  ],
                                ));
                      else
                        showModalBottomSheet(
                            context: context, builder: (context) => Agora());
                    },
                    icon: Tooltip(
                      message: "Make call",
                      child: Icon(
                        isCallLive ? Icons.phone_callback : Icons.add_call,
                        color: isCallLive ? Colors.green : Colors.grey[700],
                      ),
                    ),
                  ),
                  IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () {},
                    icon: Tooltip(
                      message: "Group chat",
                      child: Icon(
                        Icons.chat,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () {
                      _scaffoldKey.currentState!.openEndDrawer();
                    },
                    icon: Tooltip(
                      message: "Collaborators",
                      child: Icon(
                        Icons.people,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  )
                ],
              ),
              endDrawer: Drawer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 120,
                      child: DrawerHeader(
                        child: Text(
                          "Collaborators",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ExpansionTile(
                        textColor: Colors.black,
                        iconColor: Colors.black,
                        leading: Container(
                          decoration: BoxDecoration(
                              color: Colors.yellowAccent,
                              borderRadius: BorderRadius.circular(30)),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.network(project!.owner!['image']),
                            ),
                          ),
                        ),
                        title: Text(project!.owner!['uid'] == _user.uid
                            ? project!.owner!['name'] + " (You)"
                            : project!.owner!['name']),
                        subtitle: Text(
                          project!.owner!['email'],
                          style: TextStyle(fontSize: 12),
                        ),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton.icon(
                                label: Text(
                                  project!.owner!['uid'] == _user.uid
                                      ? "Note"
                                      : "Chat",
                                ),
                                icon: Icon(
                                  project!.owner!['uid'] == _user.uid
                                      ? Icons.edit_outlined
                                      : Icons.chat_bubble_outline,
                                  color: Colors.grey[800],
                                ),
                                style: ButtonStyle(
                                    foregroundColor: MaterialStateProperty.all(
                                        Colors.grey[800]),
                                    overlayColor: MaterialStateProperty.all(
                                        Colors.transparent)),
                                onPressed: () {
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (context) => Container(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(15),
                                                  child: Text(
                                                    project!.owner!['uid'] ==
                                                            _user.uid
                                                        ? "Note"
                                                        : "Chat",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ));
                                },
                              ),
                              if (project!.owner!['uid'] == _user.uid)
                                TextButton.icon(
                                  icon: Icon(Icons.add_comment_outlined),
                                  label: Text("Assign"),
                                  style: ButtonStyle(
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Colors.grey[800]),
                                      overlayColor: MaterialStateProperty.all(
                                          Colors.transparent)),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) => AssignEditTask(
                                              projectID: project!.id,
                                              ownerUID: project!.owner!['uid'],
                                            ));
                                  },
                                ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.only(top: 0),
                        itemCount: project!.collab!.length,
                        itemBuilder: (context, index) => ExpansionTile(
                          textColor: Colors.black,
                          iconColor: Colors.black,
                          leading: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.network(
                                  project!.collab![index]['image']),
                            ),
                          ),
                          title: Text(
                              project!.collab![index]['uid'] == _user.uid
                                  ? project!.collab![index]['name'] + " (You)"
                                  : project!.collab![index]['name']),
                          subtitle: Text(
                            project!.collab![index]['email'],
                            style: TextStyle(fontSize: 12),
                          ),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton.icon(
                                  label: Text(
                                    project!.collab![index]['uid'] == _user.uid
                                        ? "Note"
                                        : "Chat",
                                  ),
                                  icon: Icon(
                                    project!.collab![index]['uid'] == _user.uid
                                        ? Icons.edit_outlined
                                        : Icons.chat_bubble_outline,
                                  ),
                                  style: ButtonStyle(
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Colors.grey[800]),
                                      overlayColor: MaterialStateProperty.all(
                                          Colors.transparent)),
                                  onPressed: () {
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (context) => Container(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15),
                                                    child: Text(
                                                      project!.collab![index]
                                                                  ['uid'] ==
                                                              _user.uid
                                                          ? "Note"
                                                          : "Chat",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ));
                                  },
                                ),
                                if (project!.owner!['uid'] == _user.uid)
                                  TextButton.icon(
                                    icon: Icon(Icons.add_comment_outlined),
                                    label: Text("Assign"),
                                    style: ButtonStyle(
                                        foregroundColor:
                                            MaterialStateProperty.all(
                                                Colors.grey[800]),
                                        overlayColor: MaterialStateProperty.all(
                                            Colors.transparent)),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) => AssignEditTask(
                                                projectID: project!.id,
                                                ownerUID:
                                                    project!.owner!['uid'],
                                                collaborator: project!
                                                                .collab![index]
                                                            ['uid'] ==
                                                        _user.uid
                                                    ? null
                                                    : project!.collab![index],
                                              ));
                                    },
                                  ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButton: project!.owner!['uid'] == _user.uid
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: NeumorphicFloatingActionButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProjectEditing(
                                        project: project,
                                      )));
                        },
                        child: Tooltip(
                          message: "Edit Project",
                          child: Icon(
                            Icons.edit,
                          ),
                        ),
                      ))
                  : null,
              body: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 8, bottom: 8),
                              child: Text(
                                project!.title!,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[900],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[700],
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: Text(
                                  project!.type!,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.grey[700]!)),
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            project!.body!,
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[700]),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 8, top: 20, bottom: 8),
                        child: Row(
                          children: [
                            Text(
                              "Progress",
                              style: TextStyle(fontSize: 20),
                            ),
                            if (project!.owner!['uid'] == _user.uid &&
                                !_progressClicked)
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _progressClicked = true;
                                  });
                                },
                                icon: Icon(Icons.edit_outlined),
                                iconSize: 16,
                                splashRadius: 16,
                              ),
                            if (_progressClicked)
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Container(
                                  width: 60,
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.only(left: 5, right: 5),
                                      hintText: "%",
                                      hintStyle: TextStyle(fontSize: 16),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.transparent,
                                      )),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                        color: Colors.transparent,
                                      )),
                                    ),
                                    onSubmitted: (val) {
                                      setState(() {
                                        _progressClicked = false;
                                        try {
                                          _progress = double.parse(val) / 100;
                                          FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(_user.uid)
                                              .collection("owned_projects")
                                              .doc(project!.id)
                                              .set({'progress': _progress},
                                                  SetOptions(merge: true));
                                        } catch (e) {}
                                      });
                                    },
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                      NeumorphicProgress(
                        percent: _progress,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8, top: 40),
                        child: Text(
                          "Your Tasks",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      if (_loading)
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: CupertinoActivityIndicator(),
                        )
                      else if (myTasks.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, top: 10, bottom: 30),
                          child: Text(
                            "You currently have no tasks",
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[700]),
                          ),
                        )
                      else
                        Container(
                          height: 200,
                          child: GridView.builder(
                              physics: BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 1),
                              itemCount: myTasks.length,
                              itemBuilder: (context, index) {
                                Color color;
                                if (myTasks[index]['completed'])
                                  color = Colors.grey;
                                else if (myTasks[index]['deadline'] == "Today")
                                  color = Colors.orange;
                                else if (myTasks[index]['deadline'] ==
                                    "Tomorrow")
                                  color = Colors.orange[300]!;
                                else if (myTasks[index]['deadline'] ==
                                    "Past Deadline")
                                  color = Colors.red;
                                else if (myTasks[index]['deadline'] ==
                                    "No Deadline")
                                  color = Colors.green;
                                else
                                  color = Colors.brown;
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 5, top: 10, bottom: 40),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 300,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: myTasks[index]['completed']
                                                ? color.withOpacity(0.25)
                                                : Colors.white,
                                            border: Border.all(
                                                color: color, width: 2)),
                                        child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Container(
                                                height: 5,
                                                width: 15,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  shape: BoxShape.rectangle,
                                                  color: color,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 8,
                                              ),
                                              Expanded(
                                                flex: 0,
                                                child: Text(
                                                  myTasks[index]['title']!,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Text(
                                                myTasks[index]['deadline'],
                                                overflow: TextOverflow.clip,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[700]),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  myTasks[index]['body']!,
                                                  overflow: TextOverflow.clip,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          splashColor: color.withOpacity(0.5),
                                          highlightColor:
                                              color.withOpacity(0.25),
                                          onTap: () {
                                            viewTask(myTasks[index]);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        ),
                      Padding(
                        padding: EdgeInsets.only(left: 8, top: 0),
                        child: Text(
                          "Other Tasks",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      if (_loading)
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: CupertinoActivityIndicator(),
                        )
                      else if (collabTasks.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, top: 10, bottom: 30),
                          child: Text(
                            project!.owner!['uid'] == _user.uid
                                ? "Assign tasks for the collaborators"
                                : "There are no tasks here",
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[700]),
                          ),
                        )
                      else
                        Container(
                          height: 200,
                          child: GridView.builder(
                              physics: BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 1),
                              itemCount: collabTasks.length,
                              itemBuilder: (context, index) {
                                Color color;
                                if (collabTasks[index]['completed'])
                                  color = Colors.grey;
                                else if (collabTasks[index]['deadline'] ==
                                    "Today")
                                  color = Colors.orange;
                                else if (collabTasks[index]['deadline'] ==
                                    "Tomorrow")
                                  color = Colors.orange[200]!;
                                else if (collabTasks[index]['deadline'] ==
                                    "Past Deadline")
                                  color = Colors.red;
                                else if (collabTasks[index]['deadline'] ==
                                    "No Deadline")
                                  color = Colors.red;
                                else
                                  color = Colors.brown;
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 5, top: 20, bottom: 40),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 300,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: collabTasks[index]
                                                    ['completed']
                                                ? color.withOpacity(0.25)
                                                : Colors.white,
                                            border: Border.all(
                                                color: color, width: 2)),
                                        child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                height: 5,
                                                width: 15,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  shape: BoxShape.rectangle,
                                                  color: color,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 8,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      collabTasks[index]
                                                          ['title'],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Container(
                                                    height: 30,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      child: Image.network(
                                                          collabTasks[index]
                                                                  ['collab']
                                                              ['image']),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height: 3,
                                              ),
                                              Text(
                                                collabTasks[index]['deadline'],
                                                overflow: TextOverflow.clip,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[700]),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  collabTasks[index]['body'],
                                                  overflow: TextOverflow.clip,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          splashColor: color.withOpacity(0.5),
                                          highlightColor:
                                              color.withOpacity(0.25),
                                          onTap: () {
                                            viewTask(collabTasks[index]);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
