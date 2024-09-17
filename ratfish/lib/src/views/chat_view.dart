import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:ratfish/src/elements/character_card.dart';
import 'package:ratfish/src/elements/chat_group_card.dart';
import 'package:ratfish/src/server/character.dart';
import 'package:ratfish/src/server/chat_group.dart';
import 'package:ratfish/src/server/client.dart';
import 'package:flutter/material.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as chat_ui;
import 'package:ratfish/src/server/message.dart';
import 'package:ratfish/src/views/edit_view.dart';

class ChatView extends StatefulWidget {
  final String chatGroupId;
  final String chatId;
  final bool isGroup;

  const ChatView(this.chatGroupId, this.chatId, this.isGroup, {super.key});

  static const routeName = '/chat';

  @override
  State<ChatView> createState() => _ChatViewState();
}

class RatfishChatTheme {
  static chat_ui.ChatTheme fromTheme(ThemeData theme) {
    return chat_ui.DefaultChatTheme(
      inputBackgroundColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      primaryColor: theme.colorScheme.primary,
      secondaryColor: theme.colorScheme.secondary,
      inputTextColor: theme.colorScheme.onPrimary,
      emptyChatPlaceholderTextStyle: TextStyle(
        color: theme.colorScheme.onSurface,
      ),
      dateDividerTextStyle: TextStyle(
        color: theme.colorScheme.onSurface,
      ),
    );
  }
}

class _ChatViewState extends State<ChatView> {
  ScrollController scrollController = ScrollController();
  final List<types.Message> _messages = [];
  final List<types.Message> _messagesCache = [];
  bool messagesLoaded = false;
  late Timer updateTimer;

  @override
  void initState() {
    super.initState();

    updateChat();
    //call updateChat every 20 seconds
    updateTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      updateChat();
    });
  }

  @override
  void dispose() {
    updateTimer.cancel();
    super.dispose();
  }

  Future<void> updateChat() async {
    setState(() {
      _messagesCache.clear();
      _messagesCache.addAll(_messages);
      messagesLoaded = false;
      _messages.clear();
    });

    var messageIds = await Client.getChatMessages(widget.chatId);

    for (var messageId in messageIds) {
      var message = await Client.getServerObject<Message>(messageId);
      _messages.add(
        types.TextMessage(
          id: messageId,
          author: types.User(id: message.senderId),
          createdAt: int.parse(message.timestamp),
          updatedAt: message.editTimestamp != ""
              ? int.parse(message.editTimestamp)
              : null,
          text: message.content,
        ),
      );
    }

    // sort messages by date
    _messages.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

    setState(() {
      messagesLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<List<String>> futureChatMemberIds =
        Client.getChatMembers(widget.chatId);
    Future<ChatGroup> futureChatGroup =
        Client.getServerObject<ChatGroup>(widget.chatGroupId);
    Future<String> futureCharacterId =
        Client.getCharacterId(widget.chatGroupId, Client.instance.self.id);
    return FutureBuilder(
      future: Future.wait(
          [futureChatMemberIds, futureChatGroup, futureCharacterId]),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: ListTile(
              leading: const Icon(Icons.error),
              title: Text(
                  "Error loading chat: ${widget.chatId},${widget.chatGroupId} (${snapshot.error})"),
            ),
          );
        }

        if (snapshot.hasData) {
          ChatGroup chatGroup = snapshot.data![1] as ChatGroup;
          List<String> chatMemberIds = snapshot.data![0] as List<String>;
          String characterId = snapshot.data![2] as String;

          String id = widget.isGroup
              ? chatGroup.id
              : chatMemberIds.firstWhere((element) => element != characterId);

          return Scaffold(
            appBar: AppBar(
              title: widget.isGroup
                  ? ChatGroupCard(id, goto: "info")
                  : CharacterCard(chatMemberIds.firstWhere(
                      (element) => element != characterId,
                    )),
              actions: [
                SizedBox(
                  width: 55,
                  child: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: updateChat,
                  ),
                ),
              ],
            ),
            body: Stack(
              children: [
                chat_ui.Chat(
                  showUserAvatars: widget.isGroup,
                  avatarBuilder: (user) {
                    return FutureBuilder(
                      future: Client.getServerObject<Character>(user.id),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          Character character = snapshot.data!;
                          return Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: CircleAvatar(
                              backgroundImage: character.image.isNotEmpty
                                  ? Image.memory(base64Decode(character.image))
                                      .image
                                  : null,
                            ),
                          );
                        } else {
                          return const Padding(
                            padding: EdgeInsets.only(right: 20),
                            child: CircleAvatar(),
                          );
                        }
                      },
                    );
                  },
                  emptyState: messagesLoaded
                      ? const Center(child: Text("No messages"))
                      : const Center(child: CircularProgressIndicator()),
                  messages: messagesLoaded ? _messages : _messagesCache,
                  onSendPressed: (message) =>
                      _handleSendPressed(message, characterId, id),
                  user: types.User(id: characterId),
                  theme: RatfishChatTheme.fromTheme(Theme.of(context)),
                  onMessageLongPress: (context, message) async {
                    if (message.author.id ==
                        await Client.getCharacterId(
                            widget.chatGroupId, Client.instance.self.id)) {
                      Navigator.of(context).pushNamed(
                        EditView.routeName,
                        arguments: {
                          "type": (Message).toString(),
                          "id": message.id,
                        },
                      );
                    }
                  },
                  textMessageBuilder: (message,
                      {required int messageWidth, required bool showName}) {
                    switch (message.type) {
                      case types.MessageType.text:
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(children: [
                            Text(message.text,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: 16,
                                )),
                            if (message.updatedAt != null)
                              Text(
                                "Edited",
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                          ]),
                        );
                      default:
                        return const Text("Unknown message type");
                    }
                  },
                ),
                SizedBox(
                  height: 2,
                  width: 430,
                  child: messagesLoaded
                      ? null
                      : const Center(child: LinearProgressIndicator()),
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            body: ListTile(
              leading: const CircularProgressIndicator(),
              title: Text("Loading... (${widget.chatId})"),
            ),
          );
        }
      },
    );
  }

  void _addMessage(
      types.Message message, String characterId, String recipientId) async {
    switch (message.type) {
      case types.MessageType.text:
        await Client.addMessage(
          Message(
            id: message.id,
            chatId: widget.chatId,
            senderId: characterId,
            content: (message as types.TextMessage).text,
            editTimestamp: "",
            timestamp: "",
          ),
        );
        break;
      default:
        break;
    }
    updateChat();
  }

  void _handleSendPressed(
      types.PartialText message, String characterId, String recipientId) {
    final textMessage = types.TextMessage(
      author: types.User(id: characterId),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );

    _addMessage(textMessage, characterId, recipientId);
  }

  String randomString() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }
}
