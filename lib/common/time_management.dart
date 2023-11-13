import 'package:cloud_firestore/cloud_firestore.dart';

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

DateTime getDateOnly(DateTime dateTime, {int offset = 0}) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day + offset);
}
