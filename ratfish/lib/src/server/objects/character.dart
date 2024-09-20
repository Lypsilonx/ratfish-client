import 'package:ratfish/src/server/changeable_field.dart';
import 'package:ratfish/src/server/server_object.dart';

class Character extends ServerObject {
  String accountId;
  String chatGroupId;
  String name;
  String pronouns;
  String description;
  bool ready = false;

  Character({
    required super.id,
    required super.image,
    required this.accountId,
    required this.chatGroupId,
    required this.name,
    required this.pronouns,
    required this.description,
    required this.ready,
  });

  static Character empty = Character(
    id: "",
    image: "",
    accountId: "",
    chatGroupId: "",
    name: "",
    pronouns: "",
    description: "",
    ready: false,
  );

  factory Character.fromMap(Map<String, dynamic> map) {
    return Character(
        id: map['id'],
        image: map['image'] ?? "",
        accountId: map['accountId'] ?? "",
        chatGroupId: map['chatGroupId'] ?? "",
        name: map['name'],
        pronouns: map['pronouns'] ?? "",
        description: map['description'] ?? "",
        ready: map['ready'] == "1");
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image,
      'accountId': accountId,
      'chatGroupId': chatGroupId,
      'name': name,
      'pronouns': pronouns,
      'description': description,
      'ready': ready,
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
        "Pronouns",
        (String value) {
          pronouns = value;
        },
        () => pronouns,
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
        "Ready",
        (bool value) {
          ready = value;
        },
        () => ready,
        FieldType.BOOL,
        accessMode: AccessMode.WRITE,
      ),
    ];
  }
}
