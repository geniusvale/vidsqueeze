import 'package:flutter/material.dart';
import 'package:vidsqueeze/bloc/video_compression_bloc/video_compression_bloc.dart';
import 'package:vidsqueeze/bloc/video_picker_bloc/video_picker_bloc.dart';
import 'package:vidsqueeze/screens/home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/app_settings_bloc/app_settings_bloc.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VidSqueeze',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AppSettingsBloc(),
          ),
          BlocProvider(
            create: (context) => VideoPickerBloc(),
          ),
          BlocProvider(
            create: (context) => VideoCompressionBloc(),
          ),
        ],
        child: const HomeScreen(),
      ),
    );
  }
}
