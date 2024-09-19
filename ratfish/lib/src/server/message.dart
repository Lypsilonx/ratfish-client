import 'package:ratfish/src/server/changeable_field.dart';
import 'package:ratfish/src/server/server_object.dart';

class Message extends ServerObject {
  final String type;
  final String chatId;
  final String senderId;
  String content;
  String media;
  String editTimestamp;
  String replyMessage;
  final String timestamp;

  Message({
    required super.id,
    required this.type,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.media,
    required this.editTimestamp,
    required this.replyMessage,
    required this.timestamp,
  });

  static Message empty = Message(
    id: "",
    type: "",
    chatId: "",
    senderId: "",
    content: "",
    media: "",
    editTimestamp: "",
    replyMessage: "",
    timestamp: "",
  );

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      type: map['type'] ?? "text",
      chatId: map['chatId'],
      senderId: map['senderId'],
      content: map['content'],
      media: map['media'] ?? "",
      editTimestamp: map['editTimestamp'] ?? "",
      replyMessage: map['replyMessage'] ?? "",
      timestamp: map['timestamp'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'media': media,
      'editTimestamp': editTimestamp,
      'replyMessage': replyMessage,
      'timestamp': timestamp,
    };
  }

  @override
  List<ChangeableField> getChangeableFields() {
    return [
      ChangeableField("Content", (value) {
        content = value;
        editTimestamp = DateTime.now().millisecondsSinceEpoch.toString();
      }, () => content, FieldType.LONG_STRING),
    ];
  }
}
