import 'package:ratfish/src/elements/account_card.dart';
import 'package:ratfish/src/elements/nav_bar.dart';
import 'package:ratfish/src/views/login_view.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:ratfish/src/server/client.dart';
import 'package:ratfish/src/settings/settings_controller.dart';
import 'package:ratfish/src/util.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  static const routeName = '/settings';

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavBar(SettingsView.routeName),
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: ListView(
        controller: ScrollController(),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AccountCard(Client.instance.self.id),
                const SizedBox(height: 20),
                Text(
                  "General",
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                // Theme
                ListTile(
                  leading: Icon(Icons.color_lens,
                      color: Theme.of(context).colorScheme.primary),
                  title: Text(
                    'Color',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  trailing: DropdownButton<FlexScheme>(
                    underline: Container(),
                    value: SettingsController.instance.themeColor,
                    onChanged: SettingsController.instance.updateThemeColor,
                    selectedItemBuilder: (BuildContext context) {
                      return FlexScheme.values.map((FlexScheme scheme) {
                        return Align(
                          alignment: Alignment.centerRight,
                          child: Text(scheme.name),
                        );
                      }).toList();
                    },
                    items: FlexScheme.values.map((FlexScheme scheme) {
                      return DropdownMenuItem(
                        alignment: Alignment.centerRight,
                        value: scheme,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(scheme.name),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: GridView.count(
                                crossAxisCount: 2,
                                children: [
                                  Container(
                                    color: FlexColorScheme.light(scheme: scheme)
                                        .primary,
                                  ),
                                  Container(
                                    color: FlexColorScheme.light(scheme: scheme)
                                        .secondary,
                                  ),
                                  Container(
                                    color: FlexColorScheme.dark(scheme: scheme)
                                        .primary,
                                  ),
                                  Container(
                                    color: FlexColorScheme.dark(scheme: scheme)
                                        .secondary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Theme mode
                ListTile(
                  leading: switch (SettingsController.instance.themeMode) {
                    ThemeMode.system => Icon(Icons.brightness_4,
                        color: Theme.of(context).colorScheme.primary),
                    ThemeMode.light => Icon(Icons.brightness_5,
                        color: Theme.of(context).colorScheme.primary),
                    ThemeMode.dark => Icon(Icons.brightness_3,
                        color: Theme.of(context).colorScheme.primary),
                  },
                  title: Text(
                    'Theme',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  trailing: DropdownButton<ThemeMode>(
                    underline: Container(),
                    value: SettingsController.instance.themeMode,
                    onChanged: SettingsController.instance.updateThemeMode,
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System Theme'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light Theme'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark Theme'),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                // Logout
                TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () {
                    Util.popUpDialog(
                      context,
                      "Logout",
                      "Are you sure you want to log out?",
                      "Logout",
                      () async {
                        await Client.logout();

                        Navigator.pushReplacementNamed(
                            context, LoginView.routeName);
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 5, bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Logout',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(
                                  color: Theme.of(context).colorScheme.onError),
                        ),
                        Icon(
                          Icons.logout,
                          color: Theme.of(context).colorScheme.onError,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
