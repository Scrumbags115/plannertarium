<div align="center">
<h1>Plannertarium</h1>
<h3>Scheduling for scrumbags.</h3>
<a href="https://github.com/Scrumbags115/plannertarium/actions"><img src="https://github.com/Scrumbags115/plannertarium/workflows/plannertarium-tests/badge.svg" alt="Build Status"></a>
</div>

---
## Release Documents
Release documents can be found in the `./release` directory.

## Installation
Currently, users can install by source or by the provided APK file. To install from source, do the following:

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
### Views
- The app is split into two main parts: Tasks and Events. The user can toggle between them with the switch located in the Topbar.
- Tasks
  - The Task daily view is always the default view. Here, users can find their tasks that are due on the current day.
  - Swiping left will send the user to the weekly view. Here, the user's tasks for the entire current week (starting from Monday). The arrow buttons in the top left and right send the user to the previous and next week respectively.
  - Swiping left again will send the user to the monthly view. Here, the user can see their tasks for the whole month, and select a day to get a focused view of that day's tasks. Days with tasks due are marked with a little red dot.
  - Users can create tasks and assign a name, description, tags, and more in order to keep their day organized. 
 
- Events
  - The Event daily view shows a timeblocked view of the current day, along with all of the user's events that day.
  - The Event weekly view displays all the user's events for the current week starting from Monday. It can be reached by swiping left from the daily view. The arrow buttons in the top left and right send the user to the previous and next week respectively.
  - Swiping left once more will send the user to the monthly view, where one can drill down into days to see events on that day.
  - Users can create events and assign a name, description, tags, start and end times, and more in order to plan out their events.
    - Events can also be set to reccur on certain days of the week.
 
- Topbar
  - The daily and weekly views have a date picker in the top left to switch to different days or weeks.
  - There is also a search button which allows users to search by name, description, and tags.

### Misc
Tasks currently have a fixed color scheme:
- If a task is delayed, it is greyed out for the day *it was delayed from*. The task will then be moved to the next day.
- If a task has a due date set *and the task is displayed on the day it is due*, the task will be marked with a red background.
- Clicking on the blue circle to the left of the task will mark it as complete. This will mark all related delayed tasks as complete as well. It will cross out the text on all related tasks as well.

Recurrence functionality in events have a fixed way of updating:
- When a recurring event is made, all created events from the base event will be linked

Tasks and events must have valid date ranges and nonempty names or else it will not allow you to make changes.
