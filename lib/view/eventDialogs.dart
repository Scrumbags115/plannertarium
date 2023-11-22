import "package:flutter/material.dart";
import 'dart:async';
import 'package:planner/common/database.dart';
import 'package:planner/models/event.dart';

Future<Event?> addEventFormForDay(BuildContext context, DateTime date) async {
  DatabaseService db = DatabaseService();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController colorController = TextEditingController();
  TextEditingController tagController = TextEditingController();
  TextEditingController recRulesController = TextEditingController();
  Completer<Event?> completer = Completer<Event?>();
  DateTime timeStart = DateTime.now();
  DateTime timeEnd = DateTime.now();

  showDialog(
    context: context,
    builder: (context) {
      return SingleChildScrollView(
        child: AlertDialog(
          title: const Text('Add Event'),
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
                  timeStart = DateTime(date.year, date.month, date.day,
                      startTOD!.hour, startTOD.minute);
                },
                child: const Text("Choose start time"),
              ),
              ElevatedButton(
                onPressed: () async {
                  TimeOfDay? startTOD = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());
                  timeEnd = DateTime(date.year, date.month, date.day,
                      startTOD!.hour, startTOD.minute);
                },
                child: const Text("Choose end time"),
              ),
              // TextField(
              //   controller: tagController,
              //   decoration: InputDecoration(labelText: 'Tag'),
              // ),
              // TextField(
              //   controller: recRulesController,
              //   decoration: InputDecoration(labelText: 'Recurrence Rules'),
              // ),
            ],
          ),
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

                Event newEvent = Event(
                    name: name,
                    description: description,
                    location: location,
                    timeStart: timeStart,
                    timeEnd: timeEnd);

                db.addEvent(newEvent);

                completer.complete(newEvent);

                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
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
            Text('Starts at: ${event.timeStart.hour}:${event.timeStart.minute}'),
            Text('Ends At: ${event.timeEnd.hour}:${event.timeEnd.minute}'),
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
              Event? editedEvent = await _showEditPopup(context, event, date);
              Navigator.of(context).pop();
            },
            child: const Text('Edit'),
          ),
        ],
      );
    },
  );
}

Future<Event?> _showEditPopup(
    BuildContext context, Event event, DateTime date) async {
  DatabaseService db = DatabaseService();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController colorController = TextEditingController();
  TextEditingController tagController = TextEditingController();
  TextEditingController recRulesController = TextEditingController();
  DateTime timeStart = DateTime.now();
  DateTime timeEnd = DateTime.now();

  Completer<Event?> completer = Completer<Event?>();

  showDialog(
    context: context,
    builder: (context) {
      return SingleChildScrollView(
        child: AlertDialog(
          title: const Text('Edit Event'),
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
              TextField(
                controller: colorController,
                decoration: const InputDecoration(labelText: 'Color'),
              ),
              // TextField(
              //   controller: tagController,
              //   decoration: InputDecoration(labelText: 'Tag'),
              // ),
              // TextField(
              //   controller: recRulesController,
              //   decoration: InputDecoration(labelText: 'Recurrence Rules'),
              // ),
              ElevatedButton(
                onPressed: () async {
                  TimeOfDay? startTOD = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());
                  timeStart = DateTime(date.year, date.month, date.day,
                      startTOD!.hour, startTOD.minute);
                },
                child: const Text("Choose start time"),
              ),
              ElevatedButton(
                onPressed: () async {
                  TimeOfDay? startTOD = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());
                  timeEnd = DateTime(date.year, date.month, date.day,
                      startTOD!.hour, startTOD.minute);
                },
                child: const Text("Choose end time"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                completer.complete(null);
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                String name = nameController.text;
                String description = descriptionController.text;
                String location = locationController.text;
                String color = colorController.text;
                String tag = tagController.text;
                //String recRules = recRulesController.text;
                event.name = name;
                event.description = description;
                event.location = location;
                event.color = color;
                event.color = tag;
                event.timeStart = timeStart;
                event.timeEnd = timeEnd;
                //widget.task.recurrenceRules = recRules;

                db.setEvent(event);

                completer.complete(event);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );

  // Return the Future that completes with the edited task
  return completer.future;
}
