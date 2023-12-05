import "package:flutter/material.dart";
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:async';

import '../../models/tag.dart';
import '../../view/loginView.dart';
import 'flashError.dart';

/// Display a popup to select a tag with a colorpicker. Takes in the runtime context and an optional setState function to call on update for updating a view as necessary.

Future<List<Tag>> showTagSelectionDialog(BuildContext context,
    {Function? setState}) async {
  List<Tag> selectedTags = [];

  TextEditingController nameController = TextEditingController();
  Color selectedColor = Colors.blue;
  Color pickerColor = const Color(0xff443a49);

  void changeColor(Color color) {
    pickerColor = color;
    selectedColor = color;
    if (setState != null) {
      setState(() {});
    }
  }

  await showDialog(
      context: context,
      builder: (context) => ScaffoldMessenger(
              child: Builder(
            builder: (context) => Scaffold(
                backgroundColor: Colors.transparent,
                body: AlertDialog(
                  title: const Text('Add Tag'),
                  content: SingleChildScrollView(
                      child: SizedBox(
                          height: (MediaQuery.of(context).size.width * 0.7),
                          width: (MediaQuery.of(context).size.height * 0.8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: TextField(
                                  controller: nameController,
                                  decoration: const InputDecoration(
                                      labelText: 'Tag Name'),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text('Tag Color:',
                                        style: TextStyle(
                                          color: Colors.black,
                                        )),
                                  ),
                                  isOnIOSorAndroid()
                                      ? SizedBox(
                                          // temporary, since I can't figure out howo to make colorpicker expand to the right sizes, for some reason it overflows at phone level widths
                                          width: 200,
                                          child: ColorPicker(
                                            pickerColor: pickerColor,
                                            onColorChanged: changeColor,
                                          ),
                                        )
                                      : ColorPicker(
                                          pickerColor: pickerColor,
                                          onColorChanged: changeColor,
                                        ),
                                ],
                              ),
                            ],
                          ))),
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
                          color: selectedColor.value
                              .toString(), // turn color into int
                        );
                        if (selectedTag.name == "") {
                          // name of a tag cannot be an empty string!
                          showFlashError(
                              context, "Name of tag cannot be empty!");
                        } else {
                          selectedTags.add(selectedTag);
                          nameController.clear();
                          Navigator.pop(context, selectedTags);
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                )),
          )));

  return selectedTags;
}
