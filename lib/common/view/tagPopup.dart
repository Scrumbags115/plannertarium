import "package:flutter/material.dart";
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:async';

import '../../models/tag.dart';

/// Display a popup to select a tag with a colorpicker. Takes in the runtime context and an optional callback function to call on update for updating a view as necessary.
Future<List<Tag>> showTagSelectionDialog(BuildContext context,
    {Function? callback}) async {
  List<Tag> selectedTags = [];

  TextEditingController nameController = TextEditingController();
  Color selectedColor = Colors.blue;
  Color pickerColor = Color(0xff443a49);

  void changeColor(Color color) {
    pickerColor = color;
    selectedColor = color;
    if (callback != null) {
      callback(()=>{});
    }
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
