import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ratfish/src/server/account.dart';
import 'package:ratfish/src/server/character.dart';
import 'package:ratfish/src/server/chat_group.dart';
import 'package:ratfish/src/server/server_object.dart';

class ServerObjectIcon<T extends ServerObject> extends StatelessWidget {
  const ServerObjectIcon(
    this.serverObject,
    this.getImageData, {
    super.key,
  });

  final T serverObject;
  final Function getImageData;

  @override
  Widget build(BuildContext context) {
    Icon icon = Icon(getIconData<T>(),
        color: Theme.of(context).colorScheme.primary, size: 15);

    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          backgroundImage: getImageData(serverObject).isNotEmpty
              ? Image.memory(base64Decode(getImageData(serverObject))).image
              : null,
        ),
        if (getImageData(serverObject).isEmpty)
          Icon(
            getIconData<T>(),
            color: Theme.of(context).colorScheme.onSecondary,
            size: 25,
          ),
        Padding(
          padding: const EdgeInsets.only(left: 25, top: 25),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 2,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  color: Theme.of(context).colorScheme.surface,
                ),
                height: 22,
                width: 22,
              ),
              icon,
            ],
          ),
        ),
      ],
    );
  }

  static IconData getIconData<T extends ServerObject>() {
    var typeName = T.toString();
    var iconData = Icons.error;
    if (typeName == (Account).toString()) {
      iconData = Icons.person;
    }
    if (typeName == (Character).toString()) {
      iconData = Icons.theater_comedy;
    }
    if (typeName == (ChatGroup).toString()) {
      iconData = Icons.group;
    }
    return iconData;
  }
}
