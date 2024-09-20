import 'package:ratfish/src/elements/character_card.dart';
import 'package:ratfish/src/elements/chat_group_card.dart';
import 'package:ratfish/src/elements/server_object_icon.dart';
import 'package:ratfish/src/server/objects/account.dart';
import 'package:ratfish/src/server/client.dart';
import 'package:ratfish/src/elements/nav_bar.dart';
import 'package:ratfish/src/server/objects/chat_group.dart';
import 'package:flutter/material.dart';
import 'package:ratfish/src/util.dart';

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

          Future<int> readyAccounts = Client.getReadyCount(chatGroup.id);

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

                    Future<List<Account>> accounts = Future.wait(accountIds.map(
                        (accountId) =>
                            Client.getServerObject<Account>(accountId)));

                    return ListView(
                      controller: ScrollController(),
                      children: [
                        FutureBuilder(
                          future: accounts,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return ListTile(
                                  title: Text(
                                      "Error loading accounts: ${snapshot.error}"));
                            }

                            if (snapshot.hasData) {
                              List<Account> accounts = snapshot.data!;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ...accounts.map(
                                          (account) =>
                                              ServerObjectIcon<Account>(
                                            account,
                                            inspect: true,
                                          ),
                                        )
                                      ],
                                    ),
                                    Text(
                                      accounts
                                          .map((account) => account.displayName)
                                          .toList()
                                          .niceJoin(),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return const ListTile(
                                leading: CircularProgressIndicator(),
                                title: Text("Loading..."),
                              );
                            }
                          },
                        ),
                        if (!locked) ChatGroupCard(chatGroup.id, goto: "chat"),
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
                                        "Error loading character: $characterId (${snapshot.error})"),
                                  );
                                }

                                if (snapshot.hasData) {
                                  var characterId = snapshot.data!;
                                  return CharacterCard(
                                    characterId,
                                    chatGroupId: chatGroup.id,
                                    openEditView:
                                        accountId == Client.instance.self.id,
                                    locked: locked,
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
                          SizedBox(
                            height: 400,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.lock, size: 40),
                                  const SizedBox(height: 20),
                                  const Text("This chat group is locked"),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      accountIds.length < 3
                                          ? const Icon(Icons.close,
                                              color: Colors.red)
                                          : const Icon(Icons.check,
                                              color: Colors.green),
                                      const Text("min player ammount"),
                                    ],
                                  ),
                                  FutureBuilder(
                                    future: readyAccounts,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            snapshot.data! < accountIds.length
                                                ? const Icon(Icons.close,
                                                    color: Colors.red)
                                                : const Icon(Icons.check,
                                                    color: Colors.green),
                                            Text(
                                                "(${snapshot.data!}/${accountIds.length}) ready"),
                                          ],
                                        );
                                      } else {
                                        return const Text("Loading...");
                                      }
                                    },
                                  ),
                                ],
                              ),
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
