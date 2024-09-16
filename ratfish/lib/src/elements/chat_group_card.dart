import 'package:ratfish/src/server/chatGroup.dart';
import 'package:ratfish/src/server/client.dart';
import 'package:ratfish/src/util.dart';
import 'package:ratfish/src/views/chat_group_view.dart';
import 'package:flutter/material.dart';

class ChatGroupCard extends StatefulWidget {
  final String chatGroupId;

  ChatGroupCard(this.chatGroupId);

  @override
  State<ChatGroupCard> createState() => _ChatGroupCardState();
}

class _ChatGroupCardState extends State<ChatGroupCard> {
  @override
  Widget build(BuildContext context) {
    Future<ChatGroup> chatGroup = Client.getChatGroup(widget.chatGroupId);
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
                  (chatGroup.image != null && chatGroup.image != "")
                      ? NetworkImage(chatGroup.image!)
                      : null,
            ),
            title: Text(
              style: Theme.of(context).textTheme.titleMedium,
              chatGroup.name,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.pushNamed(context, ChatGroupView.routeName,
                  arguments: {"chatGroupId": chatGroup.id});
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
