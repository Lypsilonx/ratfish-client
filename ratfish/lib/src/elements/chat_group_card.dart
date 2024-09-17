import 'dart:convert';

import 'package:ratfish/src/server/chat_group.dart';
import 'package:ratfish/src/server/client.dart';
import 'package:ratfish/src/util.dart';
import 'package:ratfish/src/views/chat_group_view.dart';
import 'package:flutter/material.dart';
import 'package:ratfish/src/views/chat_view.dart';

class ChatGroupCard extends StatefulWidget {
  final String chatGroupId;
  final bool openChat;

  const ChatGroupCard(this.chatGroupId, {this.openChat = false, super.key});

  @override
  State<ChatGroupCard> createState() => _ChatGroupCardState();
}

class _ChatGroupCardState extends State<ChatGroupCard> {
  @override
  Widget build(BuildContext context) {
    Future<ChatGroup> chatGroup =
        Client.getServerObject<ChatGroup>(widget.chatGroupId);
    return FutureBuilder<ChatGroup>(
      future: chatGroup,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ListTile(
            leading: const Icon(Icons.error),
            title: Text(
                "Error loading chat: ${widget.chatGroupId} (${snapshot.error})"),
          );
        }

        if (snapshot.hasData) {
          ChatGroup chatGroup = snapshot.data!;

          return ListTile(
            contentPadding: const EdgeInsets.all(20),
            leading: CircleAvatar(
              backgroundImage:
                  chatGroup.image.isNotEmpty && chatGroup.image != ""
                      ? Image.memory(base64Decode(chatGroup.image)).image
                      : null,
            ),
            title: Text(
              style: Theme.of(context).textTheme.titleMedium,
              chatGroup.name,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () async {
              if (!widget.openChat) {
                Navigator.pushNamed(context, ChatGroupView.routeName,
                    arguments: {"chatGroupId": chatGroup.id});
              } else {
                var chatId = await Client.getChatIdGroup(chatGroup.id);
                Navigator.pushNamed(
                  context,
                  ChatView.routeName,
                  arguments: {
                    "chatGroupId": chatGroup.id,
                    "chatId": chatId,
                    "isGroup": true,
                  },
                );
              }
            },
            onLongPress: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Leave chat group?"),
                    content: Text(
                        "Are you sure you want to leave the chat group ${chatGroup.name}?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          Util.executeWhenOK(
                            Client.leaveChatGroup(chatGroup.id),
                            context,
                            onOK: () {
                              Navigator.pop(context);

                              Navigator.pushNamedAndRemoveUntil(
                                  context, "/", (route) => false);
                            },
                          );
                        },
                        child: const Text("Leave"),
                      ),
                    ],
                  );
                },
              );
            },
          );
        } else {
          return ListTile(
            leading: const CircularProgressIndicator(),
            title: Text("Loading... (${widget.chatGroupId})"),
          );
        }
      },
    );
  }
}
