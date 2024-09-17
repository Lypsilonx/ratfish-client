import 'package:ratfish/src/server/server_object.dart';

class Account extends ServerObject {
  String userName;
  String displayName;
  String image;
  String description;

  final String publicKey;

  Account({
    required super.id,
    required this.userName,
    required this.displayName,
    required this.image,
    required this.description,
    required this.publicKey,
  });

  @override
  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      userName: map['userName'],
      displayName: map['displayName'],
      image: map['image'] ?? "",
      description: map['description'] ?? "",
      publicKey: map['publicKey'] ?? "",
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'displayName': displayName,
      'image': image,
      'description': description,
      'publicKey': publicKey,
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
        "User Name",
        (String value) {
          userName = value;
        },
        () => userName,
        FieldType.SHORT_STRING,
        accessMode: AccessMode.WRITE,
      ),
      ChangeableField(
        "Display Name",
        (String value) {
          displayName = value;
        },
        () => displayName,
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
