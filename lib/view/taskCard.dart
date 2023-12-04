// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:get/get.dart';
import 'package:planner/common/database.dart';
import 'package:flutter/material.dart';
import 'package:planner/common/time_management.dart';
import 'package:planner/models/task.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:planner/models/tag.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  late DateTime cardDate;
  late var state;
  TaskCard(
      {super.key,
      required this.task,
      DateTime? dateOfCard,
      required this.state}) {
    cardDate = dateOfCard ?? getDateOnly(DateTime.now());
  }

  @override
  TaskCardState createState() => TaskCardState();
}

class TaskCardState extends State<TaskCard> {
  List<Tag> allTagsofTask = [];

  @override
  void initState() {
    super.initState();
    asyncInitState();
  }

  void asyncInitState() async {
    // widget.task = await db.getTask(widget.task.id);
    db.setTask(widget.task);
    allTagsofTask = await db.getTagsOfTask(widget.task.id);
    setState(() {});
  }

  void callMeInSetState() {
    db.setTask(widget.task);
    for (Tag tag in allTagsofTask) {
      db.addTagToTask(widget.task, tag);
    }
  }

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

  Color getTaskColor() {
    if (widget.task.timeDue != null &&
        widget.task.timeDue!.isAtSameMomentAs(widget.cardDate)) {
      return const Color.fromARGB(255, 255, 185, 185);
    } else if (widget.task.isDelayedOn(widget.cardDate) ||
        widget.task.completed) {
      return Colors.grey.withOpacity(0.5);
    } else {
      return Colors.white;
    }
  }

  bool isTaskCompleted() {
    bool completed = widget.task.completed;
    return completed;
  }

  Future<Color> getColorForTag(String tagID) async {
    Tag log = await db.getTag(tagID);

    return Color(int.parse(log.color));
  }

  Future<List<Color>> getColorsForTags(List<String> tagIDs) async {
    List<Color> colors = [];
    for (String tagName in tagIDs) {
      colors.add(await getColorForTag(
          tagName)); // Assuming getColorForTag returns a Future<Color>
    }
    return colors;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      confirmDismiss: (DismissDirection direction) async {
        if (direction == DismissDirection.endToStart) {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Confirm"),
                content:
                    const Text("Are you sure you wish to delete this item?"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("CANCEL"),
                  ),
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text("DELETE")),
                ],
              );
            },
          );
        }
        return true;
      },
      onDismissed: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          setState(() {
            DateTime oldTaskDate = widget.task.timeCurrent;
            widget.task.moveToNextDay();
            db.setTask(widget.task);
            widget.state.moveDelayedTask(widget.task, oldTaskDate);
          });
        } else if (direction == DismissDirection.endToStart) {
          db.deleteTask(widget.task);
          widget.state.deleteTask(widget.task);
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
        color: getTaskColor(),
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
                    widget.state.toggleCompleted(widget.task);
                  });
                },
                child: CircleAvatar(
                  backgroundColor:
                      isTaskCompleted() ? Colors.green : Colors.blue,
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
                    FutureBuilder<List<Color>>(
                      future: getColorsForTags(
                          widget.task.tags), // Use the new function here
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Color>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator(); // Show a loader while waiting
                        } else if (snapshot.hasError) {
                          return Text(
                              'Error: ${snapshot.error}'); //exception: tag not found!
                        } else if (snapshot.hasData) {
                          return Wrap(
                            spacing: 8.0,
                            children: List<Widget>.generate(
                                widget.task.tags.length, (int index) {
                              return Chip(
                                label: Text(getTagNameInLocalTagListWithTagID(
                                    widget.task.tags[index])),
                                backgroundColor: snapshot.data![
                                    index], // Use the color from the snapshot
                              );
                            }),
                          );
                        } else {
                          return Container(); // Return an empty container if there's no data
                        }
                      },
                    ),
                ],
              )),
        ),
      ),
    );
  }

  String getTagNameInLocalTagListWithTagID(String tagID) {
    for (final Tag tag in allTagsofTask) {
      if (tag.id == tagID) {
        return tag.name;
      }
    }
    return ("Tag not found in local tag list");
  }

  void showExistingTags(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Existing Tags'),
          );
        });
  }

  void showDetailPopup(BuildContext context) async {
    String formattedDate = widget.task.timeDue != null
        ? DateFormat('yyyy-MM-dd').format(widget.task.timeDue!)
        : ' ';

    // create a string of the names of tags in imcrying. Make them comma separated
    var tagsOfWidgetTask = await db.getTagsOfTask(widget.task.id);
    String tagNames = "";
    for (Tag tag in tagsOfWidgetTask) {
      tagNames += "${tag.name}, ";
    }
    // remove the last comma
    if (tagsOfWidgetTask.isNotEmpty) {
      tagNames = tagNames.substring(0, tagNames.length - 2);
    }

    showDialog(
      context: context,
      builder: (context) {
        //
        return AlertDialog(
          title: const Text('Task Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Title: ${widget.task.name}'),
              Text('Description: ${widget.task.description}'),
              Text('Tag: $tagNames'),
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
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

  Future<Task?> showEditPopup(BuildContext context) async {
    DatabaseService db = DatabaseService();

    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    TextEditingController tagController = TextEditingController();
    DateTime? dueDate = widget.task.timeDue;
    DateTime? startTime = widget.task.timeStart;
    Completer<Task?> completer = Completer<Task?>();

    List<Tag> enteredTags = [];
    //Tag? selectedTag;

    nameController.text = widget.task.name;
    descriptionController.text = widget.task.description;
    locationController.text = widget.task.location;

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
                        decoration:
                            const InputDecoration(labelText: 'Task Name'),
                      ),
                      TextField(
                        controller: descriptionController,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                      ),
                      TextField(
                        controller: locationController,
                        decoration:
                            const InputDecoration(labelText: 'Location'),
                      ),
                      TextField(
                        controller: tagController,
                        decoration: const InputDecoration(labelText: 'Tag'),
                        onTap: () async {
                          List<Tag> result =
                              await showTagSelectionDialog(context);
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
                              margin: EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 10),
                              padding: EdgeInsets.all(8),
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
                              final DateTime? pickedDate = await datePicker();
                              if (pickedDate != null &&
                                  pickedDate != startTime) {
                                setState(() {
                                  startTime = pickedDate;
                                  for (Tag tag in enteredTags) {
                                    db.setTag(tag);
                                  }
                                  db.setTask(widget.task);
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
                                  await datePicker();
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
                    if (enteredTags.isNotEmpty) {
                      widget.task.tags =
                          enteredTags.map((tag) => tag.id).toList();
                    }
                    String name = nameController.text;
                    String description = descriptionController.text;
                    String location = locationController.text;

                    widget.task.name = name;
                    widget.task.description = description;
                    widget.task.location = location;
                    widget.task.timeDue = dueDate;
                    widget.task.timeStart = startTime ?? DateTime.now();

                    widget.task.tags = [];

                    db.setTask(widget.task);

                    for (Tag tag in enteredTags) {
                      db.addTagToTask(widget.task, tag);
                      allTagsofTask.add(tag);
                    }

                    completer.complete(widget.task);
                    Navigator.of(context).pop;
                    setState(() {
                      // for (Tag tag in enteredTags) {
                      //   allTagsofTask.add(tag);
                      // }
                      asyncInitState();
                      //Navigator.of(context).reassemble();
                    });
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
