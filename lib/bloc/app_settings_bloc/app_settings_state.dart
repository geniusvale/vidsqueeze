part of 'app_settings_bloc.dart';

class AppSettingsState {
  final ThemeMode themeMode;
  final bool isScreenAlwaysOn;
  final String definedOutputPath;

  AppSettingsState({
    this.themeMode = ThemeMode.system,
    this.isScreenAlwaysOn = false,
    this.definedOutputPath = 'storage/emulated/0/Movies/',
  });

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    bool? isScreenAlwaysOn,
    String? definedOutputPath,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      isScreenAlwaysOn: isScreenAlwaysOn ?? this.isScreenAlwaysOn,
      definedOutputPath: definedOutputPath ?? this.definedOutputPath,
      // Salin properti lain jika ada
    );
  }
}

final class AppSettingsInitial extends AppSettingsState {}
