import 'dart:convert';

import 'package:flutter/material.dart';
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
    Icon icon = Icon(ServerObject.getIconData<T>(),
        color: Theme.of(context).colorScheme.primary, size: 15);

    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          backgroundImage: getImageData(serverObject).isNotEmpty
              ? Image.memory(base64Decode(getImageData(serverObject))).image
              : null,
        ),
        if (getImageData(serverObject).isEmpty)
          Icon(
            ServerObject.getIconData<T>(),
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
                    color: Theme.of(context).colorScheme.primary,
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
}
