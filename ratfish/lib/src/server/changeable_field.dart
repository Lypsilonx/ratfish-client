import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

enum FieldType {
  SHORT_STRING,
  LONG_STRING,
  IMAGE,
  INT,
  DOUBLE,
  BOOL,
}

enum AccessMode {
  READ,
  WRITE,
  READ_WRITE,
}

class ChangeableField {
  final String name;
  final Function setter;
  final Function getter;
  final FieldType type;
  final AccessMode accessMode;

  ChangeableField(this.name, this.setter, this.getter, this.type,
      {this.accessMode = AccessMode.READ_WRITE});

  Widget renderChangeable(BuildContext context, Function onChange) {
    Uint8List image = Uint8List(0);
    if (type == FieldType.IMAGE) {
      image = base64Decode(getter());
    }

    InputDecoration decoration = InputDecoration(
      labelText: name,
      border: OutlineInputBorder(
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
        child: switch (type) {
          FieldType.SHORT_STRING => TextFormField(
              initialValue: getter(),
              decoration: decoration,
              onChanged: (value) {
                setter(value);
                onChange();
              },
            ),
          FieldType.LONG_STRING => TextFormField(
              initialValue: getter(),
              minLines: 3,
              maxLines: 10,
              decoration: decoration,
              onChanged: (value) {
                setter(value);
                onChange();
              },
            ),
          FieldType.IMAGE => Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image from blob
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  backgroundImage:
                      image.isNotEmpty ? Image.memory(image).image : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    var imagePicker = ImagePicker();
                    var file = await imagePicker.pickImage(
                        source: ImageSource.gallery);
                    if (file != null) {
                      var imageData = await file.readAsBytes();
                      imageData = compressAndResizeImage(imageData, size: 128);
                      setter(base64Encode(imageData));
                      onChange();
                    }
                  },
                  child: const Text("Change Image"),
                ),
              ],
            ),
          FieldType.INT => TextFormField(
              initialValue: getter().toString(),
              decoration: decoration,
              onChanged: (value) {
                setter(int.parse(value));
                onChange();
              },
            ),
          FieldType.DOUBLE => TextFormField(
              initialValue: getter().toString(),
              decoration: decoration,
              onChanged: (value) {
                setter(double.parse(value));
                onChange();
              },
            ),
          FieldType.BOOL => name == "Ready"
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: getter()
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.primary,
                    minimumSize: const Size(200, 50),
                  ),
                  onPressed: () {
                    setter(!getter());
                    onChange();
                  },
                  child: Text(
                    getter() ? "Unready" : "Ready",
                    style: TextStyle(
                      color: getter()
                          ? Theme.of(context).colorScheme.surface
                          : Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                )
              : Column(
                  children: [
                    Text(name),
                    Switch(
                      value: getter(),
                      onChanged: (value) {
                        setter(value);
                        onChange();
                      },
                    ),
                  ],
                ),
        },
      ),
    );
  }

  Widget renderReadonly(BuildContext context) {
    return Center(
      child: switch (type) {
        FieldType.SHORT_STRING => name == "ID"
            ? ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                tileColor: Theme.of(context).colorScheme.primaryContainer,
                title: Text(
                  "$name: ${getter()}",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
                leading: Icon(Icons.copy,
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: getter()));
                },
              )
            : ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                tileColor: Theme.of(context).colorScheme.primaryContainer,
                subtitle: Text(
                  getter(),
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
                title: Text(name,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        )),
              ),
        FieldType.LONG_STRING => ListTile(
            minTileHeight: 100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            tileColor: Theme.of(context).colorScheme.primaryContainer,
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                getter(),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
            ),
            title: Text(
              name,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
          ),
        FieldType.IMAGE => CircleAvatar(
            radius: 60,
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            backgroundImage: getter().isNotEmpty
                ? Image.memory(base64Decode(getter())).image
                : null,
          ),
        FieldType.INT => ListTile(
            subtitle: Text(getter().toString()),
            title: Text(name),
          ),
        FieldType.DOUBLE => ListTile(
            subtitle: Text(getter().toString()),
            title: Text(name),
          ),
        FieldType.BOOL => ListTile(
            subtitle: Text(getter() ? "Yes" : "No"),
            title: Text(name),
          ),
      },
    );
  }
}

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
