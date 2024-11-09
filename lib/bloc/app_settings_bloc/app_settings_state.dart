part of 'app_settings_bloc.dart';

class AppSettingsState {
  final ThemeMode themeMode;
  bool isScreenAlwaysOn;
  String definedOutputPath;
  String definedBitrateQuality;
  String definedQualityTitle;

  AppSettingsState({
    this.themeMode = ThemeMode.system,
    this.isScreenAlwaysOn = false,
    this.definedOutputPath = 'storage/emulated/0/Movies/',
    this.definedBitrateQuality = '2M',
    this.definedQualityTitle = 'Minimum Recommended (Default)',
  });

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    bool? isScreenAlwaysOn,
    String? definedOutputPath,
    String? definedBitrateQuality,
    String? definedQualityTitle,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      isScreenAlwaysOn: isScreenAlwaysOn ?? this.isScreenAlwaysOn,
      definedOutputPath: definedOutputPath ?? this.definedOutputPath,
      definedBitrateQuality:
          definedBitrateQuality ?? this.definedBitrateQuality,
      definedQualityTitle: definedQualityTitle ?? this.definedQualityTitle,
      // Salin properti lain jika ada
    );
  }
}

final class AppSettingsInitial extends AppSettingsState {}
