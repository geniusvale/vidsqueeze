import 'dart:async';
import 'dart:io';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/log.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/session.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/statistics.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:vidsqueeze/widgets/widgets.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late VideoPlayerController _videoPlayerController;

  bool isCompressing = false;

  double _progress = 0.0;
  int _totalDuration = 0;

  File? videoInput;
  File? videoOutput;
  String? testOutput;

  final List<String> logList = [];
  final int maxLogCount = 100; // Batas jumlah log yang disimpan
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    FFmpegKitConfig.enableLogCallback((log) {
      setState(() {
        // Tambahkan log baru ke logList
        logList.add(log.getMessage());

        // Batasi jumlah log, hapus log terlama jika melebihi maxLogCount
        if (logList.length > maxLogCount) {
          logList.removeAt(0);
        }
      });

      // Scroll otomatis ke bawah
      _scrollToBottom();
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  Future pickFile() async {
    final result = await Permission.storage.request();
    if (result == PermissionStatus.granted) {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.video);

      if (result != null) {
        videoInput = File(result.files.single.path!);
        _videoPlayerController = VideoPlayerController.file(videoInput!)
          ..initialize().then((_) {
            setState(() {});
          });
      } else {
        // User canceled the picker
      }
    }
  }

  Future<void> getVideoDuration(String videoPath) async {
    final session = await FFprobeKit.getMediaInformation(videoPath);
    final mediaInfo = session.getMediaInformation();

    if (mediaInfo != null) {
      // Mendapatkan durasi dari informasi media
      final duration = mediaInfo.getDuration();

      setState(() {
        _totalDuration = double.parse(duration!)
            .toInt(); // Simpan durasi total video dalam ms ke int
      });

      if (duration != null) {
        print('Durasi Video: $duration ms');
        double totalDurationInSeconds = double.parse(duration) / 1000;
        print('Durasi Video: $totalDurationInSeconds detik');
      } else {
        print('Durasi tidak ditemukan');
      }
    } else {
      print('Media information tidak ditemukan.');
    }
  }

  // Fungsi untuk membuat file output baru jika file dengan nama yang sama sudah ada
  String getUniqueFilePath(String basePath, String extension) {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return '$basePath-$timestamp.$extension'; // Menambahkan timestamp pada nama file
  }

  // Future _showProgressDialog(BuildContext context) async {
  //   return showDialog(
  //     context: context,
  //     barrierDismissible: false, // Jangan tutup dialog ketika klik di luar
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(builder: (context, setState) {
  //         return AlertDialog(
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               const Text("Compressing Video..."),
  //               const SizedBox(height: 20),
  //               Text(
  //                 '${_progress.toStringAsFixed(0)}%',
  //                 textAlign: TextAlign.center,
  //               ),
  //               LinearProgressIndicator(value: _progress / 100), // Progress bar
  //             ],
  //           ),
  //         );
  //       });
  //     },
  //   );
  // }

  void resetCompressionStats() {
    setState(() {
      isCompressing = false;
      _progress = 0.0; // Reset progress
      // testOutput = outputPath;
    });
  }

  compressVideo(BuildContext context) async {
    String outputPath = "storage/emulated/0/Movies/vidSqueezeOutput.mp4";

    await getVideoDuration(videoInput!.path);

    if (File(outputPath).existsSync()) {
      outputPath = getUniqueFilePath(
        "storage/emulated/0/Movies/vidSqueezeOutput",
        "mp4",
      );
    }

    setState(() {
      isCompressing = true;
    });

    FFmpegKit.executeAsync(
        '-i ${videoInput!.path} -vcodec libx264 -b:v 2M -c:a aac $outputPath',
        (Session session) async {
      // CALLED WHEN SESSION IS EXECUTED

      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        // SUCCESS

        resetCompressionStats();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video Saved to storage/emulated/0/Movies'),
          ),
        );

        OpenFile.open(outputPath);
      } else if (ReturnCode.isCancel(returnCode)) {
        // CANCEL
        File(outputPath).deleteSync();
        resetCompressionStats();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compression is cancelled!'),
          ),
        );
      } else {
        // ERROR
        resetCompressionStats();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Compression Error - Return Code $returnCode!!'),
          ),
        );
      }
    }, (Log log) {
      // CALLED WHEN SESSION PRINTS LOGS
      debugPrint('INI LOG ${log.getMessage()}');
    }, (Statistics statistics) {
      // CALLED WHEN SESSION GENERATES STATISTICS
      debugPrint('INI STATS $statistics');
      if (statistics == null) {
        return;
      }
      if (statistics.getTime() > 0) {
        setState(() {
          _progress = ((statistics.getTime() / 1000) / _totalDuration) * 100;
          if (_progress > 100) {
            _progress = 100;
          }
        });
      }
    });
  }

  void cancelTask() {
    FFmpegKit.cancel();
    setState(() {
      isCompressing == false;
      _progress = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VidSqueeze'),
        actions: [
          IconButton(
            onPressed: () async {
              // print("Status Kompresi $isCompressing");
              // print("videoInput $videoInput");
              // getVideoDuration(videoInput!.path);
              // setState(() {});
              await OpenFile.open(testOutput);
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              videoInput == null
                  ? VideoPickerWidget(
                      onTap: () async {
                        pickFile();
                      },
                    )
                  : Container(
                      alignment: Alignment.center,
                      height: 160,
                      child: GestureDetector(
                        onTap: _videoPlayerController.value.isPlaying
                            ? () => _videoPlayerController.pause()
                            : () => _videoPlayerController.play(),
                        child: AspectRatio(
                          aspectRatio: _videoPlayerController.value.aspectRatio,
                          child: VideoPlayer(_videoPlayerController),
                        ),
                      ),
                    ),
              //Re-pick input video??
              const SizedBox(
                height: 32,
              ),
              const Text('Selected file :'),
              Text(videoInput?.path ?? 'No file selected'),
              const SizedBox(
                height: 32,
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isCompressing
                          ? null
                          : videoInput == null
                              ? null
                              : () => compressVideo(context),
                      child: const Text('Compress Video'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isCompressing ? () => cancelTask() : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: videoInput == null || isCompressing
                          ? null
                          : () {
                              pickFile();
                            },
                      child: const Text('Change Video'),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Progress :'),
                    Row(
                      children: [
                        Expanded(
                          child:
                              LinearProgressIndicator(value: _progress / 100),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          '${_progress.toStringAsFixed(0)}%',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              const Text('Logs :'),
              Container(
                decoration: BoxDecoration(color: Colors.grey[200]),
                height: 200,
                margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _scrollController,
                  itemCount: logList.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    return Text(
                      logList[index],
                      textAlign: TextAlign.start,
                    );
                  },
                ),
              ),
              //MORE FEATURES
              //Output Preview / ReOpen
              //Share Button
              //Settings :
              //Save to destined directory,
              // Dark Mode,
              //Codec, Bitrate,
              //Predefined Presets Quality
            ],
          ),
        ),
      ),
    );
  }
}
