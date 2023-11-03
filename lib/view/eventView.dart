import 'package:planner/common/database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

class eventView extends StatefulWidget {
  const eventView({Key? key}) : super(key: key);

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
  DatabaseService db = DatabaseService(uid: "test_user_1");

  @override
  void initState() {
    super.initState();
    fetchUserName();
    fetchTodayEvents();
  }

  void fetchUserName() {
    FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user?.email)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          userName = doc['name'];
        });
      });
    });
  }

  void fetchTodayEvents() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    db
        .getUserEventsInDateRange(dateStart: startOfDay, dateEnd: endOfDay)
        .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      final List<TaskEvent> todayEvents = [];
      querySnapshot.docs.forEach((doc) {
        todayEvents.add(TaskEvent.fromMap(doc.data()));
      });
      setState(() {
        events = todayEvents;
      });
    });
  }


  @override
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
          title: Text(userName),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {

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
      body: Stack(
        children: [
          Positioned(
            bottom: 25,
            right: 25,
            child: ClipOval(
              child: ElevatedButton(
                onPressed: (){

                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(75,75),
                ),
                child: const Icon(Icons.add_outlined),
              ),
            )
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TaskEventCard(
              event: TaskEvent(
                title: 'Sample Task',
                description: 'This is a sample task description.',
                startTime: DateTime.now(),
                endTime: DateTime.now().add(Duration(hours: 1)),
              )
            ),
          )
        ],
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

class TaskEventCard extends StatelessWidget {
  final TaskEvent event;

  TaskEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(event.title),
        subtitle: Text(event.description),
        trailing: Text(
          '${event.startTime.hour}:${event.startTime.minute} - ${event.endTime.hour}:${event.endTime.minute}',
        ),
      ),
    );
  }
}
