// https://gist.github.com/netsmertia/9c588f23391c781fa1eb791f0dce0768

import 'dart:async';
import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'utils.dart';
import 'game.dart';
import 'level.dart';

main() async {
  await SystemChrome.setEnabledSystemUIOverlays([]);
  // await SystemChrome.setPreferredOrientations(
  //   [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
  // );

  final initialSize = await Future<Size>(() {
    if (window.physicalSize.isEmpty) {
      final completer = Completer<Size>();
      window.onMetricsChanged = () {
        if (!window.physicalSize.isEmpty) {
          completer.complete(window.physicalSize);
        }
      };
      return completer.future;
    }
    return window.physicalSize;
  });

  // print(
  //     '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${window.physicalSize}');
  // print(
  //     '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> $initialSize');
  // print(
  //     '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ${window.physicalSize.height / 360}');
  // print(
  //     '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ${initialSize / 360}');

  // TODO: Always check to use the larger value between W & H as width
  // TODO: Add "start/pause" button
  // TODO: Implement swipe left/right to handle weapon switching
  final viewSize = Size(640, 360);
  final bounds = Offset.zero & viewSize;

  final com = NativeDeviceOrientationCommunicator();
  final landscape = [
    NativeDeviceOrientation.landscapeLeft,
    NativeDeviceOrientation.landscapeRight,
  ];

  final orientation = await com.orientation();
  final pixelRatio = landscape.contains(orientation)
      ? initialSize.height / viewSize.height
      : initialSize.width / viewSize.width;

  final deviceTransform = Float64List(16)
    ..[0] = pixelRatio
    ..[5] = pixelRatio
    ..[10] = 1
    ..[15] = 1;
  var offset = (initialSize / pixelRatio - viewSize as Offset) * 0.5;

  var btns = await loadButtons(
    'data/buttons.json',
    'img/gui.png',
    pixelRatio,
    1 / pixelRatio * window.devicePixelRatio,
    Offset.zero & initialSize / pixelRatio,
  );

  window.onMetricsChanged = () async {
    print('orientation change!');
    final o = await com.orientation();
    var size = window.physicalSize;

    // Landscape : Portrait
    final pr = landscape.contains(o)
        ? size.height / viewSize.height
        : size.width / viewSize.width;

    deviceTransform
      ..[0] = pr
      ..[5] = pr
      ..[10] = 1
      ..[15] = 1;

    offset = (size / pr - viewSize as Offset) * 0.5;

    btns = await loadButtons(
      'data/buttons.json',
      'img/gui.png',
      pr,
      1 / pr * window.devicePixelRatio,
      Offset.zero & size / pr,
    );
  };

  final testLevel = Level(
    [
      8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 4, 4, 6, 4, 4, 6, 4, 6, 4, 4, 4, 6, 4, //
      8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, //
      8, 0, 3, 3, 0, 0, 0, 0, 0, 8, 8, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, //
      8, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, //
      8, 0, 3, 3, 0, 0, 0, 0, 0, 8, 8, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, //
      8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 4, 0, 0, 0, 0, 0, 6, 6, 6, 0, 6, 4, 6, //
      8, 8, 8, 8, 0, 8, 8, 8, 8, 8, 8, 4, 4, 4, 4, 4, 4, 6, 0, 0, 0, 0, 0, 6, //
      7, 7, 7, 7, 0, 7, 7, 7, 7, 0, 8, 0, 8, 0, 8, 0, 8, 4, 0, 4, 0, 6, 0, 6, //
      7, 7, 0, 0, 0, 0, 0, 0, 7, 8, 0, 8, 0, 8, 0, 8, 8, 6, 0, 0, 0, 0, 0, 6, //
      7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 6, 0, 0, 0, 0, 0, 4, //
      7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 6, 0, 6, 0, 6, 0, 6, //
      7, 7, 0, 0, 0, 0, 0, 0, 7, 8, 0, 8, 0, 8, 0, 8, 8, 6, 4, 6, 0, 6, 6, 6, //
      7, 7, 7, 7, 0, 7, 7, 7, 7, 8, 8, 4, 0, 6, 8, 4, 8, 3, 3, 3, 0, 3, 3, 3, //
      2, 2, 2, 2, 0, 2, 2, 2, 2, 4, 6, 4, 0, 0, 6, 0, 6, 3, 0, 0, 0, 0, 0, 3, //
      2, 2, 0, 0, 0, 0, 0, 2, 2, 4, 0, 0, 0, 0, 0, 0, 4, 3, 0, 0, 0, 0, 0, 3, //
      2, 0, 0, 0, 0, 0, 0, 0, 2, 4, 0, 0, 0, 0, 0, 0, 4, 3, 0, 0, 0, 0, 0, 3, //
      1, 0, 0, 0, 0, 0, 0, 0, 1, 4, 4, 4, 4, 4, 6, 0, 6, 3, 3, 0, 0, 0, 3, 3, //
      2, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 1, 2, 2, 2, 6, 6, 0, 0, 5, 0, 5, 0, 5, //
      2, 2, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 2, 2, 0, 5, 0, 5, 0, 0, 0, 5, 5, //
      2, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 5, 0, 5, 0, 5, 0, 5, 0, 5, //
      1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, //
      2, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 5, 0, 5, 0, 5, 0, 5, 0, 5, //
      2, 2, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 2, 2, 0, 5, 0, 5, 0, 0, 0, 5, 5, //
      2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 5, 5, 5, 5, 5, 5, 5, 5, 5, //
    ],
    24,
    await loadImage('img/wolf3d.png'),
    4,
    Vector2(22, 10), // origin the bottom-left of the map array
    Vector2(-1, 0),
  );

  final game = Game(viewSize, testLevel);
  var previous = Duration.zero;
  final paint = Paint();

  int buttonState = 0;
  final btnRects = List<Rect>(btns.count);
  final pressed = (b) => buttonState & btns.masks[b] > 0;

  window.onBeginFrame = (now) {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, bounds);

    final delta = previous == Duration.zero ? Duration.zero : now - previous;
    previous = now;
    final t = delta.inMicroseconds / 1000000;

    // canvas.drawColor(Color(0xFF1D2B53), BlendMode.src);
    // canvas.drawPaint(Paint()..color = Color(0xFF1D2B53));
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    // canvas.drawRect(bounds, Paint()..color = Color(0xFF1D2B53));
    canvas.clipRect(bounds);
    game.update(t, pressed);
    game.render(canvas);
    canvas.restore();

    // Update button states
    btns.updateRects(btnRects, buttonState);
    // Draw buttons
    canvas.drawAtlas(
      btns.atlas,
      btns.transforms,
      btnRects,
      btns.colors,
      BlendMode.dstIn,
      null,
      paint,
    );

    // Draw button hit areas
    // final debugPaint = Paint()
    //   ..color = Color(0xFFFFF1E8)
    //   ..style = PaintingStyle.stroke;
    // for (int i = 0; i < btnAreas.length; i++) {
    //   canvas.drawRRect(btnAreas[i], debugPaint);
    // }

    final picture = recorder.endRecording();
    final builder = SceneBuilder()
      ..pushTransform(deviceTransform)
      ..addPicture(Offset.zero, picture)
      ..pop();

    window.render(builder.build());
    window.scheduleFrame();
  };

  window.scheduleFrame();

  window.onPointerDataPacket = (p) => buttonState = btns.updateState(p.data);
}
