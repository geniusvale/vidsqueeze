part of 'video_picker_bloc.dart';

sealed class VideoPickerEvent {}

class PickVideoEvent extends VideoPickerEvent {}

class PlayVideoEvent extends VideoPickerEvent {
  VideoPlayerController videoController;
  PlayVideoEvent({
    required this.videoController,
  });
}

class PauseVideoEvent extends VideoPickerEvent {
  VideoPlayerController videoController;
  PauseVideoEvent({
    required this.videoController,
  });
}
