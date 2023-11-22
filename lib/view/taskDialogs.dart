import "package:flutter/material.dart";
import 'dart:async';
import 'package:planner/common/database.dart';
import 'package:planner/models/task.dart';

Future<Task?> addTaskFormForDay(BuildContext context, [DateTime? date]) async {
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
                    timeDue: date,
                    color: "#FFFFFFFF");

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

void showTaskDetailPopup(BuildContext context, Task task) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Task Details'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Title: ${task.name}'),
            Text('Description: ${task.description}'),
            Text('Location: ${task.location}'),
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
              Task? editedTask = await _showEditPopup(context, task);
              Navigator.of(context).pop();
            },
            child: const Text('Edit'),
          ),
        ],
      );
    },
  );
}

Future<Task?> _showEditPopup(BuildContext context, Task task) async {
  DatabaseService db = DatabaseService();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController colorController = TextEditingController();
  TextEditingController tagController = TextEditingController();
  TextEditingController recRulesController = TextEditingController();
  TextEditingController dueDateController = TextEditingController();

  Completer<Task?> completer = Completer<Task?>();

  showDialog(
    context: context,
    builder: (context) {
      return SingleChildScrollView(
        child: AlertDialog(
          title: const Text('Edit Task'),
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
              TextField(
                controller: dueDateController,
                decoration: const InputDecoration(labelText: 'Due Date'),
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
                //String dueDate = dueDateController.text;
                task.name = name;
                task.description = description;
                task.location = location;
                task.color = color;
                task.color = tag;
                //widget.task.recurrenceRules = recRules;

                db.setTask(task);

                completer.complete(task);
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
