import 'package:cloud_firestore/cloud_firestore.dart';

/// Class to bundle data for a task/event's recurrance
class Recurrence {
  late bool enabled;
  DateTime? timeStart;
  DateTime? timeEnd;
  // monday, tuesday, ... , saturday, sunday
  List<bool>? dates;
  String? id; // ideally this should be final

  Recurrence(
      {required this.enabled,
        required this.timeStart,
        required this.timeEnd,
        required this.dates,
        String? customID}) {
    id = customID ?? DateTime.now().millisecondsSinceEpoch.toString();
  }

  Recurrence.fromMap(Map<String, dynamic> recurrenceRulesMap) {
    enabled = recurrenceRulesMap['enabled'] ?? false;
    timeStart = recurrenceRulesMap["starts on"].toDate() ?? recurrenceRulesMap["starts on"];
    timeEnd = recurrenceRulesMap["ends on"].toDate() ?? recurrenceRulesMap["ends on"];
    dates = recurrenceRulesMap["repeat on days"];
    id = recurrenceRulesMap["id"];
  }

  toMap() {
    return ({
      'enabled' : enabled,
      'starts on' : timeStart, // not in format
      'ends on' : timeEnd,
      'repeat on days' : dates,
      'id' : id // not in format
    });
  }
}