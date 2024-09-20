import 'package:flutter/material.dart';
import 'package:ratfish/src/server/objects/account.dart';
import 'package:ratfish/src/server/changeable_field.dart';
import 'package:ratfish/src/server/objects/character.dart';
import 'package:ratfish/src/server/objects/chat_group.dart';
import 'package:ratfish/src/server/objects/message.dart';

abstract class ServerObject {
  String id;
  String image;

  ServerObject({required this.id, required this.image});

  List<ChangeableField> getChangeableFields();

  static final Map<Type,
      (String className, IconData iconData, Function fromMap)> _typeMap = {
    Account: ('Account', Icons.person, Account.fromMap),
    Character: ('Character', Icons.theater_comedy, Character.fromMap),
    ChatGroup: ('ChatGroup', Icons.group, ChatGroup.fromMap),
    Message: ('Message', Icons.message, Message.fromMap),
  };

  static String getClassName<T extends ServerObject>() {
    return _typeMap[T]!.$1;
  }

  static IconData getIconData<T extends ServerObject>() {
    return _typeMap[T]!.$2;
  }

  static T fromMap<T extends ServerObject>(Map<String, dynamic> map) {
    return _typeMap[T]!.$3(map) as T;
  }

  Map<String, dynamic> toMap();
}
