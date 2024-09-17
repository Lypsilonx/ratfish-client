import 'package:ratfish/src/server/server_object.dart';

class Message extends ServerObject {
  final String chatId;
  final String senderId;
  String content;
  final String timestamp;

  Message({
    required super.id,
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

  @override
  List<ChangeableField> getChangeableFields() {
    return [
      ChangeableField("Content", (value) => content = value, () => content,
          FieldMode.LONG_STRING),
    ];
  }

  @override
  List<ViewableField> getVieweableFields() {
    return [
      ViewableField("Content", () => content, FieldMode.LONG_STRING),
    ];
  }
}
