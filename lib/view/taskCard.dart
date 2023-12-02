import 'package:planner/common/database.dart';
import 'package:flutter/material.dart';
import 'package:planner/models/task.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:planner/models/tag.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  const TaskCard({super.key, required this.task});

  @override
  TaskCardState createState() => TaskCardState();
}

class TaskCardState extends State<TaskCard> {
  DatabaseService db = DatabaseService();

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
                content: const Text('Are you sure you want to delete this task?'),
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
            showDetailPopup(context);
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
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.task.description),
                if (widget.task.tags.isNotEmpty)
                  Wrap(
                    spacing: 8.0,
                    children: widget.task.tags.map((tag) {
                      return Chip(
                        label: Text(tag),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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

  Future<List<Tag>> showTagSelectionDialog(BuildContext context) async {
    List<Tag> selectedTags = [];

    TextEditingController nameController = TextEditingController();
    Color selectedColor = Colors.blue;
    Color pickerColor = Color(0xff443a49);

    void changeColor(Color color) {
      setState(() {
        pickerColor = color;
        selectedColor = color;
      });
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tag Color:'),
                    Container(
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
                  color: selectedColor.toString(),
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

  Future<Task?> showEditPopup(BuildContext context) async {
    DatabaseService db = DatabaseService();
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    TextEditingController tagController = TextEditingController();
    DateTime? dueDate;
    DateTime? startTime = DateTime.now();
    Completer<Task?> completer = Completer<Task?>();

    List<Tag> enteredTags = [];
    Tag? selectedTag;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Task'),
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
                      Container(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: enteredTags.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Text(enteredTags[index].name),
                                  IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        enteredTags.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      TextField(
                        controller: tagController,
                        decoration: const InputDecoration(labelText: 'Tag'),
                        onTap: () async {
                          List<Tag> result = await showTagSelectionDialog(context);
                          if (result.isNotEmpty) {
                            setState(() {
                              enteredTags.addAll(result);
                            });
                          }
                        },
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
                          const Text('Due Time'),
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
                    if (enteredTags.isNotEmpty) {
                      widget.task.tags = enteredTags.map((tag) => tag.name).toList();
                    }
                    String name = nameController.text;
                    String description = descriptionController.text;
                    String location = locationController.text;

                    widget.task.name = name;
                    widget.task.description = description;
                    widget.task.location = location;
                    widget.task.timeDue = dueDate;
                    widget.task.timeStart = startTime ?? DateTime.now();

                    db.setTask(widget.task);
                    completer.complete(widget.task);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );

    return completer.future;
  }
}
