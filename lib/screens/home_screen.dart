import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:vidsqueeze/widgets/widgets.dart';

import '../bloc/video_compression_bloc/video_compression_bloc.dart';
import '../bloc/video_picker_bloc/video_picker_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    context.read<VideoCompressionBloc>().add(InitialCompressionEvent());
    super.initState();
  }

  @override
  void dispose() {
    context.read<VideoCompressionBloc>().add(DisposeLogCompressionEvent());
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VideoCompressionBloc, VideoCompressionState>(
      listener: (context, state) {
        if (state is VideoCompressionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            behavior: SnackBarBehavior.floating,
            content: AwesomeSnackbarContent(
              title: 'Success!',
              message: 'Video saved to storage/emulated/0/Movies folder!',
              contentType: ContentType.success,
            ),
          ));
        } else if (state is VideoCompressionCancelled) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            behavior: SnackBarBehavior.floating,
            content: AwesomeSnackbarContent(
              title: 'Cancelled!',
              message: 'Compression has cancelled!',
              contentType: ContentType.warning,
            ),
          ));
        } else if (state is VideoCompressionError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            behavior: SnackBarBehavior.floating,
            content: AwesomeSnackbarContent(
              title: 'Error!',
              message: 'Compression has error ${state.errorMessage}!',
              contentType: ContentType.failure,
            ),
          ));
          debugPrint('ERROR STATE ${state.errorMessage}');
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('VidSqueeze'),
            actions: [
              IconButton(
                onPressed: () async {},
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
                  BlocBuilder<VideoPickerBloc, VideoPickerState>(
                    builder: (context, state) {
                      if (state is VideoPickerPicked) {
                        return Container(
                          alignment: Alignment.center,
                          height: 160,
                          child: GestureDetector(
                            onTap: state.videoPlayerController.value.isPlaying
                                ? () => context.read<VideoPickerBloc>().add(
                                      PauseVideoEvent(
                                        videoController:
                                            state.videoPlayerController,
                                      ),
                                    )
                                : () => context.read<VideoPickerBloc>().add(
                                      PlayVideoEvent(
                                        videoController:
                                            state.videoPlayerController,
                                      ),
                                    ),
                            child: AspectRatio(
                              aspectRatio:
                                  state.videoPlayerController.value.aspectRatio,
                              child: VideoPlayer(state.videoPlayerController),
                            ),
                          ),
                        );
                      } else {
                        return VideoPickerWidget(
                          onTap: () async {
                            context
                                .read<VideoPickerBloc>()
                                .add(PickVideoEvent());
                          },
                        );
                      }
                    },
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  const Text('Selected file :'),
                  BlocSelector<VideoPickerBloc, VideoPickerState, String>(
                    selector: (state) {
                      if (state is VideoPickerPicked) {
                        return state.videoInput.path;
                      }
                      return 'NO FILE SELECTED';
                    },
                    builder: (context, state) {
                      return Text(state);
                    },
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  BlocBuilder<VideoPickerBloc, VideoPickerState>(
                    builder: (context, state) {
                      bool isVideoPicked = false;
                      String? videoInput;
                      if (state is VideoPickerPicked) {
                        isVideoPicked = true;
                        videoInput = state.videoInput.path;
                      }
                      return BlocSelector<VideoCompressionBloc,
                          VideoCompressionState, bool>(
                        selector: (state) {
                          if (state is VideoCompressionInProgress) {
                            return true;
                          }
                          return false;
                        },
                        builder: (context, isCompressing) {
                          return Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: isCompressing
                                      ? null
                                      : !isVideoPicked
                                          ? null
                                          : () => context
                                              .read<VideoCompressionBloc>()
                                              .add(
                                                CompressVideoEvent(
                                                  videoInputPath: videoInput!,
                                                ),
                                              ),
                                  child: const Text('Compress Video'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: isCompressing
                                    ? () => context
                                        .read<VideoCompressionBloc>()
                                        .add(CancelCompressionEvent())
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Cancel'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  Row(
                    children: [
                      BlocSelector<VideoPickerBloc, VideoPickerState, bool>(
                        selector: (state) => state is VideoPickerPicked,
                        builder: (context, hasVideo) {
                          return BlocSelector<VideoCompressionBloc,
                              VideoCompressionState, bool>(
                            selector: (state) =>
                                state is VideoCompressionInProgress,
                            builder: (context, isCompressing) {
                              return Expanded(
                                child: ElevatedButton(
                                  onPressed: isCompressing
                                      ? null
                                      : hasVideo
                                          ? () => context
                                              .read<VideoPickerBloc>()
                                              .add(PickVideoEvent())
                                          : null,
                                  child: const Text('Change Video'),
                                ),
                              );
                            },
                          );
                        },
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
                        BlocSelector<VideoCompressionBloc,
                            VideoCompressionState, double?>(
                          selector: (state) {
                            if (state is VideoCompressionInProgress) {
                              return state.progress;
                            }
                            return 0;
                          },
                          builder: (context, progress) {
                            return Row(
                              children: [
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: (progress ?? 0) / 100,
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  '${(progress ?? 0).round()}%',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            );
                          },
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
                      controller:
                          context.read<VideoCompressionBloc>().scrollController,
                      itemCount:
                          context.watch<VideoCompressionBloc>().logList.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        return Text(
                          context.watch<VideoCompressionBloc>().logList[index],
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
                  //Keep Screen On
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}