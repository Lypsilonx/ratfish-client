import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ratfish/src/views/character_view.dart';
import 'package:ratfish/src/views/chat_view.dart';
import 'package:ratfish/src/views/account_view.dart';
import 'package:ratfish/src/views/chat_group_view.dart';
import 'package:ratfish/src/views/chat_groups_list_view.dart';
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
                return switch (routeSettings.name) {
                  LoginView.routeName => const LoginView(),
                  SettingsView.routeName => const SettingsView(),
                  ChatsGroupListView.routeName => const ChatsGroupListView(),
                  ChatGroupView.routeName =>
                    ChatGroupView(map["chatGroupId"] as String),
                  AccountView.routeName =>
                    AccountView(map["accountId"] as String),
                  CharacterView.routeName =>
                    CharacterView(map["characterId"] as String),
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
