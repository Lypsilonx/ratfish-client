import 'package:ratfish/src/elements/ratfish_logo.dart';
import 'package:ratfish/src/server/chat_group.dart';
import 'package:ratfish/src/server/client.dart';
import 'package:ratfish/src/elements/chat_group_card.dart';
import 'package:ratfish/src/elements/nav_bar.dart';
import 'package:ratfish/src/util.dart';
import 'package:flutter/material.dart';

class ChatsGroupListView extends StatefulWidget {
  const ChatsGroupListView({super.key});

  static const routeName = '/';

  @override
  State<ChatsGroupListView> createState() => _ChatsGroupListViewState();
}

class _ChatsGroupListViewState extends State<ChatsGroupListView> {
  TextEditingController searchController = TextEditingController();
  Future<List<String>> chatGroupIds = Client.getChatGroupIds();

  void search(String search) async {
    try {
      Util.executeWhenOK(
        Client.joinChatGroup(search),
        context,
        onOK: () => {
          setState(() {
            searchController.clear();
            chatGroupIds = Client.getChatGroupIds();
          }),
        },
      );
    } catch (e) {
      Util.showErrorScaffold(context, "ChatGroup not found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavBar(ChatsGroupListView.routeName),
      appBar: AppBar(
        title: RatfishLogo(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          controller: ScrollController(),
          children: [
            Flex(
              direction: Axis.horizontal,
              children: [
                const SizedBox(width: 20),
                Expanded(
                  child: TextFormField(
                    controller: searchController,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Join Chat Group',
                      helperText: 'enter a chat group id',
                    ),
                    onFieldSubmitted: (String value) async {
                      search(value);
                    },
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () async {
                    search(searchController.text);
                  },
                ),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<String>>(
              future: chatGroupIds,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                return Column(
                  children: [
                    if (snapshot.data!.isEmpty)
                      const Text('No chat groups found'),
                    if (snapshot.data!.isNotEmpty)
                      ...snapshot.data!.map(
                        (chatGroupId) {
                          return Dismissible(
                            direction: DismissDirection.endToStart,
                            background: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.red,
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            key: Key(chatGroupId),
                            confirmDismiss: (direction) async {
                              var chatGroup =
                                  await Client.getServerObject<ChatGroup>(
                                      chatGroupId);
                              return await Util.confirmDialog(
                                context,
                                "Leave \"${chatGroup.name}\"",
                                "Are you sure you want to leave the chat group ${chatGroup.name}?",
                                "Leave",
                              );
                            },
                            onDismissed: (direction) async {
                              Util.executeWhenOK(
                                Client.leaveChatGroup(chatGroupId),
                                context,
                                onOK: () {
                                  setState(() {
                                    chatGroupIds = Client.getChatGroupIds();
                                  });
                                },
                              );
                            },
                            child: ChatGroupCard(chatGroupId, goto: "open"),
                          );
                        },
                      ),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.only(left: 23),
                      leading: const Icon(Icons.add, size: 30),
                      title: const Text('Create Chat Group'),
                      onTap: () {
                        Util.askForString(
                          context,
                          "Create Chat Group",
                          "Enter a name for the chat group",
                          "Create",
                          (name) async {
                            await Client.createChatGroup(name);
                            setState(() {
                              chatGroupIds = Client.getChatGroupIds();
                            });
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
