import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit_config.dart';
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
    on<InitialCompressionEvent>(onInitialCompression);
    on<CompressVideoEvent>(onCompressVideo);
    on<CancelCompressionEvent>(onCancelCompression);
    on<DisposeLogCompressionEvent>(onDisposeLog);
  }

  final ScrollController scrollController = ScrollController();

  List<String> logList = [''];
  final int maxLogCount = 100;

  FFmpegSession? currentSession;

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void onDisposeLog(event, emit) {
    scrollController.dispose();
    emit(VideoCompressionInitial());
  }

  Future<void> onInitialCompression(
      VideoCompressionEvent event, Emitter emit) async {
    try {
      FFmpegKitConfig.enableLogCallback((log) {
        // Tambahkan log baru ke logList
        if (log.getMessage().isNotEmpty) {
          logList.add(log.getMessage());
        } else {
          logList.add('');
        }
        //NO NEED TO EMIT, ALREADY DONE ON SUPER CONSTRUCTOR
        //EMIT WILL NOT WORK INSIDE ASYNC TASK
        // emit(VideoCompressionInitial());

        // Batasi jumlah log, hapus log terlama jika melebihi maxLogCount
        if (logList.length > maxLogCount) {
          logList.removeAt(0);
        }

        // Scroll otomatis ke bawah, secara async
        // scrollToBottom(); //ALSO WORK WELL
        Future.microtask(() => scrollToBottom());
      });
    } catch (e) {
      print(e);
    }
  }

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

  //Fungsi untuk membuat file output baru jika file dengan nama yang sama sudah ada
  String getUniqueFilePath(String basePath, String extension) {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return '$basePath-$timestamp.$extension'; // Menambahkan timestamp pada nama file
  }

  void onCancelCompression(event, emit) async {
    if (currentSession != null) {
      FFmpegKit.cancel();
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

      final outputPath =
          getUniqueFilePath('${event.outputBasePath}/vidSqueezeOutput', 'mp4');
      final definedOutputPath = getUniqueFilePath(
          '${event.userDefinedPath!}/vidSqueezeOutput', 'mp4');
      final completer = Completer<void>();

      final session = await FFmpegKit.executeAsync(
        '-i ${event.videoInputPath} -vcodec libx264 -b:v ${event.selectedBitrateQuality ?? '2M'} -c:a aac ${definedOutputPath ?? outputPath}',
        (Session session) async {
          try {
            final returnCode = await session.getReturnCode();

            if (ReturnCode.isSuccess(returnCode)) {
              emit(VideoCompressionSuccess(outputPath: outputPath));
              await OpenFile.open(outputPath);
              emit(VideoCompressionInitial());
            } else if (ReturnCode.isCancel(returnCode)) {
              File(outputPath).deleteSync();
              emit(VideoCompressionInitial());
            } else {
              // ERROR
              emit(VideoCompressionError(errorMessage: 'Compression Failed!'));
              emit(VideoCompressionInitial());
            }
            completer.complete(); //UPDATE COMPLETER, To Stop The Process.
          } catch (e) {
            completer.completeError(e);
          }
        },
        (Log log) {
          debugPrint('INI LOG ${log.getMessage()}');
        },
        (Statistics statistics) {
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
      //This will Executed, using Completer for waiting async process to complete,
      //because there's emit inside async process, if not it will error.
      await completer.future;
    } catch (e) {
      emit(VideoCompressionError(errorMessage: '$e'));
    }
  }
}
