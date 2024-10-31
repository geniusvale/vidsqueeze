part of 'video_compression_bloc.dart';

abstract class VideoCompressionEvent {}

class InitialCompressionEvent extends VideoCompressionEvent {}

class CompressVideoEvent extends VideoCompressionEvent {
  String videoInputPath;
  String outputBasePath;
  // String ffmpegCommand;

  CompressVideoEvent({
    required this.videoInputPath,
    this.outputBasePath = "storage/emulated/0/Movies/vidSqueezeOutput.mp4",
    // required this.ffmpegCommand,
  });
}

class CancelCompressionEvent extends VideoCompressionEvent {}

class ResetCompressionEvent extends VideoCompressionEvent {}

class DisposeLogCompressionEvent extends VideoCompressionEvent {}


