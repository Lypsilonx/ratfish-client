import 'dart:convert';

import 'package:ratfish/src/server/client.dart';
import 'package:flutter/material.dart';
import 'package:ratfish/src/server/server_object.dart';

class InspectView<T extends ServerObject> extends StatefulWidget {
  final String id;

  const InspectView(this.id, {super.key});

  static const routeName = '/inspect';

  @override
  State<InspectView<T>> createState() => _InspectViewState<T>();
}

class _InspectViewState<T extends ServerObject> extends State<InspectView<T>> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        Future<T> futureServerObject = Client.getServerObject<T>(widget.id);
        return Scaffold(
          appBar: AppBar(),
          body: FutureBuilder<T>(
            future: futureServerObject,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return ListTile(
                  leading: const Icon(Icons.error),
                  title:
                      Text("Error loading: ${widget.id} (${snapshot.error})"),
                );
              }

              if (snapshot.hasData) {
                T serverObject = snapshot.data!;

                return ListView(
                  controller: ScrollController(),
                  children: [
                    SizedBox(
                      width: constraints.maxWidth,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...serverObject.getVieweableFields().map(
                              (field) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: switch (field.viewMode) {
                                    FieldMode.SHORT_STRING => ListTile(
                                        title: Text(field.getter()),
                                        subtitle: Text(field.name),
                                      ),
                                    FieldMode.LONG_STRING => ListTile(
                                        title: Text(field.getter()),
                                        subtitle: Text(field.name),
                                      ),
                                    FieldMode.IMAGE => CircleAvatar(
                                        backgroundImage:
                                            field.getter().isNotEmpty
                                                ? Image.memory(base64Decode(
                                                        field.getter()))
                                                    .image
                                                : null,
                                      ),
                                    FieldMode.INT => ListTile(
                                        title: Text(field.getter().toString()),
                                        subtitle: Text(field.name),
                                      ),
                                    FieldMode.DOUBLE => ListTile(
                                        title: Text(field.getter().toString()),
                                        subtitle: Text(field.name),
                                      ),
                                    FieldMode.BOOL => ListTile(
                                        title:
                                            Text(field.getter() ? "Yes" : "No"),
                                        subtitle: Text(field.name),
                                      ),
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return ListTile(
                  leading: const CircularProgressIndicator(),
                  title: Text("Loading... (${widget.id})"),
                );
              }
            },
          ),
        );
      },
    );
  }
}
