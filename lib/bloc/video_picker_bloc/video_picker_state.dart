part of 'video_picker_bloc.dart';

//SINGLE CONCRETE CLASS APPROACH
class VideoPickerState {}

final class VideoPickerInitial extends VideoPickerState {}

final class VideoPickerPicked extends VideoPickerState {
  File videoInput;
  VideoPlayerController videoPlayerController;

  VideoPickerPicked({
    required this.videoInput,
    required this.videoPlayerController,
  });
}

final class VideoPickerPlay extends VideoPickerState {}

final class VideoPickerPause extends VideoPickerState {}
