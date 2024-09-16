import 'package:ratfish/src/server/character.dart';
import 'package:ratfish/src/server/client.dart';
import 'package:ratfish/src/views/character_view.dart';
import 'package:ratfish/src/views/chat_view.dart';
import 'package:flutter/material.dart';

class CharacterCard extends StatefulWidget {
  final String characterId;
  final String chatGroupId;

  const CharacterCard(this.characterId, {super.key, this.chatGroupId = ""});

  @override
  State<CharacterCard> createState() => _CharacterCardState();
}

class _CharacterCardState extends State<CharacterCard> {
  @override
  Widget build(BuildContext context) {
    Future<Character> character = Client.getCharacter(widget.characterId);
    return FutureBuilder<Character>(
      future: character,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ListTile(
            leading: const Icon(Icons.error),
            title: Text(
                "Error loading character: ${widget.characterId} (${snapshot.error})"),
          );
        }

        if (snapshot.hasData) {
          Character character = snapshot.data!;

          return ListTile(
            contentPadding: const EdgeInsets.all(20),
            leading: CircleAvatar(
              backgroundImage: character.avatar != ""
                  ? NetworkImage(character.avatar)
                  : null,
            ),
            title: Text(
              style: Theme.of(context).textTheme.titleMedium,
              character.name,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () async {
              if (widget.chatGroupId == "") {
                Navigator.pushNamed(context, CharacterView.routeName,
                    arguments: {"characterId": character.id});
              } else {
                var chatId = await Client.getChatIdCharacter(
                    widget.chatGroupId, character.id);
                Navigator.pushNamed(
                  context,
                  ChatView.routeName,
                  arguments: {
                    "chatGroupId": widget.chatGroupId,
                    "chatId": chatId,
                    "isGroup": false,
                  },
                );
              }
            },
          );
        } else {
          return ListTile(
            leading: const CircularProgressIndicator(),
            title: Text("Loading... (${widget.characterId})"),
          );
        }
      },
    );
  }
}
