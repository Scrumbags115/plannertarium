import 'package:uuid/uuid.dart';

List<bool> NO_RECURRENCE_ANY_DAY = [
  false,
  false,
  false,
  false,
  false,
  false,
  false
];
DateTime EPOCH_TIME = DateTime(1970);

String _getIdFromTime() {
  return DateTime.now().millisecondsSinceEpoch.toString();
}

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
    this.timeStart = timeStart ?? EPOCH_TIME;
    this.timeEnd = timeEnd ?? EPOCH_TIME;
    this.dates = dates ?? NO_RECURRENCE_ANY_DAY;
    this.id = id ?? _getIdFromTime();
  }

  /// Set nullOrId: null to set id to auto-generate an id instead
  Recurrence.requireFields(
      {required this.enabled,
      required this.timeStart,
      required this.timeEnd,
      required this.dates,
      required String? nullOrId}) {
    id = nullOrId ?? _getIdFromTime();
  }

  /// Initialize a Recurrence object's fields from a map
  Recurrence.fromMap(Map<String, dynamic>? recurrenceRulesMap,
      {String? extraId}) {
    if (recurrenceRulesMap == null) {
      enabled = false;
      timeStart = DateTime(2000);
      timeEnd = DateTime(2000);
      dates = NO_RECURRENCE_ANY_DAY;
      id = DateTime.now().millisecondsSinceEpoch.toString();
    } else {
      enabled = recurrenceRulesMap['enabled'] ?? false;
      timeStart = recurrenceRulesMap["starts on"].toDate() ??
          recurrenceRulesMap["starts on"] ??
          EPOCH_TIME;
      timeEnd = recurrenceRulesMap["ends on"].toDate() ??
          recurrenceRulesMap["ends on"] ??
          EPOCH_TIME;
      dates = [];
      // recurrenceRulesMap!['dates'].forEach((tag) {dates.add(tag as bool);}); // List<dynamic> bullshit
      if (recurrenceRulesMap["repeat on days"] != null) {
        for (var b in recurrenceRulesMap["repeat on days"]) {
          dates.add(b as bool);
        }
      } else {
        dates = NO_RECURRENCE_ANY_DAY;
      }
      id = extraId ??
          (recurrenceRulesMap.containsKey("id")
              ? recurrenceRulesMap["id"]
              : _getIdFromTime());
    }
  }

  /// Clone the recurrence object. If generateNewID is true, the ID of the cloned event will be different
  Recurrence.clone(Recurrence r, {generateNewID = false})
      : this(
          enabled: r.enabled,
          timeStart: r.timeStart,
          timeEnd: r.timeEnd,
          dates: List.from(r.dates),
          id: generateNewID ? "${r.id}-copy-${const Uuid().v4()}" : r.id,
        );

  /// Same as Recurrence.clone()
  Recurrence clone({generateNewID = false}) {
    return Recurrence.clone(this, generateNewID: generateNewID);
  }

  /// Sets the start and end dates for recurrence. Optionally can enable recurrence for Task/Event
  setTimeWindow(DateTime startDate, DateTime endDate,
      {bool enableRecurrence = false}) {
    timeStart = startDate;
    timeEnd = endDate;
    if (enableRecurrence) enabled = true;
  }

  /// Sets the days with recurrence. Optionally can enable recurrence for Task/Event
  setRecurrenceDatesFromList(List<bool> recurrenceDates,
      {bool enableRecurrence = false}) {
    dates = recurrenceDates;
    if (enableRecurrence) enabled = true;
  }

  enable() => enabled = true;

  disable() => enabled = false;

  toMap() {
    return ({
      'enabled': enabled,
      'starts on': timeStart,
      'ends on': timeEnd,
      'repeat on days': dates,
      'id': id
    });
  }

  @override
  bool operator ==(Object? other) {
    if (identical(this, other)) return true;

    if (!enabled && other is Recurrence && !other.enabled) return true;

    if (!enabled) return true;

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
      id,
    );
  }

  @override
  String toString() {
    return "Recurrence($enabled, $dates)";
  }
}
