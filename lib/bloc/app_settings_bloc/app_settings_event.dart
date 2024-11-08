part of 'app_settings_bloc.dart';

@immutable
sealed class AppSettingsEvent {}

class ToggleDarkMode extends AppSettingsEvent {
  final ThemeMode? themeData;

  ToggleDarkMode({
    this.themeData,
  });
}
