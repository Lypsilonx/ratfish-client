import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:ratfish/src/elements/account_card.dart';
import 'package:ratfish/src/elements/chat_group_card.dart';
import 'package:ratfish/src/server/chatGroup.dart';
import 'package:ratfish/src/server/client.dart';
import 'package:flutter/material.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as chat_ui;
import 'package:ratfish/src/server/message.dart';

class ChatView extends StatefulWidget {
  final String chatGroupId;
  final String chatId;

  final types.User _sender = types.User(id: Client.instance.self.id);

  ChatView(this.chatId, this.chatGroupId, {super.key});

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
      var message = await Client.getMessage(messageId);

      _messages.add(
        types.TextMessage(
          id: messageId,
          author: types.User(id: message.senderId),
          createdAt: int.parse(message.timestamp),
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
    Future<ChatGroup> futureChatGroup = Client.getChatGroup(widget.chatGroupId);
    return FutureBuilder(
      future: Future.wait([futureChatMemberIds, futureChatGroup]),
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

          bool isGroup = chatMemberIds.length != 2;
          String id = isGroup
              ? chatGroup.id
              : chatMemberIds
                  .firstWhere((element) => element != Client.instance.self.id);

          return Scaffold(
            appBar: AppBar(
              title: isGroup ? ChatGroupCard(id) : AccountCard(id),
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
                  emptyState: messagesLoaded
                      ? const Center(child: Text("No messages"))
                      : const Center(child: CircularProgressIndicator()),
                  messages: messagesLoaded ? _messages : _messagesCache,
                  onSendPressed: (message) => _handleSendPressed(message, id),
                  user: widget._sender,
                  theme: RatfishChatTheme.fromTheme(Theme.of(context)),
                  customMessageBuilder: (message, {required int messageWidth}) {
                    switch (message.type) {
                      case types.MessageType.text:
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(message.metadata!["content"]),
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

  void _addMessage(types.Message message, String recipientId) async {
    switch (message.type) {
      case types.MessageType.text:
        await Client.addMessage(
          Message(
            id: message.id,
            chatId: widget.chatId,
            senderId: widget._sender.id,
            content: (message as types.TextMessage).text,
            timestamp: "",
          ),
        );
        break;
      default:
        break;
    }
    updateChat();
  }

  void _handleSendPressed(types.PartialText message, String recipientId) {
    final textMessage = types.TextMessage(
      author: widget._sender,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );

    _addMessage(textMessage, recipientId);
  }

  String randomString() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }
}
