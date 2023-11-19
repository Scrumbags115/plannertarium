
import 'package:planner/common/login.dart';
import 'package:planner/common/recurrence.dart';
import 'package:planner/models/event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:planner/common/database.dart';
import 'package:planner/view/eventView.dart';
import 'package:planner/common/canvas.dart';

var auth = FirebaseAuth.instanceFor(
    app: Firebase.app(), persistence: Persistence.LOCAL);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: 'AIzaSyBwR4cKdPaa5c7p0fMLcAgu-VL8w3L3IUs',
        appId: '1:86325497409:android:85586ccfa7c01ea29cc0c0',
        messagingSenderId: '86325497409',
        projectId: 'plannertarium-d1696'),
  );
  await auth.setPersistence(Persistence.LOCAL);
  runApp(const eventView());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final List<String> _toDoItems = [];
  final TextEditingController _controller = TextEditingController();

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();


    // Start listening to changes.
    _controller.addListener(_printLatestValue);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    _controller.dispose();
    super.dispose();
  }

  void _printLatestValue() {
    final text = _controller.text;
    print('Second text field: $text (${text.characters.length})');
  }

  void _addToDoItem(String event) {
    if (event.isNotEmpty) {
      setState(() {
        _toDoItems.add(event);
      });
    }
    runTest(event);
  }

  void runTest(String event) async {
    FirebaseAuth.instance.userChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
    User? u = await runAuthFlow();
    DatabaseService db = DatabaseService();
    db.initUID(u!.uid);
    if (event == "login") {
      await runAuthFlow();
    } else if (event == "logout") {
      await logout();
    } else if (event == "run") {
      print(db);
      print("do crap");
      db.initUID("random test string");

      DatabaseService db2 = DatabaseService();

      print(db);
      print("done doing crap");
    } else if (event == "add") {
      final timeStart = DateTime.now();
      final timeEnd = timeStart.add(const Duration(hours: 8));
      await db.addEvent(Event(
          name: "example_event_name_2",
          tags: ["example_event_tag1"],
          timeStart: timeStart,
          timeEnd: timeEnd));
      return;
    } else if (event == "get range") {
      final dateStart = DateTime.parse("2023-11-20");
      final dateEnd = dateStart.add(const Duration(days: 8));
      final userEventMap = await db.getEventsInDateRange(
          dateStart: dateStart, dateEnd: dateEnd);
      print(userEventMap);

      userEventMap.forEach((key, value) {
        print(key + value.toString());
      });
      return;
    } else if (event =="recur") {
      Recurrence recurrenceRules = Recurrence(enabled: true, timeStart: DateTime.parse("2023-11-10"), timeEnd: DateTime.parse("2023-11-30"), dates: [true, false, false, false, false, false, false]);
      Event e = Event(name: "test_recurrence_event_1", description: "recurrence test", tags: [], timeStart: DateTime.parse("2023-11-11"), timeEnd: DateTime.parse("2023-11-12"), recurrenceRules: recurrenceRules);
      await db.setRecurringEvents(e);
    } else if (event == "delete") {
      final List<Event> eventList = await db.getListOfEventsInDay(date: DateTime.parse("2023-11-20"));
      if (eventList.isEmpty) {
        return;
      }
      Event e = eventList.first;
      await db.deleteRecurringEvents(e);
    } else if (event == "canvas") {
      await getCanvasEvents();
    } else {
      // final current_user = auth.currentUser;
      // final current_uid = current_user!.uid;
      // await db.addUserEvent(eventID: "example_event_id_$event", eventName: "example_event_name", eventTags: {"example_event_tag1", "example_event_tag2"}, timeStart: 10, timeEnd: 20);
      final dateStart = DateTime.parse("2023-10-16");
      final dateEnd = dateStart.add(const Duration(days: 5));
      // final userEvent = await db.getUserEventsInDateRange(dateStart: dateStart, dateEnd: dateEnd);
      final userEvent = await db.getEventsInDateRange(
          dateStart: dateStart, dateEnd: dateEnd);
      print(userEvent);
      // final e = userEvent.docs;
      return;
    }

    return;
  }

  Widget _buildToDoItem(String toDoText) {
    return ListTile(title: Text(toDoText));
  }

  Widget _buildToDoList() {
    return Expanded(
      child: ListView.builder(
        itemBuilder: (context, index) {
          if (index < _toDoItems.length) {
            return _buildToDoItem(_toDoItems[index]);
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: AppBar(
              centerTitle: true,
              backgroundColor: Colors.red,
              title: const Text(
                'To Do List',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                margin: const EdgeInsets.all(22),
                child: Row(
                  children: [
                    Expanded(
                      flex: 8,
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        onSubmitted: (val) {
                          _addToDoItem(val);
                        },
                        decoration: const InputDecoration(
                          hintText: 'Add a event here...',
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                            borderSide: BorderSide(color: Colors.red, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                            borderSide:
                                BorderSide(color: Colors.red, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        child: const Text('ADD'),
                        onPressed: () => _addToDoItem(_controller.text),
                      ),
                    )
                  ],
                )),
            _buildToDoList(),
          ],
        ),
      ),
    );
  }
  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("show in snack bar $value")));
  }
}
