import 'package:ratfish/src/elements/server_object_card.dart';
import 'package:ratfish/src/server/objects/character.dart';
import 'package:ratfish/src/server/client.dart';
import 'package:ratfish/src/server/objects/message.dart';
import 'package:ratfish/src/views/inspect_view.dart';
import 'package:ratfish/src/views/chat_view.dart';
import 'package:flutter/material.dart';
import 'package:ratfish/src/views/edit_view.dart';

class CharacterCard extends ServerObjectCard<Character> {
  CharacterCard(id,
      {super.key, chatGroupId = "", openEditView = false, locked = false})
      : super(
          id,
          (Character character) => openEditView
              ? locked
                  ? character.ready
                      ? "Edit"
                      : "Create Character"
                  : "You"
              : character.name,
          (BuildContext context, Character character) {
            if (openEditView) {
              return null;
            }

            if (chatGroupId == "") {
              if (character.pronouns == "") {
                return null;
              }
              return Text(
                character.description,
                style: Theme.of(context).textTheme.bodySmall,
              );
            }

            Future<Message?> lastMessage =
                Client.getChatIdCharacter(character.id)
                    .then((value) => Client.getLastMessage(value));

            return FutureBuilder(
              future: lastMessage,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(
                    "Error loading: Message (${character.id})\n${snapshot.error}",
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                }

                if (snapshot.hasData) {
                  Message? message = snapshot.data! as Message?;

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
          },
          (BuildContext context, Character character) async {
            if (chatGroupId == "") {
              await Navigator.pushNamed(context, InspectView.routeName,
                  arguments: {
                    "type": (Character).toString(),
                    "id": character.id
                  });
            } else if (openEditView) {
              await Navigator.pushNamed(
                  context, locked ? EditView.routeName : InspectView.routeName,
                  arguments: {
                    "type": (Character).toString(),
                    "id": character.id,
                  });
            } else {
              var chatId = await Client.getChatIdCharacter(character.id);
              await Navigator.pushNamed(
                context,
                ChatView.routeName,
                arguments: {
                  "chatGroupId": chatGroupId,
                  "chatId": chatId,
                  "isGroup": false,
                },
              );
            }
          },
        );
}
