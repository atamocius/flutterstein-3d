import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math.dart';
import 'buttons.dart';
import 'level.dart';

double frac(double v) => v - v.floor();
double invAbs(double v) => (1 / v).abs();
num sq(num v) => v * v;
int col(b, s, p) => (((b * s).floor() & 0xff) << p);

int greyscale(num s, [int b = 255]) =>
    (0xff000000 | col(b, s, 16) | col(b, s, 8) | col(b, s, 0)) & 0xFFFFFFFF;

ilst(d) => d.cast<int>();
dlst(d) => d.cast<double>();

Future<Image> loadImage(String key) async {
  final d = await rootBundle.load(key);
  final b = Uint8List.view(d.buffer);
  final c = Completer<Image>();
  decodeImageFromList(b, (i) => c.complete(i));
  return c.future;
}

Future<Level> loadLevel(String key) async {
  final d = jsonDecode(await rootBundle.loadString(key));
  return Level(
    ilst(d['map']),
    d['mapSize'],
    await loadImage(d['atlas']),
    d['atlasSize'],
    // origin the bottom-left of the map array
    vec(dlst(d['pos'])),
    vec(dlst(d['dir'])),
    ilst(d['ceil']),
    ilst(d['floor']),
  );
}

Future<Buttons> loadButtons(
  String key,
  double pixelRatio,
  double scale,
  Rect bounds,
  Image atlas,
) async {
  final d = jsonDecode(await rootBundle.loadString(key));
  return Buttons(
    pixelRatio,
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
    rects(d['upRects']),
    rects(d['dnRects']),
    ilst(d['masks']),
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
        .toList(),
    atlas,
  );
}

List<Rect> rects(List rects) =>
    rects.map((r) => Rect.fromLTWH(r[0], r[1], r[2], r[3])).toList();

Vector2 vec(v) => Vector2(v[0], v[1]);
