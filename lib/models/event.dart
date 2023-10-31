import 'package:planner/common/recurrence.dart';
// import recurrence class here
class Event {
  String name;
  String description;
  DateTime timeCreated = DateTime.now();
  DateTime timeModified = DateTime.now();
  DateTime? timeStart;
  DateTime? timeEnd;
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
  });


  /// Alternate constructor so VSCode autogenerates all fields
  /// Good for reading from database
  Event.requireFields(
      {required this.name,
        required this.description,
        required this.timeCreated,
        required this.timeModified,
        required this.timeStart,
        required this.timeEnd,
        required this.color,
        required this.location,
        required this.tags,
        required this.recurrenceRules});

  set Name(String newName) {
    timeModified = DateTime.now();
    name = newName;
  }
  String get Name => name;

  set Description(String newDescription) {
    timeModified = DateTime.now();
    description = newDescription;
  }
  String get Description => description;

  set TimeStart(newTimeStart) {
    timeModified = DateTime.now();
    timeStart = newTimeStart;
  }
  get TimeStart => timeStart;

  set TimeEnd(newTimeEnd) {
    timeModified = DateTime.now();
    timeEnd = newTimeEnd;
  }

  get TimeEnd => timeEnd;

  set Location(String newLocation) {
    timeModified = DateTime.now();
    location = newLocation;
  }
  String get Location => location;

  set Color(String newColor) {
    timeModified = DateTime.now();
    location = newColor;
  }
  String get Color => color;

  set Tags(Set<String> newTags) {
    timeModified = DateTime.now();
    tags = newTags;
  }
  Set<String> get Tags => tags;

  set RecurrenceRules(newRecurrence) { // Can't force Recurrence type because it can be null
    timeModified = DateTime.now();
    recurrenceRules = newRecurrence;
  }
  get RecurrenceRules => recurrenceRules;

  get TimeCreated => timeCreated; // Do not want to timeCreated this after the constructor

  get TimeModified => timeModified; // Do not want to change timeModified unless modifying a field

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