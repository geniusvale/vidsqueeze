import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/log.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/session.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/statistics.dart';
import 'package:flutter/material.dart';
import 'package:open_file_plus/open_file_plus.dart';

part 'video_compression_event.dart';
part 'video_compression_state.dart';

class VideoCompressionBloc
    extends Bloc<VideoCompressionEvent, VideoCompressionState> {
  VideoCompressionBloc() : super(VideoCompressionInitial()) {
    on<CompressVideoEvent>(onCompressVideo);
    on<CancelCompressionEvent>(onCancelCompression);
    on<ResetCompressionEvent>(onResetCompression);
  }

  FFmpegSession? currentSession;

  Future<int?> getVideoDuration(String videoPath) async {
    try {
      final session = await FFprobeKit.getMediaInformation(videoPath);
      final mediaInfo = session.getMediaInformation();

      if (mediaInfo != null) {
        // Mendapatkan durasi dari informasi media
        final duration = mediaInfo.getDuration();

        if (duration != null) {
          print('Durasi Video: $duration ms');
          print('Durasi Video: $duration detik');
          return double.parse(duration).toInt();
        }
      } else {
        print('Media information tidak ditemukan.');
      }
      return null;
    } catch (e) {
      print('Durasi tidak ditemukan $e');
    }
    return null;
  }

// Fungsi untuk membuat file output baru jika file dengan nama yang sama sudah ada
  String getUniqueFilePath(String basePath, String extension) {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return '$basePath-$timestamp.$extension'; // Menambahkan timestamp pada nama file
  }

  void onResetCompression(event, emit) {
    emit(VideoCompressionInitial());
  }

  void onCancelCompression(event, emit) async {
    if (currentSession != null) {
      await FFmpegKit.cancel();
      currentSession = null;
    }
    emit(VideoCompressionCancelled());
  }

  Future<void> onCompressVideo(CompressVideoEvent event, emit) async {
    try {
      emit(VideoCompressionInProgress());

      final duration = await getVideoDuration(event.videoInputPath);
      if (duration == null) {
        emit(VideoCompressionError(
            errorMessage: 'Failed to get video duration!'));
        return;
      }

      final outputPath = getUniqueFilePath(event.outputBasePath, 'mp4');
      final completer = Completer<void>();

      final session = await FFmpegKit.executeAsync(
        '-i ${event.videoInputPath} -vcodec libx264 -b:v 2M -c:a aac $outputPath',
        (Session session) async {
          try {
            final returnCode = await session.getReturnCode();

            if (ReturnCode.isSuccess(returnCode)) {
              emit(VideoCompressionSuccess(outputPath: outputPath));
              await OpenFile.open(outputPath);
              emit(ResetCompressionEvent());
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(
              //     content: Text('Video Saved to storage/emulated/0/Movies'),
              //   ),
              // );
            } else if (ReturnCode.isCancel(returnCode)) {
              File(outputPath).deleteSync();
              emit(ResetCompressionEvent());
              emit(VideoCompressionCancelled());
            } else {
              // ERROR
              emit(ResetCompressionEvent());
              emit(VideoCompressionError(errorMessage: 'Compression Failed!'));
            }
            completer.complete(); //UPDATE COMPLETER
          } catch (e) {
            completer.completeError(e);
          }
        },
        (Log log) {
          // print(log.getMessage());
          debugPrint('INI LOG ${log.getMessage()}');
        },
        (Statistics statistics) {
          // print(statistics);
          debugPrint('INI STATS $statistics');
          if (statistics == null) {
            return;
          }
          if (statistics.getTime() > 0) {
            //HANDLE PROGRESS
            double progress = ((statistics.getTime() / 1000) / duration) * 100;
            if (progress > 100) {
              progress = 100;
            }
            emit(VideoCompressionInProgress(progress: progress));
          }
        },
      );
      currentSession = session;
      await completer.future; //Wait for process to complete.
    } catch (e) {
      emit(VideoCompressionError(errorMessage: '$e'));
    }
  }
}
