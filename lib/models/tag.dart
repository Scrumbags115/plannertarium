import 'package:collection/collection.dart';

class Tag {
  late String _name = ""; // tag name
  late final String _id; // tag id
  late String _color = "#ff0000"; // tag color in hex
  late List<String> _includedIDs =
      <String>[]; // list of IDs of undertakings with this tag

  /// Default constructor
  /// Primarily for adding to the tags collection in the firestore, but
  /// might replace the current _tags list in the Undertaking class with
  /// a list of Tag objects instead
  Tag({String? name, String? id, String? color, List<String>? includedIDs}) {
    _name = name ?? "";
    _id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
    _color = color ?? "#ff0000";
    _includedIDs = includedIDs ?? <String>[];
  }

  /// Constructor to get a tag obj from some valid map
  /// Good for reading from database
  Tag.fromMap(Map<String, dynamic> map) {
    try {
      _name = map['name'];
      _id = map['id'];
      _color = map['color'];
      _includedIDs = [];
      map['includedIDs'].forEach((id) {
        _includedIDs.add(id.toString());
      });
    } catch (e) {
      throw Exception("Given map is malformed!\n$e");
    }
  }

  /// Alternate constructor so VSCode autogenerates all fields (ty whumsty)
  Tag.requireFields(
      {required String name,
      required String id,
      required String color,
      required List<String> includedIDs}) {
    _name = name;
    _id = id;
    _color = color;
    _includedIDs = includedIDs;
  }

  /// Getters
  String get name => _name;
  String get id => _id;
  String get color => _color;
  List<String> get includedIDs => _includedIDs;

  /// Setters
  set name(String name) => _name = name;
  set color(String color) => _color = color;
  set includedIDs(List<String> includedIDs) => _includedIDs = includedIDs;

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

  /// Operators
  @override
  bool operator ==(Object other) {
    Function eq = const ListEquality().equals;
    return identical(this, other) ||
        (other is Tag &&
            _name == other._name &&
            _id == other._id &&
            _color == other._color &&
            eq(_includedIDs, other._includedIDs)) || super == other;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => Object.hash(_name, _id, _color, _includedIDs);
}
