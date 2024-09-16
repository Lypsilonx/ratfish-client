import 'package:ratfish/src/server/account.dart';
import 'package:ratfish/src/server/client.dart';
import 'package:ratfish/src/elements/account_card.dart';
import 'package:flutter/material.dart';

class AccountView extends StatefulWidget {
  final String accountId;

  const AccountView(this.accountId, {super.key});

  static const routeName = '/account';

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        Future<Account> account = Client.getAccount(widget.accountId);
        return Scaffold(
          appBar: AppBar(),
          body: FutureBuilder<Account>(
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
                            AccountCard(
                              widget.accountId,
                            ),
                            const SizedBox(height: 20),
                            Text(account.description),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return ListTile(
                  leading: const CircularProgressIndicator(),
                  title: Text("Loading... (${widget.accountId})"),
                );
              }
            },
          ),
        );
      },
    );
  }
}
