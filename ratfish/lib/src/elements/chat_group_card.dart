import 'package:ratfish/src/elements/server_object_card.dart';
import 'package:ratfish/src/elements/server_object_icon.dart';
import 'package:ratfish/src/server/objects/character.dart';
import 'package:ratfish/src/server/objects/chat_group.dart';
import 'package:ratfish/src/server/client.dart';
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
          (ChatGroup chatGroup) => "",
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
            Future<Character> character = Client.getCharacterId(
              chatGroup.id,
              Client.instance.self.id,
            ).then(
              (characterId) async => await Client.getServerObject(characterId),
            );

            return goto == "open"
                ? FutureBuilder(
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
                  )
                : const SizedBox();
          },
        );
}
