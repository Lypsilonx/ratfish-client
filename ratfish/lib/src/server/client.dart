import 'dart:convert';

import 'package:ratfish/src/server/objects/account.dart';
import 'package:ratfish/src/server/objects/message.dart';
import 'package:ratfish/src/server/response.dart';
import 'package:ratfish/src/server/server_object.dart';
import 'package:ratfish/src/settings/settings_controller.dart';

import 'package:http/http.dart' as http;
import 'package:ratfish/src/util.dart';

class Client {
  static Client? _instance;
  static Client get instance => _instance!;
  late Account self;

  Client(this.self) {
    _instance = this;
  }

  static Future<Response> get(Map<String, String> data) async {
    try {
      var request = "https://politischdekoriert.de/ratfish-api/endpoint.php";
      var serverResponse =
          await http.post(Uri.parse(request), body: jsonEncode(data));
      var response = Response.fromString(serverResponse.body);
      if (response.statusCode != 200) {
        print(response.body);
      }
      return response;
    } catch (e) {
      return Response(400, {"message": "Failed to connect to server\n$e"});
    }
  }

  static Future<String> update() async {
    var account =
        await getServerObject<Account>(SettingsController.instance.userId);
    if (account.id == "") {
      return "Failed to update user data";
    }
    Client(account);
    return "OK";
  }

  static Future<String> register(
      String userName, String password, String confirmPassword) async {
    if (userName == "" || password == "" || confirmPassword == "") {
      return "Invalid input";
    }

    if (password != confirmPassword) {
      return "Passwords do not match";
    }

    var response = await get(
      {
        "action": "register",
        "userName": userName,
        "password": password,
      },
    );

    if (response.statusCode != 200) {
      return response.body["message"];
    }

    return await login(userName, password);
  }

  static Future<String> login(String userName, String password) async {
    if (userName == "" || password == "") {
      return "No username or password";
    }

    var response = await get(
      {
        "action": "login",
        "userName": userName,
        "password": password,
      },
    );

    if (response.statusCode != 200) {
      return response.body["message"];
    }

    await SettingsController.instance.updateUserId(response.body["userId"]);
    await SettingsController.instance
        .updateAccessToken(response.body["accessToken"]);

    var result = await update();
    if (result != "OK") {
      return result;
    }

    final keyPair = Crypotography.generateRSAkeyPair(
        Crypotography.secureRandom(password + Client.instance.self.id));

    final publicKey = Crypotography.fromPublicKey(keyPair.publicKey);
    final privateKey = Crypotography.fromPrivateKey(keyPair.privateKey);

    await SettingsController.instance.updatePrivateKey(privateKey);
    return await setPublicKey(publicKey);
  }

  static Future<String> changePassword(
      String oldPassword, String newPassword, String confirmPassword) async {
    if (newPassword != confirmPassword) {
      return "Passwords do not match";
    }

    var response = await get(
      {
        "action": "changePassword",
        "userName": instance.self.userName,
        "oldPassword": oldPassword,
        "newPassword": newPassword,
      },
    );

    if (response.statusCode != 200) {
      return response.body["message"];
    }

    return "OK";
  }

  static Future<String> logout() async {
    await SettingsController.instance.updatePrivateKey("");
    await SettingsController.instance.updateUserId("");
    await SettingsController.instance.updateAccessToken("");
    _instance = null;
    return "OK";
  }

  static Future<String> deleteAccount() async {
    var response = await get(
      {
        "action": "deleteAccount",
        "userId": instance.self.id,
        "accessToken": SettingsController.instance.accessToken,
      },
    );

    if (response.statusCode != 200) {
      return response.body["message"];
    }

    return await logout();
  }

  // Getters
  static Future<T> getServerObject<T extends ServerObject>(String id) async {
    var response = await get(
      {
        "action": "get${ServerObject.getClassName<T>()}",
        "id": id,
      },
    );

    if (response.statusCode != 200) {
      return Future.error(response.body["message"]);
    }

    return ServerObject.fromMap<T>(response.body);
  }

  static Future<List<String>> getChatMembers(String chatId) async {
    var response = await get(
      {
        "action": "getChatMembers",
        "chatId": chatId,
      },
    );

    if (response.statusCode != 200) {
      return [];
    }

    return response.body["characterIds"].cast<String>();
  }

  static Future<List<String>> getChatMessages(String chatId) async {
    var response = await get(
      {"action": "getChatMessages", "chatId": chatId},
    );

    if (response.statusCode != 200) {
      return [];
    }

    return response.body["messageIds"].cast<String>();
  }

  static Future<List<Message>> getChatMessagesFull(String chatId) async {
    var response = await get(
      {"action": "getChatMessagesFull", "chatId": chatId},
    );

    if (response.statusCode != 200) {
      return [];
    }

    return response.body["messages"].map<Message>((e) {
      return Message.fromMap(e);
    }).toList() as List<Message>;
  }

