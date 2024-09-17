import 'package:ratfish/src/server/server_object.dart';

class ChatGroup extends ServerObject {
  String name;
  String image;

  ChatGroup({
    required super.id,
    required this.name,
    required this.image,
  });

  static ChatGroup empty = ChatGroup(
    id: "",
    name: "",
    image: "",
  );

  factory ChatGroup.fromMap(Map<String, dynamic> map) {
    return ChatGroup(
      id: map['id'],
      name: map['name'],
      image: map['image'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
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
    ];
  }
}
