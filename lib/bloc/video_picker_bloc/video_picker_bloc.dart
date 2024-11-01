import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

part 'video_picker_event.dart';
part 'video_picker_state.dart';

class VideoPickerBloc extends Bloc<VideoPickerEvent, VideoPickerState> {
  VideoPickerBloc() : super(VideoPickerInitial()) {
    on<PickVideoEvent>(onPickVideo);
    on<PlayVideoEvent>(onPlayVideo);
    on<PauseVideoEvent>(onPauseVideo);
  }

  Future<void> onPickVideo(
      VideoPickerEvent event, Emitter<VideoPickerState> emit) async {
    final result = await Permission.storage.request();
    if (result == PermissionStatus.granted) {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.video);

      if (result != null) {
        final pickedFile = File(result.files.single.path!);

        final videoController = VideoPlayerController.file(pickedFile);
        await videoController.initialize();

        emit(VideoPickerPicked(
          videoInput: pickedFile,
          videoPlayerController: videoController,
        ));
      } else {
        // User canceled the picker
        emit(VideoPickerInitial());
      }
    }
  }

  Future<void> onPlayVideo(
      PlayVideoEvent event, Emitter<VideoPickerState> emit) async {
    if (state is VideoPickerPicked) {
      final currentState = state as VideoPickerPicked;
      final videoController = currentState.videoPlayerController;

      // Memainkan video
      await videoController.play();

      // Emit state baru agar BlocBuilder merender ulang
      emit(VideoPickerPicked(
        videoInput: currentState.videoInput,
        videoPlayerController: videoController,
      ));
    }
  }

  Future<void> onPauseVideo(
      PauseVideoEvent event, Emitter<VideoPickerState> emit) async {
    if (state is VideoPickerPicked) {
      final currentState = state as VideoPickerPicked;
      final videoController = currentState.videoPlayerController;

      // Menjeda video
      await videoController.pause();

      // Emit state baru agar BlocBuilder merender ulang
      emit(VideoPickerPicked(
        videoInput: currentState.videoInput,
        videoPlayerController: videoController,
      ));
    }
  }
}
