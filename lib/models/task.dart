/// Class to bundle data for a task/event's recurrance
class Recurrence {
    bool enabled;
    num timeStart;
    num timeEnd;
    List<bool> dates;

    Recurrence(this.enabled, this.timeStart, this.timeEnd, this.dates);

    toMap() {
        return ({
            'enabled' : enabled,
            'ends on' : timeEnd,
            'repeat on days' : dates,
        });
    }
}

class Task {
    String name;
    String description;
    num timeDue;
    String location;
    String color;
    Set<String> tags=<String>{};
    Recurrence? recurrenceRules;
    final num timeCreated = DateTime.now().millisecondsSinceEpoch/1000;
    num timeModified=0;

    Task({required this.name, this.description="", this.timeDue=0, this.location="", this.color="#919191", required this.tags, this.recurrenceRules}) {
        timeModified=timeCreated;
    }
    
    toMap() {
      return ({
          'date created' : timeCreated,
          'date modified' : timeModified,
          'description' : description,
          'due date' : timeDue,
          'hex color' : color,
          'location' : location,
          'recurrence rules' : recurrenceRules?.toMap() ?? Recurrence(false, 0, 0, []).toMap(),
          'tags' : tags.toList(),
          'task name' : name
          }
      );
    }
}
