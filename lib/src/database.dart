import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planner/common/recurrence.dart';
import 'package:planner/models/event.dart';

class DatabaseService {

  final String uid;
  DatabaseService({ required this.uid });

  // users collection reference
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  getUserEvents(String eventID) {
    return FirebaseFirestore.instance.collection('users').doc(uid).collection("events").doc(eventID); // turn this into a map of eventID to event objects?
  }

  getAllUserEvents() {
    return FirebaseFirestore.instance.collection('users').doc(uid).collection("events");
  }

  Future<void> _addUserEvent(String eventID, Event e) async {
    var doc = await users.doc(uid).collection("events").doc(eventID).get();
    // can't add an event with the same name
    if (doc.exists) {
      throw Future.error("Event ID already exists!");
    }
    return await users.doc(uid).collection("events").doc(eventID).set(e.toMap());
  }

  Future<void> addUserEvent(
      /// Add/set the user event. Every possible option to set is an argument
      /// required: String eventID, String eventName, Set<String> eventTags, num timeStart, num timeEnd
      /// optional: String eventDescription,, String, eventLocation, String eventColor, bool recurrenceEnabled, num recurrenceTimeStart, num recurrenceTimeEnd, List<bool> recurrenceDates
      {required String eventID,
      required String eventName,
      String eventDescription="",
      String eventLocation="",
      String eventColor="",
      required Set<String> eventTags,
      required num timeStart,
      required num timeEnd,
      bool recurrenceEnabled=false,
      num recurrenceTimeStart=0,
      num recurrenceTimeEnd=0,
      List<bool> recurrenceDates=const [false, false, false, false, false, false, false]}) async {
    Recurrence r = Recurrence(recurrenceEnabled, recurrenceTimeStart, recurrenceTimeEnd, recurrenceDates);
    Event e = Event(name: eventName, tags: eventTags, description: eventDescription, location: eventLocation, color: eventColor, timeStart: timeStart, timeEnd: timeEnd, recurrenceRules: r);
    return await _addUserEvent(eventID, e);
  }

  Future<void> updateEventOption(String eventID, Map<String, dynamic> newOptions) async
  /// Change an option in an event
  /// needs a event ID and a map of the new option
  /// map ex: {"optionName": "optionValue"}
  {
    return users.doc(uid).collection("events").doc(eventID).update(newOptions);
  }

  Future<void> updateEventName(String oldEventID, String newEventID) async {
    try {
      var doc = await users.doc(uid).collection("events").doc(oldEventID).get();
      Map<String, dynamic> data = {};
      if (doc.data() != null) {
        data = doc.data()!;
      }
      users.doc(uid).collection("events").doc(newEventID).set(data);
      users.doc(uid).collection("events").doc(oldEventID).delete();
    } catch(e) {
      return;
    }
  }
}