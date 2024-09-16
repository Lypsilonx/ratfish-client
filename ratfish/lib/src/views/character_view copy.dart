import 'package:ratfish/src/server/character.dart';
import 'package:ratfish/src/server/client.dart';
import 'package:ratfish/src/elements/character_card.dart';
import 'package:flutter/material.dart';

class CharacterView extends StatefulWidget {
  final String characterId;

  const CharacterView(this.characterId, {super.key});

  static const routeName = '/character';

  @override
  State<CharacterView> createState() => _CharacterViewState();
}

class _CharacterViewState extends State<CharacterView> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        Future<Character> character = Client.getCharacter(widget.characterId);
        return Scaffold(
          appBar: AppBar(),
          body: FutureBuilder<Character>(
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

                return ListView(
                  controller: ScrollController(),
                  children: [
                    SizedBox(
                      width: constraints.maxWidth,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CharacterCard(
                              widget.characterId,
                            ),
                            const SizedBox(height: 20),
                            Text(character.description),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return ListTile(
                  leading: const CircularProgressIndicator(),
                  title: Text("Loading... (${widget.characterId})"),
                );
              }
            },
          ),
        );
      },
    );
  }
}
