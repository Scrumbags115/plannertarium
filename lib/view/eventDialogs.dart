import "package:flutter/material.dart";
import 'dart:async';
import 'package:planner/common/database.dart';
import 'package:planner/models/event.dart';
import 'package:intl/intl.dart';
import 'package:planner/models/tag.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../common/view/timeManagement.dart';
import '../common/view/flashError.dart';

class CustomButton extends StatelessWidget {
  final int index;
  final List<String> listOfDayStrings = ["M", "T", "W", "TH", "F", "S", "SU"];
  final bool selectedRecurringDay;
  CustomButton(
      {super.key, this.selectedRecurringDay = false, required this.index});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          width: 30,
          height: 30,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          // margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(
            color: selectedRecurringDay ? Colors.orange : Colors.transparent,
            // shape: BoxShape.circle,
          ),
          child: Center(
              child:
                  Text(listOfDayStrings[index], textAlign: TextAlign.center)),
        ),
      ],
    );
  }
}

Future<Event?> editEventFormForDay(BuildContext context, DateTime date,
    {Event? event}) async {
  return addEventFormForDay(context, date, event: event, edit: true);
}

Future<Event?> addEventFormForDay(BuildContext context, DateTime date,
    {Event? event, bool edit = false}) async {
  DatabaseService db = DatabaseService();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  DateTime now = DateTime.now();
  DateTime timeStart =
      DateTime(date.year, date.month, date.day, now.hour, now.minute);
  DateTime timeEnd =
      DateTime(date.year, date.month, date.day, now.hour, now.minute);
  bool enableRecurrence = false;
  DateTime? recurrenceEndTime;
  DateTime? recurrenceStartTime;
  List<bool> selectedRecurrenceDays = [
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  if (event != null) {
    nameController.text = event.name;
    descriptionController.text = event.description;
    locationController.text = event.location;
    timeStart = event.timeStart;
    timeEnd = event.timeEnd;
    enableRecurrence = event.recurrenceRules.enabled;
    final DateTime epoch = DateTime.fromMillisecondsSinceEpoch(0);
    if (epoch.compareTo(event.recurrenceRules.timeEnd) != 0) {
      recurrenceEndTime = event.recurrenceRules.timeEnd;
    }
    if (epoch.compareTo(event.recurrenceRules.timeStart) != 0) {
      recurrenceStartTime = event.recurrenceRules.timeStart;
    }
    selectedRecurrenceDays = event.recurrenceRules.dates;
  }

  bool editRelatedRecurringEvents = false;
  Completer<Event?> completer = Completer<Event?>();
  Event? oldEvent =
      event; // old event, so if editing an event, remove the old one
  if (event != null) {
    oldEvent = event.clone();
  }

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Row(
              children: [
                !edit
                    ? const Text('Add Event on')
                    : const Text("Edit Event on"),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: ElevatedButton(
                      onPressed: () async {
                        DateTime? newDate = (await showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101)));
                        if (newDate != null) {
                          date = newDate;
                          timeStart = DateTime(newDate.year, newDate.month,
                              newDate.day, timeStart.hour, timeStart.minute);
                          timeEnd = DateTime(newDate.year, newDate.month,
                              newDate.day, timeEnd.hour, timeEnd.minute);
                        }
                        setState(() {});
                      },
                      child: Text('${date.month}/${date.day}/${date.year}')),
                )
              ],
            ),
            content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              ElevatedButton(
                onPressed: () async {
                  TimeOfDay? startTOD = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());
                  startTOD ??= TimeOfDay.now(); //in case of cancel
                  timeStart = DateTime(date.year, date.month, date.day,
                      startTOD.hour, startTOD.minute);
                  setState(() {});
                },
                child:
                    Text("Starts at: ${DateFormat("h:mma").format(timeStart)}"),
              ),
              ElevatedButton(
                onPressed: () async {
                  TimeOfDay? endTOD = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());
                  endTOD ??= TimeOfDay.now(); //in case of cancel
                  timeEnd = DateTime(date.year, date.month, date.day,
                      endTOD.hour, endTOD.minute);
                  setState(() {});
                },
                child: Text("Ends at: ${DateFormat("h:mma").format(timeEnd)}"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Enable Recurrence:",
                      style: TextStyle(fontSize: 16)),
                  Switch.adaptive(
                      value: enableRecurrence,
                      onChanged: ((value) {
                        setState(() => enableRecurrence = value);
                      }))
                ],
              ),
              Visibility(
                visible: enableRecurrence,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.wallet),
                      onPressed: () async {
                        final DateTime? pickedDate = await datePicker(context,
                            initialDate: recurrenceStartTime);
                        if (pickedDate != null &&
                            pickedDate != recurrenceStartTime) {
                          setState(() {
                            recurrenceStartTime = pickedDate;
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      recurrenceStartTime != null
                          ? 'Start Date: ${DateFormat('MM-dd-yyyy').format(recurrenceStartTime!)}'
                          : 'No start date selected',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: enableRecurrence,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.calendar_month_rounded),
                      onPressed: () async {
                        final DateTime? pickedEndDate = await datePicker(
                            context,
                            initialDate: recurrenceEndTime);
                        if (pickedEndDate != null &&
                            pickedEndDate != recurrenceEndTime) {
                          setState(() {
                            recurrenceEndTime = pickedEndDate;
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      recurrenceEndTime != null
                          ? 'End Date: ${DateFormat('MM-dd-yyyy').format(recurrenceEndTime!)}'
                          : 'No end date selected',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: enableRecurrence,
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ToggleButtons(
                      isSelected: selectedRecurrenceDays,
                      onPressed: (int index) {
                        setState(() {
                          // simply toggling buttons between true and false state
                          selectedRecurrenceDays[index] =
                              !selectedRecurrenceDays[index];
                        });
                      },
                      constraints:
                          const BoxConstraints.expand(height: 30, width: 30),
                      children: List<Widget>.generate(7, (index) {
                        return CustomButton(
                          index: index,
                          selectedRecurringDay: selectedRecurrenceDays[index],
                        );
                      }),
                    )
                    // ],
                    ),
              ),
            ]),
            actionsAlignment: MainAxisAlignment.end,
            actionsPadding: edit && enableRecurrence
                ? const EdgeInsets.symmetric(horizontal: 12, vertical: 24)
                : const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
            actions: <Widget>[
              Visibility(
                visible: edit && enableRecurrence,
                child: Wrap(
                    direction: Axis.horizontal,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: -10,
                    children: [
                      const Text("Edit Recurring:"),
                      Checkbox.adaptive(
                          value: editRelatedRecurringEvents,
                          onChanged: (newValue) {
                            setState(() {
                              editRelatedRecurringEvents = newValue!;
                            });
                          }),
                    ]
                    //  <-- leading Checkbox
                    ),
              ),
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                  completer.complete(null); // Complete with null if canceled
                },
              ),
              TextButton(
                child: const Text('Submit'),
                onPressed: () {
                  String name = nameController.text;
                  String description = descriptionController.text;
                  String location = locationController.text;
                  Event currentEvent = Event();
                  currentEvent.name = name;
                  currentEvent.description = description;
                  currentEvent.location = location;
                  currentEvent.timeStart = timeStart;

                  currentEvent.timeEnd = timeEnd;

                  currentEvent.recurrenceRules.enabled = enableRecurrence;
                  if (recurrenceEndTime != null) {
                    currentEvent.recurrenceRules.timeEnd = recurrenceEndTime!;
                  }
                  currentEvent.recurrenceRules.dates = selectedRecurrenceDays;

                  if (recurrenceStartTime != null) {
                    currentEvent.recurrenceRules.timeStart =
                        recurrenceStartTime!;
                  }

                  /// return if one of the datetimes provided is not set/is the epoch
                  bool oneIsUnset(DateTime one, DateTime two) {
                    final DateTime epoch =
                        DateTime.fromMillisecondsSinceEpoch(0);
                    return epoch.compareTo(one) == 0 ||
                        epoch.compareTo(two) == 0;
                  }

                  /// return if the given event has valid recurrence datetimes
                  bool validRecurrenceDateTimes(Event e) {
                    return !e.recurrenceRules.enabled || (!oneIsUnset(e.recurrenceRules.timeStart,
                            e.recurrenceRules.timeEnd) &&
                        e.recurrenceRules.timeStart
                                .compareTo(e.recurrenceRules.timeEnd) <
                            0);
                  }

                  /// return if the event has valid timestart and timeend datetimes
                  bool validEventDateTimes(Event e) {
                    return e.timeStart.compareTo(e.timeEnd) < 0;
                  }

                  // test if datetimes are valid for both the event and recurring event
                  if (!validEventDateTimes(currentEvent)) {
                    // if the current event datetime range is invalid, display an error
                    showFlashError(context,
                        "The event's start and end times are invalid! Please try again.");
                  } else if (!validRecurrenceDateTimes(currentEvent)) {
                    // if the current event's recurrence rules has existing datetimes and the range is invalid, display an error
                    showFlashError(context,
                        "The recurrence start and end times are invalid! Please try again.");
                  } else {
                    db.setEvent(currentEvent);
                    if (currentEvent.recurrenceRules.enabled) {
                      db.setRecurringEvents(currentEvent);
                    }

                    // if we are editing an event, delete the old one
                    if (oldEvent != null) {
                      db.deleteEvent(oldEvent);
                    }

                    if (editRelatedRecurringEvents && oldEvent != null) {
                      // delete related recurring events if the option is explicitly set
                      db.deleteRecurringEvents(oldEvent, excludeMyself: true);
                    }

                    completer.complete(currentEvent);
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      });
    },
  );

  return completer.future;
}

