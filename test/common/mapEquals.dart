import 'package:flutter/foundation.dart';
import 'package:planner/models/task.dart';

bool myMapEquals(Map<DateTime, List<Task>> m1, Map<DateTime, List<Task>> m2) {
  if (m1.keys.length != m2.keys.length) {
    return false;
  }
  for (DateTime key in m1.keys) {
    if (!setEquals(m1[key]!.toSet(), m2[key]!.toSet())) {
      return false;
    }
  }
  return true;
}