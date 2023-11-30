import 'package:planner/common/database.dart';
import 'package:flutter/material.dart';
import 'package:planner/models/task.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  const TaskCard({super.key, required this.task});

  @override
  TaskCardState createState() => TaskCardState();
}

class TaskCardState extends State<TaskCard> {
  DatabaseService db = DatabaseService();

  ///A DatePicker function to prompt a calendar
  ///Returns a selectedDate if chosen, defaulted to today if no selectedDate
  Future<DateTime?> datePicker() async {
    DateTime todayDate = DateTime.now();
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: todayDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      return todayDate;
    }
    return selectedDate;
  }

  ///A function to check if task is due today
  ///Returns a boolean true if there is a dueDate && equals to dueDate && task is not completed
  bool isTaskDueToday() {
    DateTime today = DateTime.now();
    DateTime? dueDate = widget.task.timeDue;

    return (dueDate != null &&
        today.day == dueDate.day &&
        today.month == dueDate.month &&
        today.year == dueDate.year &&
        !isTaskCompleted());
  }

  ///A function to check if task is completed
  ///Returns a boolean true if task is completed
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
          ///Gesture to delay task to next day
          setState(() {
            widget.task.moveToNextDay();
            db.setTask(widget.task);
          });
        } else if (direction == DismissDirection.endToStart) {
          ///Gesture to delete task and prompts a dialog box for confirmation
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Confirm Deletion'),
                content:
                    const Text('Are you sure you want to delete this task?'),
                actions: [
                  TextButton(
                    ///Cancel Button
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    ///Delete Button
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
        ///Specification for gestures for delay tasks
        color: const Color.fromARGB(255, 255, 153, 0),
        alignment: Alignment.centerLeft,
        child: const Icon(
          Icons.access_time,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        ///Specification for gestures for delete task
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
          ///Inkwell to prompt details of task
          onTap: () {
            showDetailPopup(context);
          },
          child: ListTile(
            leading: InkWell(
              ///Inkwell for setting a task completed
              onTap: () {
                setState(() {
                  widget.task.completed = !widget.task.completed;
                  db.setTask(widget.task);
                });
              },
              child: CircleAvatar(
                ///Specifications for the looks of Inkwell for setting a task completed
                backgroundColor: isTaskCompleted() ? Colors.green : Colors.blue,
                child: isTaskCompleted()
                    ? const Icon(Icons.check, color: Colors.white)
                    : const Icon(Icons.circle, color: Colors.blue),
              ),
            ),
            title: Text(
              ///Specifications to cross through the taskName if task is completed
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

  ///A void function to prompt for details of a task
  void showDetailPopup(BuildContext context) {
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
              onPressed: () {
                showEditPopup(context).then((editedTask) {
                  Navigator.of(context).pop();
                  if (editedTask != null) {
                    setState(() {});
                  }
                });
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  ///A function to prompt for the edit details of a task
  Future<Task?> showEditPopup(BuildContext context) async {
    DatabaseService db = DatabaseService();
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    TextEditingController colorController = TextEditingController();
    TextEditingController tagController = TextEditingController();
    DateTime? dueDate;
    DateTime? startTime = DateTime.now();
    Completer<Task?> completer = Completer<Task?>();

    showDialog(
      context: context,
      builder: (context) {
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
                          startTime = await datePicker();
                          setState(() {});
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

                widget.task.name = name;
                widget.task.description = description;
                widget.task.location = location;
                widget.task.color = color;
                widget.task.color = tag;
                widget.task.timeDue = dueDate;
                widget.task.timeStart = startTime??DateTime.now();
      
                db.setTask(widget.task);
                completer.complete(widget.task);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return completer.future;
  }
}
