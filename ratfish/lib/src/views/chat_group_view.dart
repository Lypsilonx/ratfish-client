import 'package:ratfish/src/elements/character_card.dart';
import 'package:ratfish/src/elements/chat_group_card.dart';
import 'package:ratfish/src/server/character.dart';
import 'package:ratfish/src/server/client.dart';
import 'package:ratfish/src/elements/nav_bar.dart';
import 'package:ratfish/src/server/chat_group.dart';
import 'package:flutter/material.dart';
import 'package:ratfish/src/views/edit_view.dart';

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
    Future<ChatGroup> chatGroup =
        Client.getServerObject<ChatGroup>(widget.chatGroupId);
    Future<bool> isLocked = Client.getChatGroupLocked(widget.chatGroupId);
    return FutureBuilder(
      future: Future.wait([chatGroup, isLocked]),
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
          var chatGroup = snapshot.data![0] as ChatGroup;
          var locked = snapshot.data![1] as bool;
          var chatGroupAccountIds = Client.getChatGroupAccountIds(chatGroup.id);

          return Scaffold(
            appBar: AppBar(
              title: ChatGroupCard(chatGroup.id, goto: "edit"),
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
                        if (!locked)
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 40),
                            child: ChatGroupCard(chatGroup.id, goto: "chat"),
                          ),
                        ...accountIds
                            .where(
                          (accountId) =>
                              (!locked) || accountId == Client.instance.self.id,
                        )
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
                                    child: CharacterCard(
                                      characterId,
                                      chatGroupId: chatGroup.id,
                                      openEditView:
                                          accountId == Client.instance.self.id,
                                      locked: locked,
                                    ),
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
                        if (locked)
                          ListTile(
                            leading: const Icon(Icons.lock),
                            title: const Text("This chat group is locked."),
                            subtitle: Text("${accountIds.length} members"),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                Navigator.pushNamed(
                                  context,
                                  EditView.routeName,
                                  arguments: {
                                    "type": (Character).toString(),
                                    "id": await Client.getCharacterId(
                                        chatGroup.id, Client.instance.self.id),
                                  },
                                );
                              },
                            ),
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
