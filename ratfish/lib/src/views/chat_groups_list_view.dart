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
        title: Text(
          'Chat Groups',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          controller: ScrollController(),
          children: [
            Flex(
              direction: Axis.horizontal,
              children: [
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
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    search(searchController.text);
                  },
                ),
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
                          return ChatGroupCard(chatGroupId, goto: "open");
                        },
                      ),
                    ListTile(
                      leading: const Icon(Icons.add),
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
