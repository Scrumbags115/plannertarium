import 'package:planner/common/database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class eventView extends StatefulWidget {
  const eventView({super.key});

  @override
  eventViewState createState() => eventViewState();
}

class eventViewState extends State<eventView> {
  TextEditingController titleE = TextEditingController();
  TextEditingController descriptionE = TextEditingController();
  TextEditingController dateE = TextEditingController();
  TextEditingController timeE = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  String userName = '';
  List<TaskEvent> events = [];
  DatabaseService db = DatabaseService(uid: "ian");

  @override
  void initState() {
    super.initState();
    fetchUserName();
    //fetchTodayEvents();
  }

  void fetchUserName() {
    FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user?.email)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        setState(() {
          userName = doc['name'];
        });
      }
    });
  }

  // void fetchTodayEvents() {
  //   final now = DateTime.now();
  //   final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
  //   final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

  //   db
  //       .getUserEventsInDateRange(dateStart: startOfDay, dateEnd: endOfDay)
  //       .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
  //     final List<TaskEvent> todayEvents = [];
  //     querySnapshot.docs.forEach((doc) {
  //       todayEvents.add(TaskEvent.fromMap(doc.data()));
  //     });
  //     setState(() {
  //       events = todayEvents;
  //     });
  //   });
  // }

  void addButtonForm(BuildContext context) {
    TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Text'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: textController,
                decoration: const InputDecoration(labelText: 'Enter Text'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                String enteredText = textController.text;
                // Handle the entered text (e.g., save it or use it in your app).
                Navigator.of(context).pop();
              },
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
          title: const Text('Search'),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Enter your search query',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Search'),
              onPressed: () {
                String searchQuery = searchController.text;
                // Handle the search query as needed (e.g., perform a search operation).
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  var scaffoldKey = GlobalKey<ScaffoldState>();
  @override
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
          title: Text(userName),
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
                    "Abhishek Mishra",
                    style: TextStyle(fontSize: 18),
                  ),
                  accountEmail: Text("abhishekm977@gmail.com"),
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
                leading: const Icon(Icons.book),
                title: const Text(' My Course '),
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
                leading: const Icon(Icons.video_label),
                title: const Text(' Saved Videos '),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text(' Edit Profile '),
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
        body: ListView(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: TaskEventCard(
                  event: TaskEvent(
                    title: 'Sample Task',
                    description: 'This is a sample task description',
                    startTime: DateTime.now(),
                    endTime: DateTime.now().add(const Duration(hours: 1)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: TaskEventCard(
                event: TaskEvent(
                  title: 'Sample Task',
                  description: 'This is a sample task description',
                  startTime: DateTime.now(),
                  endTime: DateTime.now().add(const Duration(hours: 1)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ClipOval(
                  child: ElevatedButton(
                    onPressed: () {
                      addButtonForm(context);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(75, 75),
                    ),
                    child: const Icon(Icons.add_outlined),
                  ),
                ),
              ),
            ),
          ],
        ));
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

  const TaskEventCard({super.key, required this.event});

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
