import 'package:planner/common/database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planner/common/time_management.dart';
import 'package:planner/models/task.dart';
import 'dart:async';
import 'package:planner/view/weekView.dart';
import 'package:planner/view/weeklyTaskView.dart';
import 'package:planner/view/monthlyTaskView.dart';
import 'package:planner/view/dayView.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  const TaskCard({super.key, required this.task});

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  DatabaseService db = DatabaseService();

  Future<DateTime?> datePicker() async {
    DateTime today = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      return today;
    }
    return picked;
  }

  bool isTaskDueToday() {
    DateTime today = DateTime.now();
    DateTime? dueDate = widget.task.timeDue;

    return (dueDate != null &&
        today.day == dueDate.day &&
        today.month == dueDate.month &&
        today.year == dueDate.year &&
        !isTaskCompleted());
  }

  bool isTaskCompleted() {
    bool completed = widget.task.completed;
    return completed;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      onDismissed: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          setState(() {
            widget.task.moveToNextDay();
            db.setTask(widget.task);
          });
        } else if (direction == DismissDirection.endToStart) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Confirm Deletion'),
                content:
                    const Text('Are you sure you want to delete this task?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      db.deleteTask(widget.task);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Delete'),
                  ),
                ],
              );
            },
          );
        }
      },
      background: Container(
        color: const Color.fromARGB(255, 255, 153, 0),
        alignment: Alignment.centerLeft,
        child: const Icon(
          Icons.access_time,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 2,
        color: isTaskDueToday() ? Colors.white : Colors.grey.withOpacity(0.5),
        margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: InkWell(
          onTap: () {
            _showDetailPopup(context);
          },
          child: ListTile(
            leading: InkWell(
              onTap: () {
                setState(() {
                  widget.task.completed = !widget.task.completed;
                  db.setTask(widget.task);
                });
              },
              child: CircleAvatar(
                backgroundColor: isTaskCompleted() ? Colors.green : Colors.blue,
                child: isTaskCompleted()
                    ? const Icon(Icons.check, color: Colors.white)
                    : const Icon(Icons.circle, color: Colors.blue),
              ),
            ),
            title: Text(
              widget.task.name,
              style: TextStyle(
                decoration:
                    isTaskCompleted() ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(widget.task.description),
          ),
        ),
      ),
    );
  }

  void _showDetailPopup(BuildContext context) {
    String formattedDate = widget.task.timeDue != null
        ? DateFormat('yyyy-MM-dd').format(widget.task.timeDue!)
        : ' ';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Task Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Title: ${widget.task.name}'),
              Text('Description: ${widget.task.description}'),
              Text(
                'Time: ${DateFormat('yyyy-MM-dd').format(widget.task.timeStart)}- $formattedDate',
              ),
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
                Task? editedTask = await _showEditPopup(context);
                Navigator.of(context).pop();
                if (editedTask != null) {
                  setState(() {});
                }
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  Future<Task?> _showEditPopup(BuildContext context) async {
    DatabaseService db = DatabaseService();
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    TextEditingController colorController = TextEditingController();
    TextEditingController tagController = TextEditingController();
    TextEditingController recRulesController = TextEditingController();
    DateTime? dueDate;
    DateTime? startTime = DateTime.now();
    TextEditingController dueDateController = TextEditingController();
    Completer<Task?> completer = Completer<Task?>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height *
                  0.7, // Adjust the height as needed
              width: MediaQuery.of(context).size.width *
                  0.8, // Adjust the width as needed
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
                    controller: colorController,
                    decoration: const InputDecoration(labelText: 'Color'),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.wallet),
                        onPressed: () async {
                          startTime = await datePicker();
                          setState(() {});
                          print(startTime);
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        startTime != null
                            ? 'Start Time: ${DateFormat('yyyy-MM-dd').format(startTime!)}'
                            : 'No start time selected',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.calendar_month_rounded),
                        onPressed: () async {
                          dueDate = await datePicker();
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Due Time',
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
                completer.complete(null); // Complete with null if canceled
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

                widget.task.name = name;
                widget.task.description = description;
                widget.task.location = location;
                widget.task.color = color;
                widget.task.color = tag;
                //widget.task.recurrenceRules = recRules;

                db.setTask(widget.task);

                completer.complete(widget.task);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    // Return the Future that completes with the edited task
    return completer.future;
  }
}
