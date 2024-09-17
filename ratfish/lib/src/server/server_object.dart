import 'package:ratfish/src/server/account.dart';
import 'package:ratfish/src/server/changeable_field.dart';
import 'package:ratfish/src/server/character.dart';
import 'package:ratfish/src/server/chat_group.dart';
import 'package:ratfish/src/server/message.dart';

abstract class ServerObject {
  String id;

  ServerObject({required this.id});

  List<ChangeableField> getChangeableFields();

  static T fromMap<T extends ServerObject>(Map<String, dynamic> map) {
    var typeName = T.toString();
    if (typeName == (Account).toString()) {
      return Account.fromMap(map) as T;
    } else if (typeName == (Character).toString()) {
      return Character.fromMap(map) as T;
    } else if (typeName == (ChatGroup).toString()) {
      return ChatGroup.fromMap(map) as T;
    } else if (typeName == (Message).toString()) {
      return Message.fromMap(map) as T;
    } else {
      throw UnimplementedError();
    }
  }

  Map<String, dynamic> toMap();
}
