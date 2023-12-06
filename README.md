<div align="center">
<h1>Plannertarium</h1>
<h3>Scheduling for scrumbags.</h3>
<a href="https://github.com/Scrumbags115/plannertarium/actions"><img src="https://github.com/Scrumbags115/plannertarium/workflows/plannertarium-tests/badge.svg" alt="Build Status"></a>
</div>

---

## Installation
The only way to install as of now is by source.

After [installing flutter](https://docs.flutter.dev/get-started/install), clone from source:
```shell
git clone git@github.com:Scrumbags115/plannertarium.git
cd plannertarium
```
Then run the app with your [method of choice](https://docs.flutter.dev/get-started/test-drive). Current supported platforms are web + android + ios (Linux/Windows/Mac builds are not guaranteed).
Android will require a registered SHA1 key with the central Firestore. iOS will require a Mac and an Apple Developer account if building.

Alternatively, you can download and install the Plannertarium app on Android using the provided APK file in `./release` called `app-release.apk`.

---
## Some basic user guides/design documents
Tasks currently have a fixed color scheme:
1. If a task is delayed, it is greyed out for the day *it was delayed from*. The task will then be moved to the next day.
2. If a task has a due date set *and the task is displayed on the day it is due*, the task will be marked with a red background.
3. Clicking on the blue box to the left of the task will mark it as complete. This will mark all related delayed tasks as complete as well. It will cross out the text on all related tasks.
Recurrence functionality in events have a fixed way of updating:
1. When a recurring event is made, all created events from the base event will be linked
