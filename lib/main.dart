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

    // FPS counter
    // print(1.0 / t);

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.clipRect(bounds);
    game.update(t, btns.pressed);
    game.render(canvas);
    canvas.restore();

    // Draw buttons
    btns.render(canvas);

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
