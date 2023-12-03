import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:planner/common/database.dart';
import 'package:planner/models/task.dart';

getAddTaskButton(state, context) {
  return Align(
    alignment: Alignment.bottomRight,
    child: Padding(
      padding:
          const EdgeInsets.fromLTRB(0, 0, 20, 20), // Adjust the value as needed
      child: ClipOval(
        child: ElevatedButton(
          onPressed: () async {
            Task? newTask = await addButtonForm(context, state);
            final newTodayTasks = await state.db.fetchTodayTasks(state.selectedDay);
            if (newTask != null) {
              state.setState(() {
                state.todayTasks.add(newTask);
                state.fetchWeeklyTasks();
              });
              state.setState(() {
                state._selectedDay = state.selectedDay;
                state._focusedDay = state.focusedDay;
                state.todayTasks = newTodayTasks;
              });
            }
            state.setState(() {});
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            minimumSize: const Size(75, 75),
          ),
          child: const Icon(
            Icons.add_outlined,
            color: Colors.black,
          ),
        ),
      ),
    ),
  );
}

///A function that asynchronously shows a dialog for adding a new task.
Future<Task?> addButtonForm(BuildContext context, state) async {
  DatabaseService db = DatabaseService();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController tagController = TextEditingController();
  DateTime? dueDate;
  DateTime? startTime = DateTime.now();
  Completer<Task?> completer = Completer<Task?>();

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: SingleChildScrollView(
            child: SizedBox(
              height: (MediaQuery.of(context).size.height * 0.7),
              width: (MediaQuery.of(context).size.width * 0.8),
              child: Column(
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
                    controller: tagController,
                    decoration: const InputDecoration(labelText: 'Tag'),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.wallet),
                        onPressed: () async {
                          final DateTime? pickedDate =
                              await datePicker(context, state);
                          if (pickedDate != null && pickedDate != startTime) {
                            setState(() {
                              startTime = pickedDate;
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        startTime != null
                            ? 'Start Date: ${DateFormat('MM-dd-yyyy').format(startTime!)}'
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
                          final DateTime? pickedDueDate =
                              await datePicker(context, state);
                          if (pickedDueDate != null &&
                              pickedDueDate != dueDate) {
                            setState(() {
                              dueDate = pickedDueDate;
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dueDate != null
                            ? 'Due Date: ${DateFormat('MM-dd-yyyy').format(dueDate!)}'
                            : 'No due date selected',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                Task newTask = Task(
                  name: name,
                  description: description,
                  location: location,
                  timeDue: dueDate,
                  timeStart: startTime,
                );
                db.setTask(newTask);
                completer.complete(newTask);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
    },
  );
  return completer.future;
}

///A DatePicker function to prompt a calendar
///Returns a selectedDate if chosen, defaulted to today if no selectedDate
Future<DateTime?> datePicker(context, state) async {
  DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: state.today,
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
  );

  if (selectedDate != null) {
    return selectedDate;
  }
  return state.today;
}
