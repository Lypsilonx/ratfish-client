class ChatGroup {
  final String id;
  final String name;
  final String? image;

  ChatGroup({
    required this.id,
    required this.name,
    this.image,
  });

  static ChatGroup empty = ChatGroup(
    id: "",
    name: "",
  );

  factory ChatGroup.fromMap(Map<String, dynamic> map) {
    return ChatGroup(
      id: map['id'],
      name: map['name'],
      image: map['image'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
    };
  }
}
