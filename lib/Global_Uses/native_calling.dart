import 'package:flutter/services.dart';

class NativeCallback {
  static const MethodChannel _platform =
      const MethodChannel('com.youtubetutorial.generation/nativeCallBack');

  Future<String> getTheVideoThumbnail({required String videoPath}) async {
    print('Thumbnail Take');

    final String thumbnailPath = await _platform
        .invokeMethod('makeVideoThumbnail', {'videoPath': videoPath});

    print("Thumbnail Path is: $thumbnailPath");

    return thumbnailPath;
  }
}
