// https://gist.github.com/netsmertia/9c588f23391c781fa1eb791f0dce0768

import 'dart:async';
import 'dart:ui';
import 'dart:typed_data';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
// import 'package:flutter/material.dart' show Colors;

const tau = math.pi * 2;

Future<ui.Image> _loadImage(List<int> buffer) {
  final c = Completer<ui.Image>();
  ui.decodeImageFromList(buffer, (img) => c.complete(img));
  return c.future;
}

main() async {
  await SystemChrome.setEnabledSystemUIOverlays([]);
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
  );

  final imgData = await rootBundle.load('img/gui.png');
  final guiImg = await _loadImage(Uint8List.view(imgData.buffer));

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

  final pixelRatio = initialSize.height / 360;
  final deviceTransform = Float64List(16)
    ..[0] = pixelRatio
    ..[5] = pixelRatio
    ..[10] = 1.0
    ..[15] = 1.0;
  final offset = Offset(
    (window.physicalSize.width / pixelRatio - 640) * 0.5,
    (window.physicalSize.height / pixelRatio - 360) * 0.5,
  );

  var previous = Duration.zero;
  final world = World();

  final paint = Paint();

  final bounds = Offset.zero & Size(640, 360);
  final guiBounds = Offset.zero & initialSize / pixelRatio;

  final guiScale = 1 / pixelRatio * window.devicePixelRatio;
  final buttonAreas = _initButtonAreas(guiScale, guiBounds);

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
    final t = delta.inMicroseconds / 1000000; // Duration.microsecondsPerSecond;

    // canvas.drawColor(Color(0xFF1D2B53), BlendMode.src);
    // canvas.drawPaint(Paint()..color = Color(0xFF1D2B53));
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.drawRect(bounds, Paint()..color = Color(0xFF1D2B53));
    canvas.clipRect(bounds);

    world.update(t);
    world.render(t, canvas);
    canvas.restore();

    // 45x77
    // 65x65

    // TODO: Load color palette values form JSON
    // TODO: Move values to JSON file

    _drawControls(
      canvas,
      guiScale,
      guiBounds,
      guiImg,
      paint,
      buttonState,
    );

    _drawButtonAreas(
      canvas,
      buttonAreas,
      Paint()
        ..color = Color(0xFFFFF1E8)
        ..style = PaintingStyle.stroke,
    );

    print(buttonState);

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
        buttonState = 0;
      } else {
        buttonState = _updateButtonState(
          buttonState,
          buttonAreas,
          Offset(d.physicalX / pixelRatio, d.physicalY / pixelRatio),
        );
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

List<RRect> _initButtonAreas(double scale, Rect bounds) {
  final dpadR = 48 * scale;
  final dpadMiniR = 20 * scale;
  final buttonR = 50 * scale;
  return [
    RRect.fromRectAndRadius(
      Rect.fromCircle(
        center:
            (Offset(79, -183) + Offset(45, 77) * 0.5 + Offset(0, -24)) * scale +
                Offset(0, bounds.height),
        radius: dpadR,
      ),
      Radius.circular(dpadR),
    ),
    RRect.fromRectAndRadius(
      Rect.fromCircle(
        center: (Offset(184, -123) + Offset(-77, 45) * 0.5 + Offset(24, 0)) *
                scale +
            Offset(0, bounds.height),
        radius: dpadR,
      ),
      Radius.circular(dpadR),
    ),
    RRect.fromRectAndRadius(
      Rect.fromCircle(
        center: (Offset(124, -18) + Offset(-45, -77) * 0.5 + Offset(0, 24)) *
                scale +
            Offset(0, bounds.height),
        radius: dpadR,
      ),
      Radius.circular(dpadR),
    ),
    RRect.fromRectAndRadius(
      Rect.fromCircle(
        center:
            (Offset(19, -78) + Offset(77, -45) * 0.5 + Offset(-24, 0)) * scale +
                Offset(0, bounds.height),
        radius: dpadR,
      ),
      Radius.circular(dpadR),
    ),

    //
    RRect.fromRectAndRadius(
      Rect.fromCircle(
        center:
            (Offset(79, -183) + Offset(45, 77) * 0.5 + Offset(0, 15)) * scale +
                Offset(0, bounds.height),
        radius: dpadMiniR,
      ),
      Radius.circular(dpadMiniR),
    ),
    RRect.fromRectAndRadius(
      Rect.fromCircle(
        center: (Offset(184, -123) + Offset(-77, 45) * 0.5 + Offset(-15, 0)) *
                scale +
            Offset(0, bounds.height),
        radius: dpadMiniR,
      ),
      Radius.circular(dpadMiniR),
    ),
    RRect.fromRectAndRadius(
      Rect.fromCircle(
        center: (Offset(124, -18) + Offset(-45, -77) * 0.5 + Offset(0, -15)) *
                scale +
            Offset(0, bounds.height),
        radius: dpadMiniR,
      ),
      Radius.circular(dpadMiniR),
    ),
    RRect.fromRectAndRadius(
      Rect.fromCircle(
        center:
            (Offset(19, -78) + Offset(77, -45) * 0.5 + Offset(15, 0)) * scale +
                Offset(0, bounds.height),
        radius: dpadMiniR,
      ),
      Radius.circular(dpadMiniR),
    ),

    //
    RRect.fromRectAndRadius(
      Rect.fromCircle(
        center: (Offset(-157, -113) + Offset(65, 65) * 0.5 + Offset(-12, 1)) *
                scale +
            Offset(bounds.width, bounds.height),
        radius: buttonR,
      ),
      Radius.circular(buttonR),
    ),
    RRect.fromRectAndRadius(
      Rect.fromCircle(
        center: (Offset(-92, -159) + Offset(65, 65) * 0.5 + Offset(5, -12)) *
                scale +
            Offset(bounds.width, bounds.height),
        radius: buttonR,
      ),
      Radius.circular(buttonR),
    ),
    RRect.fromRectAndRadius(
      Rect.fromCircle(
        center:
            (Offset(-82, -82) + Offset(65, 65) * 0.5 + Offset(5, 11)) * scale +
                Offset(bounds.width, bounds.height),
        radius: buttonR,
      ),
      Radius.circular(buttonR),
    ),
  ];
}

int _updateButtonState(int state, List<RRect> areas, Offset point) {
  for (int i = 0; i < areas.length; i++) {
    if (areas[i].contains(point)) state |= 1 << i;
  }
  return state;
}

_drawButtonAreas(Canvas canvas, List<RRect> spots, Paint paint) {
  for (int i = 0; i < spots.length; i++) {
    canvas.drawRRect(spots[i], paint);
  }
}

_drawControls(
  Canvas canvas,
  double scale,
  Rect bounds,
  Image img,
  Paint paint,
  int state,
) {
  canvas.drawAtlas(
    img,
    [
      RSTransform.fromComponents(
        rotation: 0,
        scale: scale,
        anchorX: 0,
        anchorY: 0,
        translateX: 79 * scale,
        translateY: bounds.height - 183 * scale,
      ),
      RSTransform.fromComponents(
        rotation: 1.5708,
        scale: scale,
        anchorX: 0,
        anchorY: 0,
        translateX: 184 * scale,
        translateY: bounds.height - 123 * scale,
      ),
      RSTransform.fromComponents(
        rotation: 3.1416,
        scale: scale,
        anchorX: 0,
        anchorY: 0,
        translateX: 124 * scale,
        translateY: bounds.height - 18 * scale,
      ),
      RSTransform.fromComponents(
        rotation: -1.5708,
        scale: scale,
        anchorX: 0,
        anchorY: 0,
        translateX: 19 * scale,
        translateY: bounds.height - 78 * scale,
      ),
      RSTransform.fromComponents(
        rotation: 0,
        scale: scale,
        anchorX: 0,
        anchorY: 0,
        translateX: bounds.width - 157 * scale,
        translateY: bounds.height - 113 * scale,
      ),
      RSTransform.fromComponents(
        rotation: 0,
        scale: scale,
        anchorX: 0,
        anchorY: 0,
        translateX: bounds.width - 92 * scale,
        translateY: bounds.height - 159 * scale,
      ),
      RSTransform.fromComponents(
        rotation: 0,
        scale: scale,
        anchorX: 0,
        anchorY: 0,
        translateX: bounds.width - 82 * scale,
        translateY: bounds.height - 82 * scale,
      ),
    ],
    [
      Rect.fromLTWH(0, 0, 45, 77),
      Rect.fromLTWH(0, 0, 45, 77),
      Rect.fromLTWH(0, 0, 45, 77),
      Rect.fromLTWH(0, 0, 45, 77),
      Rect.fromLTWH(90, 0, 65, 65),
      Rect.fromLTWH(90, 0, 65, 65),
      Rect.fromLTWH(90, 0, 65, 65),
    ],
    [
      Color(0xFF83769C),
      Color(0xFF83769C),
      Color(0xFF83769C),
      Color(0xFF83769C),
      Color(0xFFFF004D),
      Color(0xFF29ADFF),
      Color(0xFF00E436),
    ],
    BlendMode.dstIn,
    null,
    paint,
  );
}
