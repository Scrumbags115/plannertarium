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

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
          title: Text(userName),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
                child: ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return TaskEventCard(event: events[index]);
                    })),
            ElevatedButton(
                onPressed: (){

                },
                child: Text("Add Task"),
            )
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                child: Text("Tasks Events"),
              ),
              for(var event in events)
                ListTile(
                  title: Text(event.title),
                  subtitle: Text(event.description),
                  onTap: (){

                  }
                )
            ],
          ),
        )

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
