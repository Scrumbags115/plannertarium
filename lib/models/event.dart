import 'package:planner/common/recurrence.dart';
// import recurrence class here
class Event {
  String name;
  String description;
  final DateTime timeCreated = DateTime.now();
  DateTime timeModified=DateTime.now();
  DateTime timeStart;
  DateTime timeEnd;
  String color;
  String location;
  Set<String> tags=<String>{};
  Recurrence? recurrenceRules;
  Event({
    required this.name,
    this.description="",
    this.location="",
    this.color="",
    required this.tags,
    this.recurrenceRules,
    required this.timeStart,
    required this.timeEnd
  })
  {
    return;
  }
  Map<String, dynamic> toMap() {
    return ({
      'date created' : timeCreated,
      'date modified' : timeModified,
      'description' : description,
      'event time start' : timeStart,
      'event time end' : timeEnd,
      'hex color' : color,
      'location' : location,
      'recurrence rules' : recurrenceRules?.toMap(),
      'tags' : tags.toList(),
      'event name' : name
    }
    );
  }
}