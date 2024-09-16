import 'dart:convert';

import 'package:ratfish/src/server/account.dart';
import 'package:ratfish/src/server/chat.dart';
import 'package:ratfish/src/server/chatGroup.dart';
import 'package:ratfish/src/server/message.dart';
import 'package:ratfish/src/server/response.dart';
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
      var request =
          "http://politischdekoriert.de/ratfish-api/endpoint.php?data=${Uri.encodeComponent(jsonEncode(data))}";
      var response = await http.read(Uri.parse(request));
      return Response.fromString(response);
    } catch (e) {
      return Response(400, {"message": "Failed to connect to server\n$e"});
    }
  }

  static Future<String> update() async {
    var account = await getAccount(SettingsController.instance.userId);
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

  static Future<String> logout() async {
    await SettingsController.instance.updatePrivateKey("");
    await SettingsController.instance.updateUserId("");
    await SettingsController.instance.updateAccessToken("");
    _instance = null;
    return "OK";
  }

  // Getters
  static Future<Account> getAccount(String userId) async {
    var response = await get(
      {
        "action": "getAccount",
        "userId": userId,
      },
    );

    if (response.statusCode != 200) {
      return Account.empty;
    }

    return Account.fromMap(response.body);
  }

  static Future<ChatGroup> getChatGroup(String chatGroupId) async {
    var response = await get(
      {
        "action": "getChatGroup",
        "chatGroupId": chatGroupId,
      },
    );

    if (response.statusCode != 200) {
      return ChatGroup.empty;
    }

    return ChatGroup.fromMap(response.body);
  }

  static Future<Chat> getChat(String chatId) async {
    var response = await get(
      {
        "action": "getChat",
        "chatId": chatId,
      },
    );

    if (response.statusCode != 200) {
      return Chat.empty;
    }

    return Chat.fromMap(response.body);
  }

  static Future<Message> getMessage(String messageId) async {
    var response = await get(
      {
        "action": "getMessage",
        "messageId": messageId,
      },
    );

    if (response.statusCode != 200) {
      return Message.empty;
    }

    return Message.fromMap(response.body);
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

  // Setters
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

    return "OK";
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
}
