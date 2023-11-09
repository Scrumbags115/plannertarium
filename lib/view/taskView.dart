import 'package:planner/common/database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:planner/view/weekView.dart';
import 'package:planner/models/task.dart';
import 'package:planner/models/task.dart';

class taskView extends StatefulWidget {
  const taskView({Key? key}) : super(key: key);

  @override
  _taskViewState createState() => _taskViewState();
}

class _taskViewState extends State<taskView> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  DatabaseService db = DatabaseService(uid: "ian");

  @override
  void initState() {
    super.initState();
  }

  void fetchTodayTasks() async {
    DateTime today = DateTime.now();
    DateTime dateStart = DateTime(today.year, today.month, today.day);
    DateTime dateEnd = dateStart.add(Duration(days: 1));
    Map<DateTime, List<Task>> activeMap, delayedMap, completedMap;
    (activeMap, delayedMap, completedMap) =
        await db.getTaskMaps(dateStart, dateEnd);
  }
  
  void _showTaskDetailsDialog(Task task) {
    showDialog(
      context: scaffoldKey.currentState!.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Task Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${task.name}'),
              Text('Description: ${task.description}'),
              // Add more details as needed
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert box
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showTaskNotFoundDialog() {
    showDialog(
      context: scaffoldKey.currentState!.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Task Not Found'),
          content: Text('The task with ID was not found.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  void showSearchBar(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Search Tasks'),
          content: TextField(
            controller: searchController,
            decoration: InputDecoration(),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Search'),
              onPressed: () async {
                String searchQuery = searchController.text;
                Task task = await db.getTask(searchQuery);

                if (task.id != null) {
                  // If the task is found, show an alert box with its details
                  _showTaskDetailsDialog(task);
                } else {
                  // If the task is not found, show an alert box indicating it
                  _showTaskNotFoundDialog();
                }
              },
            ),
          ],
        );
      },
    );
  }

  var scaffoldKey = GlobalKey<ScaffoldState>();

  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text('Task'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearchBar(context);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ), //BoxDecoration
              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.green),
                accountName: Text(
                  "Cheng Wai",
                  style: TextStyle(fontSize: 18),
                ),
                accountEmail: Text("cchong10@ucsc.edu"),
                currentAccountPictureSize: Size.square(50),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 165, 255, 137),
                  child: Text(
                    "A",
                    style: TextStyle(fontSize: 30.0, color: Colors.blue),
                  ), //Text
                ), //circleAvatar
              ), //UserAccountDrawerHeader
            ), //DrawerHeader
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text(' My Profile '),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.workspace_premium),
              title: const Text(' Go Premium '),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text(' Settings '),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('LogOut'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TaskEvent {
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;

  TaskEvent({
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
  });

  factory TaskEvent.fromMap(Map<String, dynamic> data) {
    return TaskEvent(
      title: data['title'],
      description: data['description'],
      startTime: (data['event time start'] as Timestamp).toDate(),
      endTime: (data['event time end'] as Timestamp).toDate(),
    );
  }
}

class TaskEventCard extends StatefulWidget {
  final TaskEvent event;

  TaskEventCard({required this.event});

  @override
  _TaskEventCardState createState() => _TaskEventCardState();
}

class _TaskEventCardState extends State<TaskEventCard> {
  bool isCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(1.0),
      child: InkWell(
        onTap: () {
          _showDetailPopup(context);
        },
        child: ListTile(
          leading: InkWell(
            onTap: () {
              setState(() {
                isCompleted = !isCompleted;
              });
            },
            child: CircleAvatar(
              backgroundColor: isCompleted ? Colors.green : Colors.blue,
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white)
                  : const Icon(Icons.circle, color: Colors.white),
            ),
          ),
          title: Text(widget.event.title),
          subtitle: Text(widget.event.description),
          trailing: Text(
            '${widget.event.startTime.hour}:${widget.event.startTime.minute} - ${widget.event.endTime.hour}:${widget.event.endTime.minute}',
          ),
        ),
      ),
    );
  }

  void _showDetailPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Task Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Title: ${widget.event.title}'),
              Text('Description: ${widget.event.description}'),
              Text(
                'Time: ${widget.event.startTime.hour}:${widget.event.startTime.minute} - ${widget.event.endTime.hour}:${widget.event.endTime.minute}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            )
          ],
        );
      },
    );
  }
}
