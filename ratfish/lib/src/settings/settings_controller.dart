import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'settings_service.dart';

class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);

  final SettingsService _settingsService;

  static late SettingsController _instance;
  static SettingsController get instance => _instance;

  Future<void> loadSettings() async {
    _themeColor = await _settingsService.themeColor();
    updateThemeColor(_themeColor);
    _themeMode = await _settingsService.themeMode();

    _userId = await _settingsService.userId();
    _accessToken = await _settingsService.accessToken();
    _privateKey = await _settingsService.privateKey();

    _instance = this;

    notifyListeners();
  }

  late ThemeData _darkTheme;
  ThemeData get darkTheme => _darkTheme;

  late ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  late FlexScheme _themeColor;
  FlexScheme get themeColor => _themeColor;

  void updateThemeColor(FlexScheme? newThemeColor) async {
    if (newThemeColor == null) return;

    _themeColor = newThemeColor;
    _theme = FlexThemeData.light(scheme: newThemeColor, useMaterial3: true);
    _darkTheme = FlexThemeData.dark(scheme: newThemeColor, useMaterial3: true);

    notifyListeners();
    await _settingsService.updateThemeColor(themeColor);
  }

  late ThemeData _theme;
  ThemeData get theme => _theme;

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    if (newThemeMode == _themeMode) return;

    _themeMode = newThemeMode;

    notifyListeners();
    await _settingsService.updateThemeMode(newThemeMode);
  }

  late String _userId;
  String get userId => _userId;

  Future<void> updateUserId(String? newUserId) async {
    if (newUserId == null) return;
    if (newUserId == _userId) return;

    _userId = newUserId;

    notifyListeners();
    await _settingsService.updateUserId(newUserId);
  }

  late String _accessToken;
  String get accessToken => _accessToken;

  Future<void> updateAccessToken(String? newAccessToken) async {
    if (newAccessToken == null) return;
    if (newAccessToken == _accessToken) return;

    _accessToken = newAccessToken;

    notifyListeners();
    await _settingsService.updateAccessToken(newAccessToken);
  }

  late String _privateKey;
  String get privateKey => _privateKey;

  Future<void> updatePrivateKey(String newPrivateKey) async {
    if (newPrivateKey == _privateKey) return;

    _privateKey = newPrivateKey;

    notifyListeners();
    await _settingsService.updatePrivateKey(newPrivateKey);
  }
}
