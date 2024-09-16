import 'package:ratfish/src/elements/character_card.dart';
import 'package:ratfish/src/elements/chat_group_card.dart';
import 'package:ratfish/src/server/client.dart';
import 'package:ratfish/src/elements/nav_bar.dart';
import 'package:ratfish/src/server/chatGroup.dart';
import 'package:flutter/material.dart';

class ChatGroupView extends StatefulWidget {
  final String chatGroupId;

  const ChatGroupView(this.chatGroupId, {super.key});

  static const routeName = '/chat_group';

  @override
  State<ChatGroupView> createState() => _ChatGroupViewState();
}

class _ChatGroupViewState extends State<ChatGroupView> {
  @override
  Widget build(BuildContext context) {
    Future<ChatGroup> chatGroup = Client.getChatGroup(widget.chatGroupId);
    return FutureBuilder<ChatGroup>(
      future: chatGroup,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            bottomNavigationBar: NavBar(ChatGroupView.routeName),
            body: ListTile(
              leading: const Icon(Icons.error),
              title: Text(
                  "Error loading chat: ${widget.chatGroupId} (${snapshot.error})"),
            ),
          );
        }

        if (snapshot.hasData) {
          var chatGroup = snapshot.data!;
          var chatGroupAccountIds = Client.getChatGroupAccountIds(chatGroup.id);

          return Scaffold(
            appBar: AppBar(
              title: Text(
                chatGroup.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: FutureBuilder(
                future: chatGroupAccountIds,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return ListTile(
                      leading: const Icon(Icons.error),
                      title: Text(
                          "Error loading chat group accounts: ${chatGroup.id} (${snapshot.error})"),
                    );
                  }

                  if (snapshot.hasData) {
                    var accountIds = snapshot.data!;
                    return ListView(
                      controller: ScrollController(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 40),
                          child: ChatGroupCard(chatGroup.id, openChat: true),
                        ),
                        ...accountIds
                            .where((accountId) =>
                                accountId != Client.instance.self.id)
                            .map(
                          (accountId) {
                            Future<String> characterId =
                                Client.getCharacterId(chatGroup.id, accountId);
                            return FutureBuilder(
                              future: characterId,
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return ListTile(
                                    leading: const Icon(Icons.error),
                                    title: Text(
                                        "Error loading character: ${chatGroup.id} (${snapshot.error})"),
                                  );
                                }

                                if (snapshot.hasData) {
                                  var characterId = snapshot.data!;
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 40),
                                    child: CharacterCard(characterId,
                                        chatGroupId: chatGroup.id),
                                  );
                                } else {
                                  return const ListTile(
                                    leading: CircularProgressIndicator(),
                                    title: Text("Loading..."),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ],
                    );
                  } else {
                    return Scaffold(
                      body: ListTile(
                        leading: const CircularProgressIndicator(),
                        title: Text("Loading... (${chatGroup.id})"),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        } else {
          return Scaffold(
            body: ListTile(
              leading: const CircularProgressIndicator(),
              title: Text("Loading... (${widget.chatGroupId})"),
            ),
          );
        }
      },
    );
  }
}
