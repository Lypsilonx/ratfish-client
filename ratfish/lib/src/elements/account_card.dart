import 'dart:convert';

import 'package:ratfish/src/server/account.dart';
import 'package:ratfish/src/server/client.dart';
import 'package:flutter/material.dart';
import 'package:ratfish/src/views/inspect_view.dart';

class AccountCard extends StatefulWidget {
  final String accountId;

  const AccountCard(this.accountId, {super.key});

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  @override
  Widget build(BuildContext context) {
    Future<Account> account = Client.getServerObject<Account>(widget.accountId);
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
              backgroundImage: account.image.isNotEmpty
                  ? Image.memory(base64Decode(account.image)).image
                  : null,
            ),
            title: Text(
              style: Theme.of(context).textTheme.titleMedium,
              account.displayName,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () async {
              Navigator.pushNamed(context, InspectView.routeName,
                  arguments: {"type": (Account).toString(), "id": account.id});
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
