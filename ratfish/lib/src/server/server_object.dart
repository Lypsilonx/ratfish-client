import 'package:ratfish/src/server/account.dart';
import 'package:ratfish/src/server/character.dart';
import 'package:ratfish/src/server/chat_group.dart';
import 'package:ratfish/src/server/message.dart';

abstract class ServerObject {
  String id;

  ServerObject({required this.id});

  List<ChangeableField> getChangeableFields();
  List<ViewableField> getVieweableFields();

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

class ChangeableField {
  final String name;
  final Function setter;
  final Function getter;
  final FieldMode changeMode;

  ChangeableField(this.name, this.setter, this.getter, this.changeMode);
}

class ViewableField {
  final String name;
  final Function getter;
  final FieldMode viewMode;

  ViewableField(this.name, this.getter, this.viewMode);
}

enum FieldMode {
  SHORT_STRING,
  LONG_STRING,
  IMAGE,
  INT,
  DOUBLE,
  BOOL,
}
