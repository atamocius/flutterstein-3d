// https://gist.github.com/netsmertia/9c588f23391c781fa1eb791f0dce0768

import 'dart:async';
import 'dart:ui';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'utils.dart';
import 'game.dart';

main() async {
  await SystemChrome.setEnabledSystemUIOverlays([]);
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
  );

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

  print(
      '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${window.physicalSize}');
  print(
      '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> $initialSize');
  print(
      '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ${window.physicalSize.height / 360}');
  print(
      '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ${initialSize / 360}');

  final screenSize = Size(640, 360);
  final pixelRatio = initialSize.height / screenSize.height;
  final deviceTransform = Float64List(16)
    ..[0] = pixelRatio
    ..[5] = pixelRatio
    ..[10] = 1.0
    ..[15] = 1.0;
  final offset =
      (window.physicalSize / pixelRatio - screenSize as Offset) * 0.5;

  var previous = Duration.zero;
  final bounds = Offset.zero & screenSize;
  final paint = Paint();

  final guiImg = await loadImage('img/gui.png');
  final data = await loadData(
    'data/data.json',
    1 / pixelRatio * window.devicePixelRatio,
    Offset.zero & initialSize / pixelRatio,
  );

  final btnTransforms = data[0];
  final btnUpRects = data[1];
  final btnDnRects = data[2];
  final btnMasks = data[3];
  final btnColors = data[4];
  final btnAreas = data[5];

  final game = Game();
  int buttonState = 0;
  final btnRects = List<Rect>.from(btnUpRects);

  final pressed = (b) => buttonState & btnMasks[b] > 0;

  window.onBeginFrame = (now) {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, bounds);

    final delta = previous == Duration.zero ? Duration.zero : now - previous;
    previous = now;
    final t = delta.inMicroseconds / 1000000; // Duration.microsecondsPerSecond;

    // canvas.drawColor(Color(0xFF1D2B53), BlendMode.src);
    // canvas.drawPaint(Paint()..color = Color(0xFF1D2B53));
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.drawRect(bounds, Paint()..color = Color(0xFF1D2B53));
    canvas.clipRect(bounds);
    game.update(t, pressed);
    game.render(t, canvas);
    canvas.restore();

    // Update button states
    updateRects(buttonState, btnRects, btnUpRects, btnDnRects, btnMasks);
    // Draw buttons
    canvas.drawAtlas(
      guiImg,
      btnTransforms,
      btnRects,
      btnColors,
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

  window.onPointerDataPacket =
      (p) => buttonState = handlePointers(p.data, pixelRatio, btnAreas);
}
