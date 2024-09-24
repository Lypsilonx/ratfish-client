import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ratfish/src/server/server_object.dart';
import 'package:ratfish/src/views/inspect_view.dart';

class ServerObjectIcon<T extends ServerObject> extends StatelessWidget {
  const ServerObjectIcon(
    this.serverObject, {
    super.key,
    this.inspect = false,
  });

  final T serverObject;
  final bool inspect;

  @override
  Widget build(BuildContext context) {
    Icon icon = Icon(ServerObject.getIconData<T>(),
        color: Theme.of(context).colorScheme.primary, size: 15);

    return GestureDetector(
      onTap: () async {
        if (inspect) {
          Navigator.pushNamed(
            context,
            InspectView.routeName,
            arguments: {
              "id": serverObject.id,
              "type": (T).toString(),
            },
          );
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            backgroundImage: serverObject.image.isNotEmpty
                ? Image.memory(base64Decode(serverObject.image)).image
                : null,
          ),
          if (serverObject.image.isEmpty)
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
      ),
    );
  }
}
