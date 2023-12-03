import "package:flutter/material.dart";
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:planner/common/database.dart';
import 'package:planner/models/event.dart';
import 'package:intl/intl.dart';

import '../common/view/addTaskButton.dart';


class CustomButton extends StatelessWidget {
  int index;
  List<String> listOfDayStrings = ["M", "T", "W", "TH", "F", "S", "SU"];
  var selectedRecurringDay;
  CustomButton({
    Key? key,
    this.selectedRecurringDay = false,
    required this.index
  });

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
          child: Center(child: Text(listOfDayStrings[index], textAlign: TextAlign.center)),
        ),

      ],
    );
  }
}

Future<Event?> addEventFormForDay(BuildContext context, DateTime? date,
    {Event? event}) async {
  DatabaseService db = DatabaseService();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController tagController = TextEditingController();
  TextEditingController recRulesController = TextEditingController();
  Completer<Event?> completer = Completer<Event?>();
  Event currentEvent;
  Event? oldEvent = event; // old event, so if editing an event, remove the old one
  DateTime timeStart = DateTime.now();
  DateTime timeEnd = DateTime.now();

  DateTime? recurrenceEndTime;
  DateTime? recurrenceStartTime;

  bool enableRecurrence = false;

  List<bool> selectedRecurrenceDays = [
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];

  Future<DateTime?> datePicker() async {
    DateTime todayDate = DateTime.now();
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: todayDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      return selectedDate;
    }
    return selectedDate;
  }

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Row(
              children: [
                const Text('Add Event on'),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: ElevatedButton(
                      onPressed: () async {
                        DateTime? originalDate = date;
                        date = (await showDatePicker(
                            context: context,
                            initialDate: date!,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101)));
                        date ??=
                            originalDate; //in case user cancels date picker, show original date
                        setState(() {});
                      },
                      child: Text('${date?.month}/${date?.day}/${date?.year}')),
                )
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
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
                    timeStart = DateTime(date!.year, date!.month, date!.day,
                        startTOD.hour, startTOD.minute);
                    setState(() {});
                  },
                  child: Text(
                      "Starts at: ${DateFormat("h:mma").format(timeStart)}"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    TimeOfDay? endTOD = await showTimePicker(
                        context: context, initialTime: TimeOfDay.now());
                    endTOD ??= TimeOfDay.now(); //in case of cancel
                    timeEnd = DateTime(date!.year, date!.month, date!.day,
                        endTOD.hour, endTOD.minute);
                    setState(() {});
                  },
                  child:
                      Text("Ends at: ${DateFormat("h:mma").format(timeEnd)}"),
                ),
                // TextField(
                //   controller: tagController,
                //   decoration: InputDecoration(labelText: 'Tag'),
                // ),
                // TextField(
                //   controller: recRulesController,
                //   decoration: InputDecoration(labelText: 'Recurrence Rules'),
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Enable Recurrence:",
                        style: TextStyle(fontSize: 16)),
                    Switch.adaptive(
                        value: enableRecurrence,
                        onChanged: ((value) {
                        setState(() => enableRecurrence = value);
                        })
                    )
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.wallet),
                      onPressed: () async {
                        final DateTime? pickedDate = await datePicker();
                        if (pickedDate != null && pickedDate != recurrenceStartTime) {
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
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.calendar_month_rounded),
                      onPressed: () async {
                        final DateTime? pickedDueDate = await datePicker();
                        if (pickedDueDate != null && pickedDueDate != recurrenceEndTime) {
                          setState(() {
                            recurrenceEndTime = pickedDueDate;
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      recurrenceEndTime != null
                          ? 'Due Date: ${DateFormat('MM-dd-yyyy').format(recurrenceEndTime!)}'
                          : 'No due date selected',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ToggleButtons(
                        isSelected: selectedRecurrenceDays,
                        onPressed: (int index) {
                          setState(() {
                            // simply toggling buttons between true and false state
                            selectedRecurrenceDays[index] =
                            !selectedRecurrenceDays[index];
                          }
                          );
                        },

                        // onPressed: (index) {
                        //   setStateFunction(() {
                        //     for (int i = 0; i < isSelected.length; i++) {
                        //       if (i == index) {
                        //         isSelected[i] = true;
                        //       } else {
                        //         isSelected[i] = false;
                        //       }
                        //     }
                        //   });
                        // },
                        // renderBorder: false,

                        fillColor: Colors.transparent,
                        splashColor: Colors.orange,
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
            ]),
            actions: <Widget>[
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
                  if (oldEvent != null) {
                    db.deleteEvent(oldEvent);
                  }
                  db.setEvent(currentEvent);
                  db.deleteRecurringEvents(currentEvent, excludeMyself: true);
                  if (currentEvent.recurrenceRules.enabled) {
                    db.setRecurringEvents(currentEvent);
                  }

                  completer.complete(currentEvent);

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
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () async {
              // Wait for the _showEditPopup to complete and get the edited task
              Event? editedEvent = await addEventFormForDay(context, date, event: event);
              Navigator.of(context).pop();
            },
            child: const Text('Edit'),
          ),
        ],
      );
    },
  );
}