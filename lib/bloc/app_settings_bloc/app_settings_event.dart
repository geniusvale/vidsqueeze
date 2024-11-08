part of 'app_settings_bloc.dart';

class AppSettingsEvent {}

class ToggleDarkMode extends AppSettingsEvent {
  final ThemeMode? themeData;

  ToggleDarkMode({
    this.themeData,
  });
}

class ChangeCompressionQuality extends AppSettingsEvent {
  String? title;
  String? bitrate;

  ChangeCompressionQuality({
    this.title,
    this.bitrate,
  });
}

class ToggleScreenOn extends AppSettingsEvent {
  bool enable;

  ToggleScreenOn({
    this.enable = false,
  });
}