Future<List<Tag>> showTagSelectionDialog(BuildContext context) async {
  List<Tag> selectedTags = [];

  TextEditingController nameController = TextEditingController();
  Color selectedColor = Colors.blue;
  Color pickerColor = const Color(0xff443a49);

  void changeColor(Color color) {
    pickerColor = color;
    selectedColor = color;
  }

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add Tag'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tag Name'),
              ),
              const SizedBox(height: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Tag Color:',
                        style: TextStyle(
                          color: Colors.black,
                        )),
                  ),
                  SizedBox(
                    width: 200,
                    child: ColorPicker(
                      pickerColor: pickerColor,
                      onColorChanged: changeColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, selectedTags);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Tag selectedTag = Tag(
                name: nameController.text,
                color: selectedColor.value.toString(), // turn color into int
              );
              selectedTags.add(selectedTag);
              nameController.clear();
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );

  return selectedTags;
}

void showEventDetailPopup(BuildContext context, Event event, DateTime date) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Event Details'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Title: ${event.name}'),
            Text('Description: ${event.description}'),
            Text('Location: ${event.location}'),
            Text('Starts at: ${DateFormat("h:mma").format(event.timeStart)}'),
            Text('Ends At: ${DateFormat("h:mma").format(event.timeEnd)}'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () {
                DatabaseService db = DatabaseService();
                db.deleteEvent(event);
                Navigator.of(context).pop();
              },
              child: const Text('Delete')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () async {
              // Wait for the _showEditPopup to complete and get the edited task
              Event? editedEvent =
                  await editEventFormForDay(context, date, event: event);
              Navigator.of(context).pop();
            },
            child: const Text('Edit'),
          ),
        ],
      );
    },
  );
}
