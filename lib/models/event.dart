// import recurrence class here
class Event {
  String name;
  String description;
  final num timeCreated = DateTime.now().millisecondsSinceEpoch/1000;
  num timeModified=0;
  num timeStart;
  num timeEnd;
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
    timeModified=timeCreated;
  }
  toMap() {
    return ({
      'date created' : timeCreated,
      'date modified' : timeModified,
      'description' : description,
      'event time start' : timeStart,
      'event time end' : timeEnd,
      'hex color' : color,
      'location' : location,
      'recurrence rules' : recurrenceRules?.toMap() ?? Recurrence(false, 0, 0, []).toMap(),
      'tags' : tags.toList(),
      'task name' : name
    }
    );
  }
}