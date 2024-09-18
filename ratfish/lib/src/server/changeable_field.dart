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
    return Center(
      child: switch (type) {
        FieldType.SHORT_STRING => TextFormField(
            initialValue: getter(),
            decoration: InputDecoration(
              labelText: name,
            ),
            onChanged: (value) {
              setter(value);
              onChange();
            },
          ),
        FieldType.LONG_STRING => TextFormField(
            initialValue: getter(),
            minLines: 3,
            maxLines: 10,
            decoration: InputDecoration(
              labelText: name,
            ),
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
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                backgroundImage:
                    image.isNotEmpty ? Image.memory(image).image : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  var imagePicker = ImagePicker();
                  var file =
                      await imagePicker.pickImage(source: ImageSource.gallery);
                  if (file != null) {
                    var imageData = await file.readAsBytes();
                    imageData = compressAndResizeImage(imageData, size: 64);
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
            decoration: InputDecoration(
              labelText: name,
            ),
            onChanged: (value) {
              setter(int.parse(value));
              onChange();
            },
          ),
        FieldType.DOUBLE => TextFormField(
            initialValue: getter().toString(),
            decoration: InputDecoration(
              labelText: name,
            ),
            onChanged: (value) {
              setter(double.parse(value));
              onChange();
            },
          ),
        FieldType.BOOL => name == "Ready"
            ? ElevatedButton(
                onPressed: () {
                  setter(!getter());
                  onChange();
                },
                child: Text(getter() ? "Unready" : "Ready"),
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
    );
  }

  Widget renderReadonly(BuildContext context) {
    return switch (type) {
      FieldType.SHORT_STRING => name == "ID"
          ? ListTile(
              subtitle: Text(getter()),
              title: Text(name),
              leading: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: getter()));
                },
              ),
            )
          : ListTile(
              subtitle: Text(getter()),
              title: Text(name),
            ),
      FieldType.LONG_STRING => ListTile(
          subtitle: Text(getter()),
          title: Text(name),
        ),
      FieldType.IMAGE => CircleAvatar(
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
    };
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
