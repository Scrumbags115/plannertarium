import 'package:flutter/material.dart';

///A DatePicker function to prompt a calendar
///Returns a selectedDate if chosen, default value else
Future<DateTime?> datePicker(context, {DateTime? initialDate, DateTime? defaultDateTime}) async {
  initialDate ??= DateTime.now();
  DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
  );

  if (selectedDate != null) {
    return selectedDate;
  }
  return defaultDateTime;
}