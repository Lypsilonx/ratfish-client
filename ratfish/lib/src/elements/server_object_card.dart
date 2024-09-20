import 'package:ratfish/src/elements/server_object_icon.dart';
import 'package:ratfish/src/server/client.dart';
import 'package:flutter/material.dart';
import 'package:ratfish/src/server/server_object.dart';

class ServerObjectCard<T extends ServerObject> extends StatefulWidget {
  final String id;
  final Function getDisplayName;
  final Function getSubtitle;
  final Future<void> Function(BuildContext context, T serverObject) onTap;
  final Function? onLongPress;
  final Widget Function(BuildContext context, T serverObject)? trailing;

  const ServerObjectCard(
      this.id, this.getDisplayName, this.getSubtitle, this.onTap,
      {super.key, this.onLongPress, this.trailing});

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
          return ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding:
                const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
            leading: ServerObjectIcon<T>(serverObject),
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
            trailing: widget.trailing != null
                ? widget.trailing!(context, serverObject)
                : null,
            onTap: () async {
              widget.onTap(context, serverObject).then(
                (value) async {
                  await Client.getServerObject<T>(widget.id).then((value) {
                    setState(() {
                      serverObject = value;
                    });
                  });
                },
              );
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
