import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'app_settings_event.dart';
part 'app_settings_state.dart';

class AppSettingsBloc extends Bloc<AppSettingsEvent, AppSettingsState> {
  AppSettingsBloc() : super(AppSettingsInitial()) {
    on<ToggleDarkMode>(toggleDarkMode);
    on<ChangeCompressionQuality>(updateCompressionQuality);
    on<ToggleScreenOn>(turnScreenOn);
  }

  List presetQuality = [
    {'title': 'Minimum Recommended (Default)', 'bitrate': '2M'},
    {'title': 'Medium', 'bitrate': '4M'},
    {'title': 'High', 'bitrate': '6M'},
    {'title': 'Ultra', 'bitrate': '8M'},
  ];

  void toggleDarkMode(ToggleDarkMode event, Emitter emit) {
    emit(state.copyWith(themeMode: event.themeData));
  }

  void updateCompressionQuality(ChangeCompressionQuality event, emit) {
    emit(state.copyWith(
      definedQualityTitle: event.title,
      definedBitrateQuality: event.bitrate,
    ));
  }

  void turnScreenOn(ToggleScreenOn event, emit) {
    emit(state.copyWith(isScreenAlwaysOn: event.enable));
  }
}
