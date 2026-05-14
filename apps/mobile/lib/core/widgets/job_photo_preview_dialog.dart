import 'package:flutter/material.dart';

import 'job_photo_widget.dart';

void showJobPhotoPreviewDialog({
  required BuildContext context,
  required String url,
}) {
  showDialog<void>(
    context: context,
    builder: (context) => Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Center(child: JobPhotoWidget(url: url)),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
