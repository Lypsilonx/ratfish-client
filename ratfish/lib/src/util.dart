import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import "package:pointycastle/export.dart";

class Util {
  static Uint8List compressAndResizeImage(Uint8List imageData,
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

    img.Image resizedImage =
        img.copyResize(image, width: width, height: height);

    // Compress the image with JPEG format
    List<int> compressedBytes = img.encodeJpg(resizedImage, quality: quality);

    return Uint8List.fromList(compressedBytes);
  }

  static void executeWhenOK(
    Future<String> result,
    BuildContext context, {
    void Function()? onOK,
  }) {
    result.then((result) {
      if (result == "OK") {
        if (onOK != null) onOK();
      } else {
        showErrorScaffold(context, result);
      }
    });
  }

  static Widget imageErrorBuilder(
      BuildContext context, Object error, StackTrace? stackTrace) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxWidth,
          color: Theme.of(context).colorScheme.surface,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 10),
                Text(
                  "Error loading image",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showErrorScaffold(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onError,
        ),
      ),
      showCloseIcon: true,
      backgroundColor: Theme.of(context).colorScheme.error,
    ));
  }

  static Future<bool> confirmDialog(BuildContext context, String title,
      String content, String confirmText) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text(confirmText),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }

  static void popUpDialog(BuildContext context, String title, String content,
      String confirmText, void Function() confirmAction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text(confirmText),
              onPressed: () {
                Navigator.of(context).pop();
                confirmAction();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static void askForString(BuildContext context, String title, String content,
      String confirmText, void Function(String string) confirmAction) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(content),
              TextFormField(
                controller: controller,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(confirmText),
              onPressed: () {
                if (controller.text.isEmpty) {
                  showErrorScaffold(context, "Please enter a value");
                  return;
                }

                Navigator.of(context).pop();
                confirmAction(controller.text);
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class Crypotography {
  // Create an rsa key pair
  static AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAkeyPair(
      SecureRandom secureRandom,
      {int bitLength = 512}) {
    // Create an RSA key generator and initialize it

    final keyGen = RSAKeyGenerator()
      ..init(ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
          secureRandom));

    // Use the generator

    final pair = keyGen.generateKeyPair();

    // Cast the generated key pair into the RSA key types

    final myPublic = pair.publicKey as RSAPublicKey;
    final myPrivate = pair.privateKey as RSAPrivateKey;

    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(myPublic, myPrivate);
  }

  static SecureRandom secureRandom(String password) {
    final secureRandom = FortunaRandom();

    final seeds = <int>[];
    for (int i = 0; i < 32; i++) {
      // add 32 random bytes (from 0 to 255) to the seed by iterating through the password
      seeds.add(min(password.codeUnitAt(i % password.length), 255));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

    return secureRandom;
  }

  static RSAPublicKey parsePublicKey(String publicKey) {
    final parts = publicKey.split(':');
    return RSAPublicKey(
      BigInt.parse(parts[0]),
      BigInt.parse(parts[1]),
    ); // modulus, exponent
  }

  static RSAPrivateKey parsePrivateKey(String privateKey) {
    final parts = privateKey.split(':');
    return RSAPrivateKey(
      BigInt.parse(parts[0]),
      BigInt.parse(parts[1]),
      parts.length > 2 ? BigInt.parse(parts[2]) : null,
      parts.length > 3 ? BigInt.parse(parts[3]) : null,
    ); // modulus, privateExponent, p, q
  }

  static String fromPublicKey(RSAPublicKey publicKey) {
    return "${publicKey.modulus}:${publicKey.exponent}";
  }

  static String fromPrivateKey(RSAPrivateKey privateKey) {
    return "${privateKey.modulus}:${privateKey.privateExponent}${privateKey.p != null ? ":${privateKey.p}" : ""}${privateKey.q != null ? ":${privateKey.q}" : ""}";
  }

  static List<int> rsaEncrypt(String publicKey, String dataToEncrypt) {
    final encryptor = OAEPEncoding(RSAEngine())
      ..init(
          true,
          PublicKeyParameter<RSAPublicKey>(
              parsePublicKey(publicKey))); // true=encrypt

    return _processInBlocks(
        encryptor, Uint8List.fromList(dataToEncrypt.codeUnits));
  }

  static String rsaDecrypt(String privateKey, List<int> cipherText) {
    final decryptor = OAEPEncoding(RSAEngine())
      ..init(
          false,
          PrivateKeyParameter<RSAPrivateKey>(
              parsePrivateKey(privateKey))); // false=decrypt

    return String.fromCharCodes(
        _processInBlocks(decryptor, Uint8List.fromList(cipherText)));
  }

  static Uint8List _processInBlocks(
      AsymmetricBlockCipher engine, Uint8List input) {
    final numBlocks = input.length ~/ engine.inputBlockSize +
        ((input.length % engine.inputBlockSize != 0) ? 1 : 0);

    final output = Uint8List(numBlocks * engine.outputBlockSize);

    var inputOffset = 0;
    var outputOffset = 0;
    while (inputOffset < input.length) {
      final chunkSize = (inputOffset + engine.inputBlockSize <= input.length)
          ? engine.inputBlockSize
          : input.length - inputOffset;

      outputOffset += engine.processBlock(
          input, inputOffset, chunkSize, output, outputOffset);

      inputOffset += chunkSize;
    }

    return (output.length == outputOffset)
        ? output
        : output.sublist(0, outputOffset);
  }
}
