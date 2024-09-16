import 'package:ratfish/src/server/client.dart';
import 'package:ratfish/src/util.dart';
import 'package:flutter/material.dart';
import 'package:ratfish/src/elements/ratfish_logo.dart';
import 'package:ratfish/src/settings/settings_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  static const routeName = 'login';

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool register = false;
  String userName = "";
  String password = "";
  String confirmPassword = "";

  @override
  void initState() {
    super.initState();

    if (SettingsController.instance.userId != "" &&
        SettingsController.instance.accessToken != "" &&
        SettingsController.instance.privateKey != "") {
      Util.executeWhenOK(Client.update(), context, onOK: () {
        Navigator.pushReplacementNamed(context, "/");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RatfishLogo(),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
                const SizedBox(height: 40),
                Text(
                  register ? 'Register' : 'Login',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                  ),
                  onChanged: (String value) {
                    setState(() {
                      userName = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                  onChanged: (String value) {
                    setState(() {
                      password = value;
                    });
                  },
                ),
              ] +
              (register
                  ? [
                      const SizedBox(height: 20),
                      TextFormField(
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                        ),
                        onChanged: (String value) {
                          setState(() {
                            confirmPassword = value;
                          });
                        },
                      ),
                    ]
                  : <Widget>[]) +
              [
                const SizedBox(height: 60),
                TextButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                          Theme.of(context).colorScheme.primary)),
                  onPressed: () async {
                    Util.executeWhenOK(
                      register
                          ? Client.register(userName, password, confirmPassword)
                          : Client.login(userName, password),
                      context,
                      onOK: () {
                        setState(
                          () {
                            Navigator.pushReplacementNamed(context, "/");
                            //loginStep = 1;
                          },
                        );
                      },
                    );
                  },
                  child: Text(
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                    register ? 'Register' : 'Login',
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    setState(() {
                      register = !register;
                    });
                  },
                  child: Text(
                    register ? 'Already have an account?' : 'Create an account',
                  ),
                ),
              ],
        ),
      ),
    );
  }
}
