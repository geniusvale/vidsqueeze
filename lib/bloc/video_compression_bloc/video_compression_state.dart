part of 'video_compression_bloc.dart';

class VideoCompressionState {}

class VideoCompressionInitial extends VideoCompressionState {}

class VideoCompressionInProgress extends VideoCompressionState {
  double? progress = 0.0;
  VideoCompressionInProgress({
    this.progress,
  });
}

class VideoCompressionSuccess extends VideoCompressionState {
  String? outputPath;
  VideoCompressionSuccess({
    this.outputPath,
  });
}

class VideoCompressionError extends VideoCompressionState {
  String? errorMessage;
  VideoCompressionError({
    required this.errorMessage,
  });
}

class VideoCompressionCancelled extends VideoCompressionState {}
