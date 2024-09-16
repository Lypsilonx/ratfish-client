class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final String timestamp;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.timestamp,
  });

  static Message empty = Message(
    id: "",
    chatId: "",
    senderId: "",
    content: "",
    timestamp: "",
  );

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      chatId: map['chatId'],
      senderId: map['senderId'],
      content: map['content'],
      timestamp: map['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp,
    };
  }
}
