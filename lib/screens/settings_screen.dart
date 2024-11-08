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
          ListTile(
            title: const Text('Keep Screen On'),
            trailing: Switch(value: false, onChanged: (isScreenOn) {}),
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
          ListTile(
            title: const Text('Compression Quality'),
            subtitle: const Text('Minimum Recommended (Default)'),
            trailing: TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => SimpleDialog(
                    title: const Text('Choose Quality',
                        textAlign: TextAlign.center),
                    children: [
                      RadioListTile(
                        title: const Text('Minimum Recommended 2M (Default)'),
                        value: false,
                        groupValue: false,
                        onChanged: (isChoosed) {},
                      ),
                      RadioListTile(
                        title: const Text('Medium 4M'),
                        value: false,
                        groupValue: false,
                        onChanged: (isChoosed) {},
                      ),
                      RadioListTile(
                        title: const Text('High 6M'),
                        value: false,
                        groupValue: false,
                        onChanged: (isChoosed) {},
                      ),
                      RadioListTile(
                        title: const Text('Ultra 8M'),
                        value: false,
                        groupValue: false,
                        onChanged: (isChoosed) {},
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Change'),
            ),
          ),
        ],
      ),
    );
  }
}
