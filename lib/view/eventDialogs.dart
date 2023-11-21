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
                  timeStart = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    startTOD!.hour,
                    startTOD.minute
                  );
                },
                child: const Text("Choose start time"),
              ),
              ElevatedButton(
                onPressed: () async {
                  TimeOfDay? startTOD = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());
                  timeEnd = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    startTOD!.hour,
                    startTOD.minute
                  );
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
                  timeEnd: timeEnd
                );

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
