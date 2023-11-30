import 'package:collection/collection.dart';

class Tag {
  late String _name = ""; // tag name
  late final String _id; // tag id
  late String _color = "#ff0000"; // tag color in hex
  late Map<String, List<String>> _includedIDs = {
    'task': [],
    'event': []
  }; // Map of type to IDs of objects of that type with this tag

  /// Default constructor
  /// Primarily for adding to the tags collection in the firestore, but
  /// might replace the current _tags list in the Undertaking class with
  /// a list of Tag objects instead
  Tag(
      {String? name,
      String? id,
      String? color,
      Map<String, List<String>>? includedIDs}) {
    _name = name ?? "";
    _id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
    _color = color ?? "#ff0000";
    _includedIDs = includedIDs ?? {};
  }

  /// Constructor to get a tag obj from some valid map
  /// Good for reading from database
  Tag.fromMap(Map<String, dynamic> map) {
    try {
      _name = map['name'];
      _id = map['id'];
      _color = map['color'];
      _includedIDs = {};
      for (final key in map['includedIDs'].keys) {
        _includedIDs[key] = [];
        for (final task_string in map["includedIDs"][key]) {
          _includedIDs[key]?.add(task_string);
        }
      }
    } catch (e) {
      throw Exception("Given map is malformed!\n$e");
    }
  }

  /// Alternate constructor so VSCode autogenerates all fields (ty whumsty)
  Tag.requireFields(
      {required String name,
      required String id,
      required String color,
      required Map<String, List<String>> includedIDs}) {
    _name = name;
    _id = id;
    _color = color;
    _includedIDs = includedIDs;
  }

  /// Getters
  String get name => _name;
  String get id => _id;
  String get color => _color;
  Map<String, List<String>> get includedIDs => _includedIDs;

  /// Setters
  set name(String name) => _name = name;
  set color(String color) => _color = color;
  set includedIDs(Map<String, List<String>> includedIDs) =>
      _includedIDs = includedIDs;

  /// Convert to map
  /// Could be used later
  Map<String, dynamic> toMap() {
    return {
      'name': _name,
      'id': _id,
      'color': _color,
      'includedIDs': _includedIDs,
    };
  }

  /// check if two includedID values are the same
  bool includedIDEquals(Map<String, List<String>> first, Map<String, List<String>> second) {
    // combine all the keys into one set
    Function eq = const ListEquality().equals;
    Set<String> keys = first.keys.toSet();
    keys.union(second.keys.toSet());
    for (final String typeString in keys) {
      if ((first[typeString]??[]).isEmpty && (second[typeString]??[]).isEmpty) {
        continue;
      }
      if (!eq(first[typeString], second[typeString])) {
        return false;
      }
    }
    return true;
  }
  /// Operators
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Tag) return false;

    return identical(this, other) ||
        (_name == other._name &&
            _id == other._id &&
            _color == other._color &&
            includedIDEquals(_includedIDs, other._includedIDs)) ||
        super == other;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => Object.hash(_name, _id, _color, _includedIDs);
}

/// Given some tags separated by commas, separates them into a list of strings without whitespace
List<String> tagCSVToList(String csv) {
  List<String> tagsWithWhitespace = csv.split(",");
  for (int i = 0; i < tagsWithWhitespace.length; i++) {
    tagsWithWhitespace[i] = tagsWithWhitespace[i].trim();
  }
  tagsWithWhitespace.removeWhere((tag) => tag == "");
  return tagsWithWhitespace;
}
