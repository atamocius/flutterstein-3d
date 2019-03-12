// https://gist.github.com/netsmertia/9c588f23391c781fa1eb791f0dce0768

import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'utils.dart';
import 'game.dart';
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

  // https://pacoup.com/2011/06/12/list-of-true-169-resolutions/
  final viewSize = Size(640, 360);
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

  final lvl = await loadLevel('data/level.json');
  final game = Game(viewSize, lvl);
  final zero = Duration.zero;
  var prev = zero;

  window.onBeginFrame = (now) {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, bounds);

    final delta = prev == zero ? zero : now - prev;
    prev = now;
    final t = delta.inMicroseconds / 1000000;

    // print(1.0 / t); // FPS counter

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
