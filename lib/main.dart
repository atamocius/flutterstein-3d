// https://gist.github.com/netsmertia/9c588f23391c781fa1eb791f0dce0768

import 'dart:async';
import 'dart:ui';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:flutter/services.dart';

final deviceTransform = Float64List(16)
  ..[0] = window.devicePixelRatio
  ..[5] = window.devicePixelRatio
  ..[10] = 1.0
  ..[15] = 1.0;

const tau = math.pi * 2;

main() async {
  await SystemChrome.setEnabledSystemUIOverlays([]);
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.landscapeLeft],
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

  print(window.physicalSize);
  print(initialSize);
  print(window.devicePixelRatio);
  print(window.physicalSize / window.devicePixelRatio);
  print(Offset.zero & (window.physicalSize / window.devicePixelRatio));

  var previous = Duration.zero;
  final world = World();

  window.onBeginFrame = (now) {
    final paintBounds = Offset.zero & (initialSize / window.devicePixelRatio);
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, paintBounds);
    canvas.translate(paintBounds.width / 2.0, paintBounds.height / 2.0);

    final delta = previous == Duration.zero ? Duration.zero : now - previous;
    previous = now;
    final t = delta.inMicroseconds / Duration.microsecondsPerSecond;

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
    world.input(pointer.physicalX, pointer.physicalY);
  };
}

class World {
  var _turn = 0.0;
  double _x = 0;
  double _y = 0;
  static const rotationsPerSecond = 0.25;

  // World(this._x, this._y);
  World();

  void input(double x, double y) {
    print('$x, $y');
    _x = x - 640;
    _y = y - 360;
  }

  void update(double t) {
    _turn += t * rotationsPerSecond;
  }

  void render(double t, Canvas canvas) {
    // canvas.drawPaint(Paint()..color = Color(0xff880000));
    canvas.save();
    canvas.translate(_x, _y);
    canvas.rotate(tau * _turn);
    var white = Paint()..color = Color(0xffffffff);
    var size = 100.0;
    canvas.drawRect(Rect.fromLTWH(-size / 2, -size / 2, size, size), white);
    canvas.restore();
  }
}
