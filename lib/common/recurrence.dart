/// Class to bundle data for a task/event's recurrance
class Recurrence {
  bool enabled;
  DateTime? timeStart;
  DateTime? timeEnd;
  List<bool>? dates;

  Recurrence(this.enabled, this.timeStart, this.timeEnd, this.dates);

  toMap() {
    return ({
      'enabled' : enabled,
      'starts on' : timeStart,
      'ends on' : timeEnd,
      'repeat on days' : dates,
    });
  }
}