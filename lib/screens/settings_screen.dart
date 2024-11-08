import 'dart:io';

import 'package:flutter/material.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/app_settings_bloc/app_settings_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          BlocSelector<AppSettingsBloc, AppSettingsState, bool>(
            selector: (state) => state.isScreenAlwaysOn,
            builder: (context, isScreenOn) {
              return ListTile(
                title: const Text('Keep Screen On'),
                trailing: Switch(
                    value: isScreenOn,
                    onChanged: (value) {
                      context
                          .read<AppSettingsBloc>()
                          .add(ToggleScreenOn(enable: value));
                    }),
              );
            },
          ),
          BlocSelector<AppSettingsBloc, AppSettingsState, ThemeMode>(
            selector: (state) => state.themeMode,
            builder: (context, mode) {
              return ListTile(
                title: const Text('Dark Theme'),
                trailing: Switch(
                  value: mode.name == 'dark' ? true : false,
                  onChanged: (isDarkMode) {
                    final newThemeMode =
                        isDarkMode ? ThemeMode.dark : ThemeMode.light;
                    context
                        .read<AppSettingsBloc>()
                        .add(ToggleDarkMode(themeData: newThemeMode));
                  },
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Save Directory'),
            subtitle:
                Text(context.watch<AppSettingsBloc>().state.definedOutputPath),
            trailing: TextButton(
                onPressed: () async {
                  await FilesystemPicker.open(
                    context: context,
                    title: 'Save to folder',
                    rootDirectory: Directory('storage/emulated/0/'),
                    fsType: FilesystemType.folder,
                    pickText: 'Save file to this folder',
                  );
                },
                child: const Text('Change')),
          ),
          BlocBuilder<AppSettingsBloc, AppSettingsState>(
            builder: (blocBuilderContext, state) {
              // debugPrint(
              //     context.read<AppSettingsBloc>().state.definedBitrateQuality);
              // debugPrint(state.definedQualityTitle);
              return ListTile(
                title: const Text('Compression Quality'),
                subtitle: Text(
                  state.definedQualityTitle,
                ),
                trailing: TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => SimpleDialog(
                        title: const Text(
                          'Choose Quality',
                          textAlign: TextAlign.center,
                        ),
                        children: context
                            .read<AppSettingsBloc>()
                            .presetQuality
                            .map(
                              (e) => RadioListTile(
                                title: Text(e['title']),
                                value: e['bitrate'],
                                groupValue: state.definedBitrateQuality,
                                onChanged: (value) {
                                  blocBuilderContext
                                      .read<AppSettingsBloc>()
                                      .add(
                                        ChangeCompressionQuality(
                                          title: e['title'],
                                          bitrate: value.toString(),
                                        ),
                                      );
                                  Navigator.pop(context);
                                },
                              ),
                            )
                            .toList(),
                      ),
                    );
                  },
                  child: const Text('Change'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
