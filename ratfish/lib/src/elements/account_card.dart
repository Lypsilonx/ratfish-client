import 'package:ratfish/src/server/account.dart';
import 'package:ratfish/src/server/client.dart';
import 'package:ratfish/src/views/account_view.dart';
import 'package:ratfish/src/views/chat_view.dart';
import 'package:flutter/material.dart';

class AccountCard extends StatefulWidget {
  final String accountId;
  final String chatGroupId;

  AccountCard(this.accountId, {this.chatGroupId = ""});

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  @override
  Widget build(BuildContext context) {
    Future<Account> account = Client.getAccount(widget.accountId);
    return FutureBuilder<Account>(
      future: account,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ListTile(
            leading: const Icon(Icons.error),
            title: Text(
                "Error loading account: ${widget.accountId} (${snapshot.error})"),
          );
        }

        if (snapshot.hasData) {
          Account account = snapshot.data!;

          return ListTile(
            contentPadding: const EdgeInsets.all(20),
            leading: CircleAvatar(
              backgroundImage:
                  account.avatar != "" ? NetworkImage(account.avatar) : null,
            ),
            title: Text(
              style: Theme.of(context).textTheme.titleMedium,
              account.displayName,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              if (widget.chatGroupId == "") {
                Navigator.pushNamed(context, AccountView.routeName,
                    arguments: {"accountId": account.id});
              } else {
                Navigator.pushNamed(context, ChatView.routeName, arguments: {
                  "chatGroupId": widget.chatGroupId,
                  "accountId": account.id
                });
              }
            },
          );
        } else {
          return ListTile(
            leading: const CircularProgressIndicator(),
            title: Text("Loading... (${widget.accountId})"),
          );
        }
      },
    );
  }
}
