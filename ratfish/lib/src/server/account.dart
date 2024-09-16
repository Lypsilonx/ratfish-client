class Account {
  String id;
  String userName;
  String displayName;
  String avatar;
  String description;

  String publicKey;

  Account({
    required this.id,
    required this.userName,
    required this.displayName,
    required this.avatar,
    required this.description,
    required this.publicKey,
  });

  static Account empty = Account(
    id: "",
    userName: "",
    displayName: "",
    avatar: "",
    description: "",
    publicKey: "",
  );

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      userName: map['userName'],
      displayName: map['displayName'],
      avatar: map['avatar'] ?? "",
      description: map['description'] ?? "",
      publicKey: map['publicKey'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'displayName': displayName,
      'avatar': avatar,
      'description': description,
      'publicKey': publicKey,
    };
  }
}
