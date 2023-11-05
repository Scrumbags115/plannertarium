/// Class to bundle data for a task/event's recurrance
class Recurrence {
  bool enabled;
  DateTime? timeStart;
  DateTime? timeEnd;
  // monday, tuesday, ... , saturday, sunday
  List<bool>? dates;
  int? id; // ideally this should be final

  Recurrence(
      {required this.enabled,
        required this.timeStart,
        required this.timeEnd,
        required this.dates,
        this.id}) {
    id = id ?? DateTime.now().millisecondsSinceEpoch;
  }

  Recurrence.requireFields(
      {required this.enabled,
        required this.timeStart,
        required this.timeEnd,
        required this.dates}) {
    id ??= DateTime.now().millisecondsSinceEpoch; // something about this design pattern looks off... not sure how to make this better since flutter won't allow me to put an optional named argument in
  }
  toMap() {
    return ({
      'enabled' : enabled,
      'starts on' : timeStart,
      'ends on' : timeEnd,
      'repeat on days' : dates,
      'id' : id
    });
  }
}