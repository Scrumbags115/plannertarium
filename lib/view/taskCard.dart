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
  late List<Tag> tagList;
  final StreamController<List<Tag>> tagListStream = StreamController();
  
  @override
  void initState() {
    super.initState();
    updateTagList();
  }

  /// Get the latest list of tags and input it into the streambuilder controller
  void updateTagList() async {
    List<Tag> newTagList = [];
    for (final String tagID in widget.task.tags) {
      newTagList.add(await db.getTag(tagID));
    }
    tagListStream.add(newTagList);
  }

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
                onTap: () {
                  setState(() {
                    widget.task.completed = !widget.task.completed;
                    db.setTask(widget.task);
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
                children: <Widget>[
                  Text(widget.task.description),
                  StreamBuilder<List<Tag>>(
                      stream: tagListStream.stream,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Tag>> snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          // setState(() {});
                          // not sure what to do here
                        }
                        if (snapshot.hasData) {
                          List<Chip> chipList = [];
                          for (final Tag tag in (snapshot.data!)) {
                            Chip tagChip = Chip(
                                label: Text(tag.name),
                                backgroundColor: Color(int.parse(tag.color)));
                            chipList.add(tagChip);
                          }
                          return Wrap(spacing: 8.0, children: chipList);
                        }
                        return const Text('Loading...');
                      }),
                ],
              ),
            )),
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

  Future<Tag?> showExistingTag() async {
    Completer<Tag?> completer = Completer<Tag?>();
    List<Tag> userTags = await db.getAllTags();
    print(userTags);
    void showTagDialog(BuildContext dialogContext) {
      showDialog(
        context: dialogContext,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Existing Tag'),
            content: SingleChildScrollView(
              child: SizedBox(
                height: (MediaQuery.of(dialogContext).size.height * 0.5),
                width: (MediaQuery.of(dialogContext).size.width * 0.8),
                child: ListView.builder(
                  itemCount: userTags.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(userTags[index].name),
                      onTap: () {
                        Navigator.of(context).pop();
                        completer.complete(userTags[index]);
                      },
                    );
                  },
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
            ],
          );
        },
      );
    }

    // Call the function with the current BuildContext
    showTagDialog(context);

    return completer.future;
  }

  Future<Tag?> showTagSelectionDialog(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    Color selectedColor = Colors.blue; // Default color
    Color pickerColor = Color(0xff443a49);

    void changeColor(Color color) {
      setState(() {
        pickerColor = color;
        selectedColor = color; // Update the selectedColor as well
      });
    }

    return showDialog(
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
                    const Text('Tag Color:'),
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
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Tag selectedTag = Tag(
                    name: nameController.text, color: selectedColor.toString());
                print(selectedColor.toString());
                Navigator.pop(context, selectedTag);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
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

    List<Tag> enteredTags = []; // Use a list to store multiple tags

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
                        decoration: const InputDecoration(
                          labelText: 'Tag',
                          suffixIcon: Icon(Icons.keyboard_arrow_down),
                        ),
                        onTap: () async {
                          Tag? result = await showTagSelectionDialog(context);
                          if (result != null) {
                            setState(() {
                              enteredTags.add(result);
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
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  enteredTags.removeAt(index);
                                });
                              },
                              child: Container(
                                height: 50,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 10),
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      enteredTags[index].name,
                                    ),
                                  ],
                                ),
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

                    List<String> tags =
                        enteredTags.map((tag) => tag.name).toList();

                    widget.task.tags = tags;
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
