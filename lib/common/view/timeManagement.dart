import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

///A DatePicker function to prompt a calendar
///Returns a selectedDate if chosen, default value else
Future<DateTime?> datePicker(context,
    {DateTime? initialDate, DateTime? defaultDate}) async {
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
  return defaultDate;
}

/// returns the number of 24 hour sections between 2 dates
int daysBetween(DateTime from, DateTime to) {
  from = getDateOnly(from);
  to = getDateOnly(to);
  return (to.difference(from).inHours / 24).round();
}

DateTime toDateIfTimestamp(dynamic t) {
  if (t is Timestamp) {
    return t.toDate();
  } else if (t is DateTime) {
    return t;
  }
  throw Exception("Trying to get Date out of $t");
}

DateTime getDateOnly(DateTime dateTime,
    {int offsetDays = 0, int offsetMonths = 0}) {
  return DateTime(
      dateTime.year, dateTime.month + offsetMonths, dateTime.day + offsetDays);
}

void verifyDateStartEnd(DateTime start, DateTime end) {
  if (!start.isBefore(end)) {
    throw Exception("Bad time window, start: $start is not before end: $end");
  }
}

DateTime mostRecentMonday(DateTime date) {
  return getDateOnly(date, offsetDays: (1 - date.weekday));
}

DateTime getMonthAsDateTime(DateTime day) {
  return DateTime(day.year, day.month, 1);
}

DateTime getNextMonthAsDateTime(DateTime day) {
  return DateTime(day.year, day.month + 1, 1);
}

String getDateAsString(DateTime day) {
  return "${day.month}/${day.day}/${day.year}";
}

String getTimeAsString(DateTime time) {
  return "${time.hour % 12}:${time.minute} ${time.hour < 12 ? 'AM' : 'PM'} ${time.month}/${time.day}/${time.year}";
}
