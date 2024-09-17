import 'package:ratfish/src/server/changeable_field.dart';
import 'package:ratfish/src/server/server_object.dart';

class Character extends ServerObject {
  String accountId;
  String chatGroupId;
  String name;
  String image;
  String description;

  Character({
    required super.id,
    required this.accountId,
    required this.chatGroupId,
    required this.name,
    required this.image,
    required this.description,
  });

  static Character empty = Character(
    id: "",
    accountId: "",
    chatGroupId: "",
    name: "",
    image: "",
    description: "",
  );

  factory Character.fromMap(Map<String, dynamic> map) {
    return Character(
      id: map['id'],
      accountId: map['accountId'],
      chatGroupId: map['chatGroupId'],
      name: map['name'],
      image: map['image'] ?? "",
      description: map['description'] ?? "",
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'chatGroupId': chatGroupId,
      'name': name,
      'image': image,
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
    ];
  }
}
