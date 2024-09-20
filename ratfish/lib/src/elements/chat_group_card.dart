import 'package:ratfish/src/elements/server_object_card.dart';
import 'package:ratfish/src/elements/server_object_icon.dart';
import 'package:ratfish/src/server/objects/character.dart';
import 'package:ratfish/src/server/objects/chat_group.dart';
import 'package:ratfish/src/server/client.dart';
import 'package:ratfish/src/server/objects/message.dart';
import 'package:ratfish/src/views/chat_group_view.dart';
import 'package:flutter/material.dart';
import 'package:ratfish/src/views/chat_view.dart';
import 'package:ratfish/src/views/edit_view.dart';
import 'package:ratfish/src/views/inspect_view.dart';

class ChatGroupCard extends ServerObjectCard<ChatGroup> {
  ChatGroupCard(id, {super.key, goto = "info"})
      : super(
          id,
          (ChatGroup chatGroup) =>
              goto == "chat" ? "Group Chat" : chatGroup.name,
          (BuildContext context, ChatGroup chatGroup) {
            if (goto == "info" || goto == "edit") {
              return Text(
                chatGroup.description,
                style: Theme.of(context).textTheme.bodySmall,
              );
            }

            if (goto == "chat") {
              Future<Message?> lastMessage = Client.getChatIdGroup(chatGroup.id)
                  .then((value) => Client.getLastMessage(value));
              Future<Character> character = lastMessage.then(
                (message) =>
                    Client.getServerObject<Character>(message!.senderId),
              );

              return FutureBuilder(
                future: Future.wait([lastMessage, character]),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(
                      "Error loading: Message (${chatGroup.id})\n${snapshot.error}",
                      style: Theme.of(context).textTheme.bodySmall,
                    );
                  }

                  if (snapshot.hasData) {
                    Message? message = snapshot.data![0] as Message?;
                    Character character = snapshot.data![1] as Character;

                    if (message == null) {
                      return const SizedBox();
                    }

                    return Text(
                      "${character.name}: ${message.content}",
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    );
                  }

                  return Text(
                    "",
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              );
            }

            return null;
          },
          (BuildContext context, ChatGroup chatGroup) async {
            switch (goto) {
              case "info":
                await Navigator.pushNamed(
                  context,
                  InspectView.routeName,
                  arguments: {
                    "id": chatGroup.id,
                    "type": (ChatGroup).toString(),
                  },
                );
              case "edit":
                await Navigator.pushNamed(
                  context,
                  EditView.routeName,
                  arguments: {
                    "id": chatGroup.id,
                    "type": (ChatGroup).toString(),
                  },
                );
              case "open":
                await Navigator.pushNamed(context, ChatGroupView.routeName,
                    arguments: {"chatGroupId": chatGroup.id});
                break;
              case "chat":
                var chatId = await Client.getChatIdGroup(chatGroup.id);
                await Navigator.pushNamed(
                  context,
                  ChatView.routeName,
                  arguments: {
                    "chatGroupId": chatGroup.id,
                    "chatId": chatId,
                    "isGroup": true,
                  },
                );
                break;
            }
          },
          trailing: (BuildContext context, ChatGroup chatGroup) {
            if (goto != "open") {
              return const SizedBox();
            }

            Future<Character> character = Client.getCharacterId(
              chatGroup.id,
              Client.instance.self.id,
            ).then(
              (characterId) async => await Client.getServerObject(characterId),
            );

            return FutureBuilder(
              future: character,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Icon(Icons.error);
                }

                if (snapshot.hasData) {
                  return ServerObjectIcon<Character>(
                    snapshot.data!,
                    inspect: true,
                  );
                } else {
                  return const SizedBox();
                }
              },
            );
          },
        );
}
