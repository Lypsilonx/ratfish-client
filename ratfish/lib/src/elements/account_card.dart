import 'package:ratfish/src/elements/server_object_card.dart';
import 'package:ratfish/src/server/objects/account.dart';
import 'package:ratfish/src/server/client.dart';
import 'package:flutter/material.dart';
import 'package:ratfish/src/views/edit_view.dart';
import 'package:ratfish/src/views/inspect_view.dart';

class AccountCard extends ServerObjectCard<Account> {
  AccountCard(String id, {super.key})
      : super(id, (Account account) => account.displayName,
            (Account account) => account.pronouns,
            (BuildContext context, Account account) async {
          await Navigator.pushNamed(
            context,
            id == Client.instance.self.id
                ? EditView.routeName
                : InspectView.routeName,
            arguments: {
              "type": (Account).toString(),
              "id": id,
            },
          );
        });
}
