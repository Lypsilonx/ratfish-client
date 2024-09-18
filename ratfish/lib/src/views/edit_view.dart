import 'package:ratfish/src/server/changeable_field.dart';
import 'package:ratfish/src/server/client.dart';
import 'package:flutter/material.dart';
import 'package:ratfish/src/server/server_object.dart';
import 'package:ratfish/src/util.dart';

class EditView<T extends ServerObject> extends StatefulWidget {
  final String id;

  const EditView(this.id, {super.key});

  static const routeName = '/edit';

  @override
  State<EditView<T>> createState() => _EditViewState<T>();
}

class _EditViewState<T extends ServerObject> extends State<EditView<T>> {
  ScrollController scrollController = ScrollController();
  T? cachedServerObject;
  bool dirty = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        Future<T> futureServerObject;
        if (cachedServerObject == null) {
          futureServerObject = Client.getServerObject<T>(widget.id);
        } else {
          futureServerObject = Future.value(cachedServerObject!);
        }
        return Scaffold(
          appBar: AppBar(
            title: Text("Edit ${T.toString()}"),
            leading: dirty
                ? IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: () {
                      Util.executeWhenOK(
                          Client.setServerObject<T>(
                              cachedServerObject!, widget.id),
                          context);
                      Navigator.pop(context);
                    },
                  )
                : null,
          ),
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
                cachedServerObject = serverObject;

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
                            ...serverObject.getChangeableFields().map(
                              (field) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: field.accessMode == AccessMode.READ
                                      ? field.renderReadonly(context)
                                      : field.renderChangeable(
                                          context,
                                          () {
                                            setState(() {
                                              dirty = true;
                                            });
                                          },
                                        ),
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
