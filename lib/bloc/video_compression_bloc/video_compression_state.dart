part of 'video_compression_bloc.dart';

class VideoCompressionState {
  // List<String>? logList = [];
  // int? maxLogCount = 100; // Batas jumlah log yang disimpan
  // ScrollController? scrollController = ScrollController();
}

class VideoCompressionInitial extends VideoCompressionState {
  // List<String>? logList = [];

  // VideoCompressionInitial({
  //   this.logList,
  // });
}

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
