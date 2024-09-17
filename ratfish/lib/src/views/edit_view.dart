import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

import 'package:ratfish/src/server/client.dart';
import 'package:flutter/material.dart';
import 'package:ratfish/src/server/server_object.dart';
import 'package:image/image.dart' as img;

Uint8List compressAndResizeImage(Uint8List imageData,
    {int size = 800, int quality = 85}) {
  img.Image image = img.decodeImage(imageData.toList())!;

  // Resize the image to have the longer side be 800 pixels
  int width;
  int height;

  if (image.width > image.height) {
    width = size;
    height = (image.height / image.width * size).round();
  } else {
    height = size;
    width = (image.width / image.height * size).round();
  }

  img.Image resizedImage = img.copyResize(image, width: width, height: height);

  // Compress the image with JPEG format
  List<int> compressedBytes = img.encodeJpg(resizedImage, quality: quality);

  return Uint8List.fromList(compressedBytes);
}

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
                            ...serverObject
                                .getChangeableFields()
                                .where((field) =>
                                    field.accessMode != AccessMode.READ)
                                .map(
                              (field) {
                                Uint8List image = Uint8List(0);
                                if (field.type == FieldType.IMAGE) {
                                  image = base64Decode(field.getter());
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: switch (field.type) {
                                    FieldType.SHORT_STRING => TextFormField(
                                        initialValue: field.getter(),
                                        decoration: InputDecoration(
                                          labelText: field.name,
                                        ),
                                        onChanged: (value) {
                                          field.setter(value);
                                        },
                                      ),
                                    FieldType.LONG_STRING => TextFormField(
                                        initialValue: field.getter(),
                                        minLines: 3,
                                        maxLines: 10,
                                        decoration: InputDecoration(
                                          labelText: field.name,
                                        ),
                                        onChanged: (value) {
                                          field.setter(value);
                                        },
                                      ),
                                    FieldType.IMAGE => Row(
                                        children: [
                                          // Image from blob
                                          CircleAvatar(
                                            backgroundImage: image.isNotEmpty
                                                ? Image.memory(image).image
                                                : null,
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              var imagePicker = ImagePicker();
                                              var file =
                                                  await imagePicker.pickImage(
                                                      source:
                                                          ImageSource.gallery);
                                              if (file != null) {
                                                var imageData =
                                                    await file.readAsBytes();
                                                imageData =
                                                    compressAndResizeImage(
                                                        imageData,
                                                        size: 64);
                                                field.setter(
                                                    base64Encode(imageData));
                                                setState(() {});
                                              }
                                            },
                                            child: const Text("Change Image"),
                                          ),
                                        ],
                                      ),
                                    FieldType.INT => TextFormField(
                                        initialValue: field.getter().toString(),
                                        decoration: InputDecoration(
                                          labelText: field.name,
                                        ),
                                        onChanged: (value) {
                                          field.setter(int.parse(value));
                                        },
                                      ),
                                    FieldType.DOUBLE => TextFormField(
                                        initialValue: field.getter().toString(),
                                        decoration: InputDecoration(
                                          labelText: field.name,
                                        ),
                                        onChanged: (value) {
                                          field.setter(double.parse(value));
                                        },
                                      ),
                                    FieldType.BOOL => Switch(
                                        value: field.getter(),
                                        onChanged: (value) {
                                          field.setter(value);
                                        },
                                      ),
                                  },
                                );
                              },
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await Client.setServerObject<T>(
                                    serverObject, widget.id);
                                Navigator.pop(context);
                              },
                              child: const Text("Save"),
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
