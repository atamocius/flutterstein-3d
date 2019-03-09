// https://gist.github.com/netsmertia/9c588f23391c781fa1eb791f0dce0768

import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math.dart';
import 'utils.dart';
import 'game.dart';
import 'level.dart';
import 'buttons.dart';

main() async {
  await SystemChrome.setEnabledSystemUIOverlays([]);
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

  // print(
  //     '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${window.physicalSize}');
  // print(
  //     '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> $initialSize');
  // print(
  //     '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ${window.physicalSize.height / 360}');
  // print(
  //     '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ${initialSize / 360}');

  // TODO: Add "start/pause" button
  // TODO: Implement swipe left/right to handle weapon switching
  final viewSize = Size(256, 144);
  final bounds = Offset.zero & viewSize;

  final deviceTransform = Float64List(16);
  Offset offset;
  Buttons btns;
  final btnAtlas = await loadImage('img/gui.png');

  final handleMetricsChanged = () async {
    final size = window.physicalSize,
        pixelRatio = size.shortestSide / viewSize.shortestSide;

    deviceTransform
      ..[0] = pixelRatio
      ..[5] = pixelRatio
      ..[10] = 1
      ..[15] = 1;

    offset = (size / pixelRatio - viewSize as Offset) * 0.5;

    btns = await loadButtons(
      'data/buttons.json',
      pixelRatio,
      1 / pixelRatio * window.devicePixelRatio,
      Offset.zero & size / pixelRatio,
      btnAtlas,
    );
  };

  handleMetricsChanged();
  window.onMetricsChanged = handleMetricsChanged;

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
    [
      Sprite(Vector2(20.5, 11.5), 10), //green light in front of playerstart
      //green lights in every room
      Sprite(Vector2(18.5, 4.5), 10),
      Sprite(Vector2(10.0, 4.5), 10),
      Sprite(Vector2(10.0, 12.5), 10),
      Sprite(Vector2(3.5, 6.5), 10),
      Sprite(Vector2(3.5, 20.5), 10),
      Sprite(Vector2(3.5, 14.5), 10),
      Sprite(Vector2(14.5, 20.5), 10),

      //row of pillars in front of wall: fisheye test
      Sprite(Vector2(18.5, 10.5), 9),
      Sprite(Vector2(18.5, 11.5), 9),
      Sprite(Vector2(18.5, 12.5), 9),

      //some barrels around the map
      Sprite(Vector2(21.5, 1.5), 8),
      Sprite(Vector2(15.5, 1.5), 8),
      Sprite(Vector2(16.0, 1.8), 8),
      Sprite(Vector2(16.2, 1.2), 8),
      Sprite(Vector2(3.5, 2.5), 8),
      Sprite(Vector2(9.5, 15.5), 8),
      Sprite(Vector2(10.0, 15.1), 8),
      Sprite(Vector2(10.5, 15.8), 8),
    ],
  );

  final game = Game(viewSize, testLevel);
  final zero = Duration.zero;
  var prev = zero;

  window.onBeginFrame = (now) {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, bounds);

    final delta = prev == zero ? zero : now - prev;
    prev = now;
    final t = delta.inMicroseconds / 1000000;

    print(1.0 / t); // FPS counter

    // canvas.drawColor(Color(0xFF1D2B53), BlendMode.src);
    // canvas.drawPaint(Paint()..color = Color(0xFF1D2B53));
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    // canvas.drawRect(bounds, Paint()..color = Color(0xFF1D2B53));
    canvas.clipRect(bounds);
    game.update(t, btns.pressed);
    game.render(canvas);
    canvas.restore();

    // Draw buttons
    btns.render(canvas);

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

    window
      ..render(builder.build())
      ..scheduleFrame();
  };

  window
    ..scheduleFrame()
    ..onPointerDataPacket = (p) => btns.update(p.data);
}
