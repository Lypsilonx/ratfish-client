import 'package:ratfish/src/server/server_object.dart';

class Message extends ServerObject {
  final String chatId;
  final String senderId;
  String content;
  String editTimestamp;
  final String timestamp;

  Message({
    required super.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.editTimestamp,
    required this.timestamp,
  });

  static Message empty = Message(
    id: "",
    chatId: "",
    senderId: "",
    content: "",
    editTimestamp: "",
    timestamp: "",
  );

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      chatId: map['chatId'],
      senderId: map['senderId'],
      content: map['content'],
      editTimestamp: map['editTimestamp'] ?? "",
      timestamp: map['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'editTimestamp': editTimestamp,
      'timestamp': timestamp,
    };
  }

  @override
  List<ChangeableField> getChangeableFields() {
    return [
      ChangeableField("Content", (value) {
        content = value;
        editTimestamp = DateTime.now().microsecondsSinceEpoch.toString();
      }, () => content, FieldType.LONG_STRING),
    ];
  }
}
