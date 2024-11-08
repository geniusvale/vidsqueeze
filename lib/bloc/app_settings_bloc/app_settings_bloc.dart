import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'app_settings_event.dart';
part 'app_settings_state.dart';

class AppSettingsBloc extends Bloc<AppSettingsEvent, AppSettingsState> {
  AppSettingsBloc() : super(AppSettingsInitial()) {
    on<AppSettingsEvent>((event, emit) {});
    on<ToggleDarkMode>(toggleDarkMode);
  }

  void toggleDarkMode(ToggleDarkMode event, Emitter emit) {
    emit(state.copyWith(themeMode: event.themeData));
  }
}
