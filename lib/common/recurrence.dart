import 'package:cloud_firestore/cloud_firestore.dart';

/// Class to bundle data for a task/event's recurrance
class Recurrence {
  late bool enabled;
  late DateTime timeStart;
  late DateTime timeEnd;
  // monday, tuesday, ... , saturday, sunday
  late List<bool> dates;
  late String id; // ideally this should be final

  Recurrence(
      {this.enabled = false,
        DateTime? timeStart,
        DateTime? timeEnd,
        List<bool>? dates,
        String? id}) {
    this.timeStart = timeStart ?? DateTime(2000);
    this.timeEnd = timeEnd ?? DateTime(2000);
    this.dates = dates ?? [false, false, false, false, false, false, false];
    this.id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
  }
  
  /// Set nullOrId: null to set id to auto-generate an id instead
  Recurrence.requireFields(
      {required this.enabled,
        required this.timeStart,
        required this.timeEnd,
        required this.dates,
        required String? nullOrId}) {
    this.id = nullOrId ?? DateTime.now().millisecondsSinceEpoch.toString();
  }

  Recurrence.fromMap(Map<String, dynamic>? recurrenceRulesMap, {String? extraId}) {
    if (recurrenceRulesMap == null) {
      enabled = false;
      timeStart = DateTime(2000);
      timeEnd = DateTime(2000);
      dates = [false, false, false, false, false, false, false];
      id = DateTime.now().millisecondsSinceEpoch.toString();
    } else {
      enabled = recurrenceRulesMap?['enabled'] ?? false;
      timeStart = recurrenceRulesMap?["starts on"].toDate() ?? recurrenceRulesMap?["starts on"] ?? DateTime(2000);
      timeEnd = recurrenceRulesMap?["ends on"].toDate() ?? recurrenceRulesMap?["ends on"] ?? DateTime(2000);
      dates = [];
      // recurrenceRulesMap!['dates'].forEach((tag) {dates.add(tag as bool);}); // List<dynamic> bullshit
      if (recurrenceRulesMap?["repeat on days"]!=null) { 
        for (var b in recurrenceRulesMap!["repeat on days"]) {
          dates.add(b as bool);
      }
      } else {
          dates = [false, false, false, false, false, false, false];
      }
      id = extraId ?? (recurrenceRulesMap?.containsKey("id")!=null ? recurrenceRulesMap!["id"] : DateTime.now().millisecondsSinceEpoch.toString());
    }
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

  @override
  bool operator ==(Object? other) {
    if (identical(this, other)) return true;

    if (!enabled && other is Recurrence && !other.enabled) return true;

    if (other == null && !enabled) return true;

    return other is Recurrence &&
        enabled == other.enabled &&
        timeStart == other.timeStart &&
        timeEnd == other.timeEnd &&
        dates == other.dates &&
        id == other.id;
  }

  @override
  int get hashCode {
    return Object.hash(
      enabled,
      timeStart,
      timeEnd,
      dates,
      id,
    );
  }

  @override String toString() {
    return "Recurrence($enabled, $dates)";
  }
}