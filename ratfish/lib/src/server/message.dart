class Message {
  final String id;
  final String text;
  final DateTime createdAt;
  final String senderId;

  Message({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.senderId,
  });

  static Message empty = Message(
    id: "",
    text: "",
    createdAt: DateTime.now(),
    senderId: "",
  );

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      text: map['text'],
      createdAt: DateTime.parse(map['createdAt']),
      senderId: map['senderId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'senderId': senderId,
    };
  }
}
