// https://gist.github.com/netsmertia/9c588f23391c781fa1eb791f0dce0768

import 'dart:ui';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:flutter/services.dart';

const tau = math.pi * 2;

main() async {
  await SystemChrome.setEnabledSystemUIOverlays([]);
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
  );

  final pixelRatio = window.physicalSize.height / 360;
  final deviceTransform = Float64List(16)
    ..[0] = pixelRatio
    ..[5] = pixelRatio
    ..[10] = 1.0
    ..[15] = 1.0;

  var previous = Duration.zero;
  final world = World();

  window.onBeginFrame = (now) {
    final paintBounds = Offset.zero & Size(640, 360);
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, paintBounds);

    final delta = previous == Duration.zero ? Duration.zero : now - previous;
    previous = now;
    final t = delta.inMicroseconds / 1000000; // Duration.microsecondsPerSecond;

    world.update(t);
    world.render(t, canvas);

    final picture = recorder.endRecording();
    final builder = SceneBuilder()
      ..pushTransform(deviceTransform)
      ..addPicture(Offset.zero, picture)
      ..pop();

    window.render(builder.build());
    window.scheduleFrame();
  };

  window.scheduleFrame();

  window.onPointerDataPacket = (packet) {
    final pointer = packet.data.first;
    world.input(
      pointer.physicalX / pixelRatio,
      pointer.physicalY / pixelRatio,
    );
  };
}

class World {
  var _turn = 0.0;
  double _x = 320;
  double _y = 180;
  static const rotationsPerSecond = 0.25;

  // World(this._x, this._y);
  World();

  void input(double x, double y) {
    print('$x, $y');
    // _x = x - 640;
    // _y = y - 360;
    _x = x;
    _y = y;
  }

  void update(double t) {
    _turn += t * rotationsPerSecond;
  }

  void render(double t, Canvas canvas) {
    // canvas.drawPaint(Paint()..color = Color(0xff880000));
    canvas.save();
    canvas.translate(_x, _y);
    // canvas.translate(320, 180);
    // canvas.rotate(tau * _turn);
    var white = Paint()..color = Color(0xffffffff);
    var size = 100.0;
    canvas.drawRect(Rect.fromLTWH(-size / 2, -size / 2, size, size), white);
    canvas.restore();
  }
}
