import 'package:ratfish/src/elements/server_object_card.dart';
import 'package:ratfish/src/server/objects/character.dart';
import 'package:ratfish/src/server/client.dart';
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
          (Character character) => openEditView ? "" : character.pronouns,
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
              var chatId =
                  await Client.getChatIdCharacter(chatGroupId, character.id);
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
