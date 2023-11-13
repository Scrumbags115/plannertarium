import 'package:flutter/material.dart';
import 'package:planner/view/weekView.dart';

class monthView extends StatelessWidget {
  const monthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
            ),
            itemCount: 30,
            itemBuilder: (BuildContext context, int index) {
              return MultiDayCard(index + 1 - DateTime.now().day);
            }));
  }
}
