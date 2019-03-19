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

  var viewSize = Size(640, 360);
  var bounds = Offset.zero & viewSize;

  var deviceTransform = Float64List(16);
  Offset offset;
  Buttons btns;
  var btnAtlas = await loadImage('img/gui.png');

  var handleMetricsChanged = () async {
    var size = window.physicalSize,
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

  var lvl = await loadLevel('data/level.json');
  var g = Game(viewSize, lvl);
  var zero = Duration.zero;
  var prev = zero;

  window.onBeginFrame = (now) {
    var recorder = PictureRecorder();
    var c = Canvas(recorder, bounds);

    var delta = prev == zero ? zero : now - prev;
    prev = now;
    var t = delta.inMicroseconds / 1000000;

    c.save();
    c.translate(offset.dx, offset.dy);
    c.clipRect(bounds);
    g.update(t, btns.pressed);
    g.render(c);
    c.restore();

    btns.render(c);

    var picture = recorder.endRecording();
    var builder = SceneBuilder()
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
