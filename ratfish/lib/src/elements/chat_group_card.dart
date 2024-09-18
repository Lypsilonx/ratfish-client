import 'package:ratfish/src/elements/server_object_card.dart';
import 'package:ratfish/src/server/chat_group.dart';
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
          (ChatGroup chatGroup) => chatGroup.image,
          (ChatGroup chatGroup) =>
              goto == "chat" ? "Group Chat" : chatGroup.name,
          (ChatGroup chatGroup) => "",
          (BuildContext context, ChatGroup chatGroup) async {
            switch (goto) {
              case "info":
                Navigator.pushNamed(
                  context,
                  InspectView.routeName,
                  arguments: {
                    "id": chatGroup.id,
                    "type": (ChatGroup).toString(),
                  },
                );
              case "edit":
                Navigator.pushNamed(
                  context,
                  EditView.routeName,
                  arguments: {
                    "id": chatGroup.id,
                    "type": (ChatGroup).toString(),
                  },
                );
              case "open":
                Navigator.pushNamed(context, ChatGroupView.routeName,
                    arguments: {"chatGroupId": chatGroup.id});
                break;
              case "chat":
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
                break;
            }
          },
        );
}
