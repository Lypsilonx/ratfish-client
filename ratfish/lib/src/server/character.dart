class Character {
  String id;
  String accountId;
  String chatGroupId;
  String name;
  String avatar;
  String description;

  Character({
    required this.id,
    required this.accountId,
    required this.chatGroupId,
    required this.name,
    required this.avatar,
    required this.description,
  });

  static Character empty = Character(
    id: "",
    accountId: "",
    chatGroupId: "",
    name: "",
    avatar: "",
    description: "",
  );

  factory Character.fromMap(Map<String, dynamic> map) {
    return Character(
      id: map['id'],
      accountId: map['accountId'],
      chatGroupId: map['chatGroupId'],
      name: map['name'],
      avatar: map['avatar'] ?? "",
      description: map['description'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'chatGroupId': chatGroupId,
      'name': name,
      'avatar': avatar,
      'description': description,
    };
  }
}