  static getChatIdGroup(String chatGroupId) async {
    var response = await get(
      {
        "action": "getChatIdGroup",
        "chatGroupId": chatGroupId,
      },
    );

    if (response.statusCode != 200) {
      return "";
    }

    return response.body["chatId"];
  }

  static getChatIdCharacter(String chatGroupId, String characterId) async {
    var response = await get(
      {
        "action": "getChatIdCharacter",
        "userId": instance.self.id,
        "chatGroupId": chatGroupId,
        "characterId": characterId,
      },
    );

    if (response.statusCode != 200) {
      return "";
    }

    return response.body["chatId"];
  }

  static Future<List<String>> getChatGroupIds() async {
    var response = await get(
      {
        "action": "getChatGroupIds",
        "userId": instance.self.id,
      },
    );

    if (response.statusCode != 200) {
      return [];
    }

    return response.body["chatGroupIds"].cast<String>();
  }

  static Future<List<String>> getChatGroupAccountIds(String chatGroupId) async {
    var response = await get(
      {
        "action": "getChatGroupAccountIds",
        "chatGroupId": chatGroupId,
      },
    );

    if (response.statusCode != 200) {
      return [];
    }

    return response.body["accountIds"].cast<String>();
  }

  static Future<bool> getChatGroupLocked(String chatGroupId) async {
    var response = await get(
      {
        "action": "getChatGroupLocked",
        "chatGroupId": chatGroupId,
      },
    );

    if (response.statusCode != 200) {
      return false;
    }

    return response.body["locked"];
  }

  static Future<int> getReadyCount(String chatGroupId) async {
    var response = await get(
      {
        "action": "getReadyCount",
        "chatGroupId": chatGroupId,
      },
    );

    if (response.statusCode != 200) {
      return 0;
    }

    return response.body["readyCount"];
  }

  static Future<String> getCharacterId(
      String chatGroupId, String accountId) async {
    var response = await get(
      {
        "action": "getCharacterId",
        "userId": accountId,
        "chatGroupId": chatGroupId,
      },
    );

    if (response.statusCode != 200) {
      return "";
    }

    return response.body["characterId"];
  }

  // Setters
  static Future<String> setServerObject<T extends ServerObject>(
      T serverObject, String id) async {
    var response = await get(
      {
        "action": "set${ServerObject.getClassName<T>()}",
        "id": id,
        "userId": instance.self.id,
        "accessToken": SettingsController.instance.accessToken,
        "data": jsonEncode(serverObject.toMap()),
      },
    );

    if (response.statusCode != 200) {
      return response.body["message"];
    }

    return "OK";
  }

  static Future<String> createChatGroup(String name) async {
    var response = await get(
      {
        "action": "createChatGroup",
        "userId": instance.self.id,
        "accessToken": SettingsController.instance.accessToken,
        "name": name,
      },
    );

    if (response.statusCode != 200) {
      return response.body["message"];
    }

    return joinChatGroup(response.body["chatGroupId"].toString());
  }

  static Future<String> joinChatGroup(String chatGroupId) async {
    var response = await get(
      {
        "action": "joinChatGroup",
        "userId": instance.self.id,
        "accessToken": SettingsController.instance.accessToken,
        "chatGroupId": chatGroupId,
      },
    );

    if (response.statusCode != 200) {
      return response.body["message"];
    }

    return "OK";
  }

  static Future<String> leaveChatGroup(String chatGroupId) async {
    var response = await get(
      {
        "action": "leaveChatGroup",
        "userId": instance.self.id,
        "accessToken": SettingsController.instance.accessToken,
        "chatGroupId": chatGroupId,
      },
    );

    if (response.statusCode != 200) {
      return response.body["message"];
    }

    return "OK";
  }

  static Future<String> setPublicKey(String publicKey) async {
    if (instance.self.publicKey == publicKey) {
      return "OK";
    }

    var response = await get(
      {
        "action": "setPublicKey",
        "userId": instance.self.id,
        "accessToken": SettingsController.instance.accessToken,
        "publicKey": publicKey,
      },
    );

    if (response.statusCode != 200) {
      return response.body["message"];
    }

    return await update();
  }

  static Future<String> addMessage(Message message) async {
    var response = await get(
      {
        "action": "addMessage",
        "userId": instance.self.id,
        "accessToken": SettingsController.instance.accessToken,
        "message": jsonEncode(message.toMap()),
      },
    );

    if (response.statusCode != 200) {
      return response.body["message"];
    }

    return "OK";
  }

  static Future<String> deleteMessage(
      String characterId, String messageId) async {
    var response = await get(
      {
        "action": "deleteMessage",
        "userId": instance.self.id,
        "accessToken": SettingsController.instance.accessToken,
        "characterId": characterId,
        "messageId": messageId,
      },
    );

    if (response.statusCode != 200) {
      return response.body["message"];
    }

    return "OK";
  }
}
