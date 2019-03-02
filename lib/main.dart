// https://gist.github.com/netsmertia/9c588f23391c781fa1eb791f0dce0768

import 'dart:async';
import 'dart:ui';
import 'dart:typed_data';
import 'dart:math' as math;
import 'dart:convert';

import 'package:flutter/services.dart';
// import 'package:flutter/material.dart' show Colors;

const tau = math.pi * 2;

main() async {
  await SystemChrome.setEnabledSystemUIOverlays([]);
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
  );

  final imgData = await rootBundle.load('img/gui.png');
  final guiImg = await _loadImage(Uint8List.view(imgData.buffer));
  final engineData = jsonDecode(await rootBundle.loadString('data/data.json'));

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

  final paint = Paint();

  final bounds = Offset.zero & screenSize;

  final guiData = _loadGuiData(
    1 / pixelRatio * window.devicePixelRatio,
    Offset.zero & initialSize / pixelRatio,
    engineData,
  );

  final btnTransforms = guiData[0];
  final btnUpRects = guiData[1];
  final btnDnRects = guiData[2];
  final btnMasks = guiData[3];
  final btnColors = guiData[4];
  final btnAreas = guiData[5];

  final btnRects = List<Rect>.from(btnUpRects);

  final updateBtnRects = (state) {
    for (int i = 0; i < btnRects.length; i++) {
      btnRects[i] = state & btnMasks[i] > 0 ? btnDnRects[i] : btnUpRects[i];
    }
    return btnRects;
  };

  int buttonState = 0;

  window.onBeginFrame = (now) {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, bounds);
    // final guiCanvas =
    //     Canvas(recorder, Offset.zero & (initialSize / window.devicePixelRatio));

    // print(
    //     '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> $guiBounds');

    final delta = previous == Duration.zero ? Duration.zero : now - previous;
    previous = now;
    final t = delta.inMicroseconds / Duration.microsecondsPerSecond; // 1000000

    // canvas.drawColor(Color(0xFF1D2B53), BlendMode.src);
    // canvas.drawPaint(Paint()..color = Color(0xFF1D2B53));
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.drawRect(bounds, Paint()..color = Color(0xFF1D2B53));
    canvas.clipRect(bounds);

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

    // _drawButtonAreas(
    //   canvas,
    //   buttonAreas,
    //   Paint()
    //     ..color = Color(0xFFFFF1E8)
    //     ..style = PaintingStyle.stroke,
    // );

    // print(buttonState);

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

Future<Image> _loadImage(List<int> buffer) {
  final c = Completer<Image>();
  decodeImageFromList(buffer, (img) => c.complete(img));
  return c.future;
}

// _drawButtonAreas(Canvas canvas, List<RRect> spots, Paint paint) {
//   for (int i = 0; i < spots.length; i++) {
//     canvas.drawRRect(spots[i], paint);
//   }
// }

List<Rect> _loadRects(List rects) =>
    rects.map((r) => Rect.fromLTWH(r[0], r[1], r[2], r[3])).toList();

List _loadGuiData(double scale, Rect bounds, data) {
  final d = data['buttons'];
  return [
    (d['transforms'] as List)
        .map((t) => RSTransform.fromComponents(
              rotation: t[0],
              scale: scale,
              anchorX: 0,
              anchorY: 0,
              translateX: t[1] * bounds.width + t[3] * scale,
              translateY: t[2] * bounds.height + t[4] * scale,
            ))
        .toList(),
    _loadRects(d['upRects']),
    _loadRects(d['dnRects']),
    d['masks'],
    (d['colors'] as List).map((c) => Color(c)).toList(),
    (d['areas'] as List)
        .map((a) => RRect.fromRectAndRadius(
              Rect.fromCircle(
                center: Offset(a[0], a[1]) * scale +
                    Offset(a[3] * bounds.width, a[4] * bounds.height),
                radius: a[2] * scale,
              ),
              Radius.circular(a[2] * scale),
            ))
        .toList()
  ];
}
