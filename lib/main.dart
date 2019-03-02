// https://gist.github.com/netsmertia/9c588f23391c781fa1eb791f0dce0768

import 'dart:async';
import 'dart:ui';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'utils.dart';

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
  final world = World();
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

  int buttonState = 0;
  final btnRects = List<Rect>.from(btnUpRects);

  final updateBtnRects = (state) {
    for (int i = 0; i < btnRects.length; i++) {
      btnRects[i] = state & btnMasks[i] > 0 ? btnDnRects[i] : btnUpRects[i];
    }
    return btnRects;
  };

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
    // print(buttonState);
    world.update(t);
    world.render(t, canvas);
    canvas.restore();

    // Draw buttons
    canvas.drawAtlas(
      guiImg,
      btnTransforms,
      updateBtnRects(buttonState),
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

  window.onPointerDataPacket = (packet) {
    buttonState = 0;
    for (final d in packet.data) {
      if (d.change == PointerChange.up) {
        // Throw away the previously set bits since we can't determine for which
        // button the "up" action is for (the player might have moved their finger
        // outside of the button or to a different button)
        buttonState = 0;
      } else {
        // Update the button state
        for (int i = 0; i < btnAreas.length; i++) {
          if (btnAreas[i].contains(
              Offset(d.physicalX / pixelRatio, d.physicalY / pixelRatio))) {
            buttonState |= 1 << i;
          }
        }
      }
    }
  };
}

class World {
  static const tau = math.pi * 2;
  var _turn = 0.0;
  double _x = 320;
  double _y = 180;
  static const rotationsPerSecond = 0.25;

  // World(this._x, this._y);
  World();

  void input(double x, double y) {
    // print('$x, $y');
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
