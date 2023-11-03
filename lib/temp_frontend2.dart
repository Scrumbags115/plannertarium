import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:planner/common/database.dart';
import 'package:planner/view/eventView.dart';

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
    DatabaseService db = DatabaseService(uid: "test_user_1");

    if (event == "add") {
      final timeStart = DateTime.now();
      final timeEnd = timeStart.add(const Duration(hours: 8));
      await db.addUniqueUserEvent(
          eventName: "example_event_name_2",
          eventTags: {"example_event_tag1"},
          timeStart: timeStart,
          timeEnd: timeEnd);
      return;
    } else if (event == "get range") {
      final dateStart = DateTime.parse("2023-10-20");
      final dateEnd = dateStart.add(const Duration(days: 8));
      final userEventMap = await db.getMapOfUserEventsInDateRange(
          dateStart: dateStart, dateEnd: dateEnd);
      print(userEventMap);

      userEventMap.forEach((key, value) {
        print(key + value.toString());
      });
      return;
    } else {
      return;
    }

    // final current_user = auth.currentUser;
    // final current_uid = current_user!.uid;
    // await db.addUserEvent(eventID: "example_event_id_$event", eventName: "example_event_name", eventTags: {"example_event_tag1", "example_event_tag2"}, timeStart: 10, timeEnd: 20);
    final dateStart = DateTime.parse("2023-10-16");
    final dateEnd = dateStart.add(const Duration(days: 5));
    // final userEvent = await db.getUserEventsInDateRange(dateStart: dateStart, dateEnd: dateEnd);
    final userEvent = await db.getMapOfUserEventsInDateRange(
        dateStart: dateStart, dateEnd: dateEnd);
    print(userEvent);
    // final e = userEvent.docs;
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
}
