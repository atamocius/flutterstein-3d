// https://gist.github.com/netsmertia/9c588f23391c781fa1eb791f0dce0768

import 'dart:async';
import 'dart:ui';
import 'dart:typed_data';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:convert';

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

  final engineData = jsonDecode(await rootBundle.loadString('data/data.json'));

  print(engineData['controls']['areas']);

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
  // final buttonAreas = _initButtonAreas(guiScale, guiBounds);
  // final buttonAreas =
  //     _loadButtonAreas(guiScale, guiBounds, engineData['controls']['areas']);

  final guiData = _loadGuiData(
    guiScale,
    guiBounds,
    engineData['controls']['transforms'],
    engineData['controls']['btnUpRects'],
    engineData['controls']['btnDnRects'],
    engineData['controls']['colors'],
    engineData['controls']['areas'],
  );

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

    // TODO: Load color palette values form JSON
    // TODO: Move values to JSON file

    _drawControls(
      canvas,
      guiImg,
      paint,
      guiData[0],
      guiData[1](buttonState),
      guiData[2],
    );

    // _drawButtonAreas(
    //   canvas,
    //   buttonAreas,
    //   Paint()
    //     ..color = Color(0xFFFFF1E8)
    //     ..style = PaintingStyle.stroke,
    // );

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
          guiData[3],
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

List<Rect> _loadRects(List rects) => rects
    .map((r) => Rect.fromLTWH(
        r[0].toDouble(), r[1].toDouble(), r[2].toDouble(), r[3].toDouble()))
    .toList();

List _loadGuiData(
  double scale,
  Rect bounds,
  List transforms,
  List upRects,
  List downRects,
  List colors,
  List areas,
) {
  var upR = _loadRects(upRects);
  var dnR = _loadRects(downRects);
  return [
    transforms
        .map((t) => RSTransform.fromComponents(
              rotation: t[0].toDouble(),
              scale: scale,
              anchorX: 0,
              anchorY: 0,
              translateX: t[1] * bounds.width + t[3] * scale,
              translateY: t[2] * bounds.height + t[4] * scale,
            ))
        .toList(),
    (state) => [
          state & 17 > 0 ? dnR[0] : upR[0],
          state & 34 > 0 ? dnR[1] : upR[1],
          state & 68 > 0 ? dnR[2] : upR[2],
          state & 136 > 0 ? dnR[3] : upR[3],
          state & 256 > 0 ? dnR[4] : upR[4],
          state & 512 > 0 ? dnR[5] : upR[5],
          state & 1024 > 0 ? dnR[6] : upR[6],
        ],
    colors.map((c) => Color(c)).toList(),
    areas
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

_drawControls(
  Canvas canvas,
  Image img,
  Paint paint,
  List<RSTransform> transforms,
  List<Rect> rects,
  List<Color> colors,
) {
  canvas.drawAtlas(
    img,
    transforms,
    rects,
    colors,
    BlendMode.dstIn,
    null,
    paint,
  );
}
