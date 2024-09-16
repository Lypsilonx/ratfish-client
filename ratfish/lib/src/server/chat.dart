class Chat {
  final String id;
  final List<String> memberIds;
  final List<String> messageIds;

  Chat({
    required this.id,
    required this.memberIds,
    required this.messageIds,
  });

  static Chat empty = Chat(
    id: "",
    memberIds: [],
    messageIds: [],
  );

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'],
      memberIds: map['memberIds'],
      messageIds: map['messageIds'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberIds': memberIds,
      'messageIds': messageIds,
    };
  }
}
