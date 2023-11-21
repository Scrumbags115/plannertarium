import "package:flutter/material.dart";
import 'dart:async';
import 'package:planner/common/database.dart';
import 'package:planner/models/task.dart';

Future<Task?> addTaskFormForDay(BuildContext context,
    [DateTime? date]) async {
  DatabaseService db = DatabaseService();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController colorController = TextEditingController();
  TextEditingController tagController = TextEditingController();
  TextEditingController recRulesController = TextEditingController();
  Completer<Task?> completer = Completer<Task?>();

  showDialog(
    context: context,
    builder: (context) {
      return SingleChildScrollView(
        child: AlertDialog(
          title: const Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Task Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
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

                Task newTask = Task(
                    name: name,
                    description: description,
                    location: location,
                    timeStart: DateTime.now(),
                    timeDue: date);

                db.setTask(newTask);

                // Complete with the new task
                completer.complete(newTask);

                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );

  // Return the Future that completes with the new task
  return completer.future;
}
