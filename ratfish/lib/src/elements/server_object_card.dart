import 'dart:convert';

import 'package:ratfish/src/server/account.dart';
import 'package:ratfish/src/server/character.dart';
import 'package:ratfish/src/server/chat_group.dart';
import 'package:ratfish/src/server/client.dart';
import 'package:flutter/material.dart';
import 'package:ratfish/src/server/server_object.dart';

class ServerObjectCard<T extends ServerObject> extends StatefulWidget {
  final String id;
  final Function getImageData;
  final Function getDisplayName;
  final Function getSubtitle;
  final Function onTap;
  final Function? onLongPress;

  const ServerObjectCard(this.id, this.getImageData, this.getDisplayName,
      this.getSubtitle, this.onTap,
      {super.key, this.onLongPress});

  @override
  State<ServerObjectCard<T>> createState() => _ServerObjectCardState();
}

class _ServerObjectCardState<T extends ServerObject>
    extends State<ServerObjectCard<T>> {
  @override
  Widget build(BuildContext context) {
    Future<T> futureServerObject = Client.getServerObject<T>(widget.id);
    return FutureBuilder<T>(
      future: futureServerObject,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ListTile(
            leading: const Icon(Icons.error),
            title: Text("Error loading: $T (${widget.id})\n${snapshot.error}"),
          );
        }

        if (snapshot.hasData) {
          T serverObject = snapshot.data!;

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
          var icon = Icon(iconData,
              color: Theme.of(context).colorScheme.primary, size: 15);

          return ListTile(
            contentPadding: const EdgeInsets.all(20),
            leading: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  backgroundImage: widget.getImageData(serverObject).isNotEmpty
                      ? Image.memory(
                              base64Decode(widget.getImageData(serverObject)))
                          .image
                      : null,
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
            ),
            title: Text(
              style: Theme.of(context).textTheme.titleMedium,
              widget.getDisplayName(serverObject),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: widget.getSubtitle(serverObject) != ""
                ? Text(
                    style: Theme.of(context).textTheme.bodySmall,
                    widget.getSubtitle(serverObject),
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            onTap: () async {
              widget.onTap(context, serverObject);
            },
          );
        } else {
          return const ListTile(
            leading: CircularProgressIndicator(),
            title: Text("Loading..."),
          );
        }
      },
    );
  }
}
