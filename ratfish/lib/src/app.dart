import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ratfish/src/server/account.dart';
import 'package:ratfish/src/server/character.dart';
import 'package:ratfish/src/server/chat_group.dart';
import 'package:ratfish/src/views/chat_view.dart';
import 'package:ratfish/src/views/chat_group_view.dart';
import 'package:ratfish/src/views/chat_groups_list_view.dart';
import 'package:ratfish/src/views/edit_view.dart';
import 'package:ratfish/src/views/inspect_view.dart';
import 'package:ratfish/src/views/login_view.dart';

import 'package:ratfish/src/views/settings_view.dart';
import 'package:ratfish/src/settings/settings_controller.dart';

/// The Widget that configures your application.
class Ratfish extends StatelessWidget {
  const Ratfish({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsController.instance,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          restorationScopeId: 'app',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,
          theme: SettingsController.instance.theme,
          darkTheme: SettingsController.instance.darkTheme,
          themeMode: SettingsController.instance.themeMode,
          initialRoute: LoginView.routeName,
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                var map = routeSettings.arguments as Map? ?? {};

                if (routeSettings.name == EditView.routeName) {
                  var typeName = map["type"] as String;
                  if (typeName == (Account).toString()) {
                    return EditView<Account>(map["id"] as String);
                  } else if (typeName == (Character).toString()) {
                    return EditView<Character>(map["id"] as String);
                  } else if (typeName == (ChatGroup).toString()) {
                    return EditView<ChatGroup>(map["id"] as String);
                  }

                  throw UnimplementedError();
                }

                if (routeSettings.name == InspectView.routeName) {
                  var typeName = map["type"] as String;
                  if (typeName == (Account).toString()) {
                    return InspectView<Account>(map["id"] as String);
                  } else if (typeName == (Character).toString()) {
                    return InspectView<Character>(map["id"] as String);
                  } else if (typeName == (ChatGroup).toString()) {
                    return InspectView<ChatGroup>(map["id"] as String);
                  }

                  throw UnimplementedError();
                }

                return switch (routeSettings.name) {
                  LoginView.routeName => const LoginView(),
                  SettingsView.routeName => const SettingsView(),
                  ChatsGroupListView.routeName => const ChatsGroupListView(),
                  ChatGroupView.routeName =>
                    ChatGroupView(map["chatGroupId"] as String),
                  ChatView.routeName => ChatView(map["chatGroupId"] as String,
                      map["chatId"] as String, map["isGroup"] as bool),
                  _ => const ChatsGroupListView()
                };
              },
            );
          },
        );
      },
    );
  }
}
