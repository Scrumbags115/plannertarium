import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:planner/common/database.dart';
import 'package:planner/common/view/timeManagement.dart';
import 'package:planner/models/task.dart';
import 'package:planner/models/tag.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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
            final newTodayTasks =
                await state.db.fetchTodayTasks(state.selectedDay);
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
  DateTime startTime = getDateOnly(DateTime.now());
  Completer<Task?> completer = Completer<Task?>();
  List<Tag> enteredTags = [];
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
                    onTap: () async {
                      List<Tag> result = await showTagSelectionDialog(context);
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
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.wallet),
                        onPressed: () async {
                          final DateTime? pickedDate = await datePicker(context,
                              initialDate: state.today,
                              defaultDate: state.today);
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
                          final DateTime? pickedDueDate = await datePicker(
                              context,
                              initialDate: state.monday,
                              defaultDate: state.monday);
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
                  timeStart: getDateOnly(startTime),
                );

                // if (enteredTags.isNotEmpty) {
                //   //error is here, saying
                //   // Class 'TaskView' has no instance getter 'task'.
                //   // Receiver: Instance of 'TaskView'
                //   // Tried calling: task
                //   //198 state.wwidget.(ERROR)task.tags
                //       newTask.tags =
                //           enteredTags.map((tag) => tag.id).toList();
                // }

                db.setTask(newTask);

                for (Tag tag in enteredTags) {
                  db.setTag(tag);
                  db.addTagToTask(newTask, tag);
                  // state.allTagsofTask.add(tag);
                }

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

Future<List<Tag>> showTagSelectionDialog(BuildContext context) async {
  List<Tag> selectedTags = [];

  TextEditingController nameController = TextEditingController();
  Color selectedColor = Colors.grey;
  Color pickerColor = const Color(0xff443a49);

  void changeColor(Color color) {
    pickerColor = color;
    selectedColor = color;
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
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Tag Color:',
                        style: TextStyle(
                          color: Colors.black,
                        )),
                  ),
                  SizedBox(
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
                color: selectedColor.value.toString(), // turn color into int
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
