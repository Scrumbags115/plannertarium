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