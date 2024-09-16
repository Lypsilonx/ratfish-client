import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static SettingsService? _instance;
  static SharedPreferences? _preferences;
  static Future<SettingsService> getInstance() async {
    _instance ??= SettingsService();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  static const String _settingsPrefix = "Ratfish";

  // Theme Color
  static const String themeColorKey = "${_settingsPrefix}ThemeColor";
  static const FlexScheme themeColorDefault = FlexScheme.red;
  Future<FlexScheme> themeColor() async {
    if (_preferences!.containsKey(themeColorKey)) {
      return FlexScheme.values[_preferences!.getInt(themeColorKey)!];
    }

    return themeColorDefault;
  }

  Future<void> updateThemeColor(FlexScheme themeColor) async {
    _preferences!.setInt(themeColorKey, themeColor.index);
  }

  // Theme Mode
  static const String themeModeKey = "${_settingsPrefix}Theme";
  static const ThemeMode themeModeDefault = ThemeMode.system;
  Future<ThemeMode> themeMode() async {
    if (_preferences!.containsKey(themeModeKey)) {
      String themeModeName = _preferences!.getString(themeModeKey)!;
      return ThemeMode.values.firstWhere((e) => e.name == themeModeName,
          orElse: () => themeModeDefault);
    }

    return themeModeDefault;
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    _preferences!.setString(themeModeKey, themeMode.name);
  }

  // User Id
  static const String userIdKey = "${_settingsPrefix}UserId";
  static const String userIdDefault = "0";
  Future<String> userId() async {
    if (_preferences!.containsKey(userIdKey)) {
      return _preferences!.getString(userIdKey)!;
    }

    return userIdDefault;
  }

  Future<void> updateUserId(String userId) async {
    _preferences!.setString(userIdKey, userId);
  }

  // Access Token
  static const String accessTokenKey = "${_settingsPrefix}AccessToken";
  static const String accessTokenDefault = "";
  Future<String> accessToken() async {
    if (_preferences!.containsKey(accessTokenKey)) {
      return _preferences!.getString(accessTokenKey)!;
    }

    return accessTokenDefault;
  }

  Future<void> updateAccessToken(String accessToken) async {
    _preferences!.setString(accessTokenKey, accessToken);
  }

  // Private Key
  static const String privateKeyKey = "${_settingsPrefix}PrivateKey";
  static const String privateKeyDefault = "";
  Future<String> privateKey() async {
    if (_preferences!.containsKey(privateKeyKey)) {
      return _preferences!.getString(privateKeyKey)!;
    }

    return privateKeyDefault;
  }

  Future<void> updatePrivateKey(String privateKey) async {
    _preferences!.setString(privateKeyKey, privateKey);
  }
}
