import "package:flutter/material.dart";
import 'dart:async';
import 'package:planner/common/database.dart';
import 'package:planner/models/event.dart';
import 'package:intl/intl.dart';

import '../common/view/tagPopup.dart';
import '../common/view/timeManagement.dart';
import '../common/view/flashError.dart';
import '../models/tag.dart';

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

class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(label),
          Checkbox(
            value: value,
            onChanged: (bool? newValue) {
              onChanged(newValue);
            },
          ),
        ],
      ),
    );
  }
}

Future<Event?> addEventFormForDay(BuildContext context, DateTime date,
    {Event? event, bool edit = false}) async {
  DatabaseService db = DatabaseService();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController tagController = TextEditingController();

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

  List<Tag> enteredTags = [];
  List<Tag> allTagsOfEvent = enteredTags;
  if (event != null) {
    oldEvent = event.clone();

    allTagsOfEvent = await db.getTagsOfEvent(event.id);
    enteredTags = List.from(allTagsOfEvent);
  }
  // todo: make this synchronous
  showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
              title: Row(children: [
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
              ]),
              content: SingleChildScrollView(
                child: SizedBox(
                    height: (MediaQuery.of(context).size.height * 0.7),
                    width: (MediaQuery.of(context).size.width * 0.8),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextField(
                            controller: nameController,
                            decoration:
                                const InputDecoration(labelText: 'Event Name'),
                          ),
                          TextField(
                            controller: descriptionController,
                            decoration:
                                const InputDecoration(labelText: 'Description'),
                          ),
                          TextField(
                            controller: locationController,
                            decoration:
                                const InputDecoration(labelText: 'Location'),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: ElevatedButton(
                              onPressed: () async {
                                TimeOfDay? startTOD = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now());
                                startTOD ??=
                                    TimeOfDay.now(); //in case of cancel
                                timeStart = DateTime(date.year, date.month,
                                    date.day, startTOD.hour, startTOD.minute);
                                setState(() {});
                              },
                              child: Text(
                                  "Starts at: ${DateFormat("h:mma").format(timeStart)}"),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: ElevatedButton(
                              onPressed: () async {
                                TimeOfDay? endTOD = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now());
                                endTOD ??= TimeOfDay.now(); //in case of cancel
                                timeEnd = DateTime(date.year, date.month,
                                    date.day, endTOD.hour, endTOD.minute);
                                setState(() {});
                              },
                              child: Text(
                                  "Ends at: ${DateFormat("h:mma").format(timeEnd)}"),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: Row(
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
                          ),
                          Visibility(
                            visible: enableRecurrence,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.wallet),
                                  onPressed: () async {
                                    final DateTime? pickedDate =
                                        await datePicker(context,
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
                                  icon:
                                      const Icon(Icons.calendar_month_rounded),
                                  onPressed: () async {
                                    final DateTime? pickedEndDate =
                                        await datePicker(context,
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
                                  constraints: const BoxConstraints.expand(
                                      height: 30, width: 30),
                                  children: List<Widget>.generate(7, (index) {
                                    return CustomButton(
                                      index: index,
                                      selectedRecurringDay:
                                          selectedRecurrenceDays[index],
                                    );
                                  }),
                                )
                                // ],
                                ),
                          ),
                          TextField(
                            controller: tagController,
                            decoration: const InputDecoration(labelText: 'Tag'),
                            onTap: () async {
                              List<Tag> result = await showTagSelectionDialog(
                                  context,
                                  setState: setState);
                              if (result.isNotEmpty) {
                                setState(() {
                                  enteredTags.addAll(result);
                                });
                              }
                            },
                          ),
                          SizedBox(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: enteredTags.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 10),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            // removeFromLocalTagList(enteredTags[index]);
                                            enteredTags.removeAt(index);
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            Text(enteredTags[index].name),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ])),
              ),
              actions: <Widget>[
                Visibility(
                  visible: edit && enableRecurrence,
                  child: Wrap(
                      direction: Axis.horizontal,
                      crossAxisAlignment: WrapCrossAlignment.center,
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
                Visibility(
                    visible: edit && enableRecurrence,
                    child: LabeledCheckbox(
                        label: "Edit Recurring: ",
                        value: editRelatedRecurringEvents,
                        onChanged: (newValue) {
                          setState(() {
                            editRelatedRecurringEvents = newValue!;
                          });
                        })),
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

                      for (Tag tag in enteredTags) {
                        db.setTag(tag);
                      }

                      if (enteredTags.isNotEmpty) {
                        currentEvent.tags =
                            enteredTags.map((tag) => tag.id).toList();
                      }

                      currentEvent.timeEnd = timeEnd;

                      currentEvent.recurrenceRules.enabled = enableRecurrence;
                      if (recurrenceEndTime != null) {
                        currentEvent.recurrenceRules.timeEnd =
                            recurrenceEndTime!;
                      }
                      currentEvent.recurrenceRules.dates =
                          selectedRecurrenceDays;

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
                        return !e.recurrenceRules.enabled ||
                            (!oneIsUnset(e.recurrenceRules.timeStart,
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
                          db.deleteRecurringEvents(oldEvent,
                              excludeMyself: true);
                        }

                        completer.complete(currentEvent);
                      }
                      Navigator.of(context).pop();
                    })
              ]);
        });
      });

  return completer.future;
}

Future<String> getTagNamesOfEvent(Event event) async {
  DatabaseService db = DatabaseService();
  var tagsOfEvent = await db.getTagsOfEvent(event.id);
  String tagNames = "";
  for (Tag tag in tagsOfEvent) {
    tagNames += "${tag.name}, ";
  }
  // remove the last comma if the string is not empty
  if (tagNames.isNotEmpty) {
    tagNames = tagNames.substring(0, tagNames.length - 2);
  }
  return tagNames;
}

Future<void> showEventDetailPopup(
    BuildContext context, Event event, DateTime date) async {
  // todo: make this synchronous
  String tagNames = await getTagNamesOfEvent(event);
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
            Text('Tag: $tagNames'),
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
