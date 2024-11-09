part of 'video_compression_bloc.dart';

abstract class VideoCompressionEvent {}

class InitialCompressionEvent extends VideoCompressionEvent {}

class CompressVideoEvent extends VideoCompressionEvent {
  String videoInputPath;
  String outputBasePath;
  String? userDefinedPath;
  String? selectedBitrateQuality;
  // String ffmpegCommand;

  CompressVideoEvent({
    required this.videoInputPath,
    this.outputBasePath = "storage/emulated/0/Movies/vidSqueezeOutput",
    this.userDefinedPath,
    this.selectedBitrateQuality,
    // required this.ffmpegCommand,
  });
}

class CancelCompressionEvent extends VideoCompressionEvent {}

class DisposeLogCompressionEvent extends VideoCompressionEvent {}
