import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPickerWidget extends StatelessWidget {
  Function() onTap;

  VideoPickerWidget({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      dashPattern: const [8, 1],
      radius: const Radius.circular(8),
      borderType: BorderType.RRect,
      child: GestureDetector(
        onTap: onTap,
        child: const SizedBox(
          width: double.infinity,
          height: 160,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_outlined),
              Text('Pick your video'),
            ],
          ),
        ),
      ),
    );
  }
}
