import 'package:ratfish/src/server/changeable_field.dart';
import 'package:ratfish/src/server/server_object.dart';

class ChatGroup extends ServerObject {
  String name;
  String description;

  ChatGroup({
    required super.id,
    required super.image,
    required this.name,
    required this.description,
  });

  static ChatGroup empty = ChatGroup(
    id: "",
    image: "",
    name: "",
    description: "",
  );

  factory ChatGroup.fromMap(Map<String, dynamic> map) {
    return ChatGroup(
      id: map['id'],
      image: map['image'] ?? "",
      name: map['name'],
      description: map['description'] ?? "",
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image,
      'name': name,
      'description': description,
    };
  }

  @override
  List<ChangeableField> getChangeableFields() {
    return [
      ChangeableField(
        "Image",
        (String value) {
          image = value;
        },
        () => image,
        FieldType.IMAGE,
      ),
      ChangeableField(
        "Name",
        (String value) {
          name = value;
        },
        () => name,
        FieldType.SHORT_STRING,
      ),
      ChangeableField(
        "Description",
        (String value) {
          description = value;
        },
        () => description,
        FieldType.LONG_STRING,
      ),
      ChangeableField(
        "ID",
        (String value) {},
        () => id,
        FieldType.SHORT_STRING,
        accessMode: AccessMode.READ,
      ),
    ];
  }
}
