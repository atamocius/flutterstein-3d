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

int gs(num s, [int b = 255]) =>
    (0xff000000 | col(b, s, 16) | col(b, s, 8) | col(b, s, 0)) & 0xFFFFFFFF;

ilst(d) => d.cast<int>();
dlst(d) => d.cast<double>();

Future<Image> loadImage(String k) async {
  var d = await rootBundle.load(k);
  var b = Uint8List.view(d.buffer);
  var c = Completer<Image>();
  decodeImageFromList(b, (i) => c.complete(i));
  return c.future;
}

Future<Level> loadLevel(String k) async {
  var d = jsonDecode(await rootBundle.loadString(k));
  return Level(
    ilst(d['map']),
    d['mapSize'],
    await loadImage(d['atlas']),
    d['atlasSize'],
    vec(dlst(d['pos'])),
    vec(dlst(d['dir'])),
    ilst(d['ceil']),
    ilst(d['floor']),
  );
}

Future<Buttons> loadButtons(
    String k, double r, double s, Rect b, Image i) async {
  var d = jsonDecode(await rootBundle.loadString(k));
  return Buttons(
    r,
    (d['transforms'] as List)
        .map((t) => RSTransform.fromComponents(
              rotation: t[0],
              scale: s,
              anchorX: 0,
              anchorY: 0,
              translateX: t[1] * b.width + t[3] * s,
              translateY: t[2] * b.height + t[4] * s,
            ))
        .toList(),
    rects(d['upRects']),
    rects(d['dnRects']),
    ilst(d['masks']),
    (d['colors'] as List).map((c) => Color(c)).toList(),
    (d['areas'] as List)
        .map((a) => RRect.fromRectAndRadius(
              Rect.fromCircle(
                center: Offset(a[0], a[1]) * s +
                    Offset(a[3] * b.width, a[4] * b.height),
                radius: a[2] * s,
              ),
              Radius.circular(a[2] * s),
            ))
        .toList(),
    i,
  );
}

List<Rect> rects(List l) =>
    l.map((r) => Rect.fromLTWH(r[0], r[1], r[2], r[3])).toList();

Vector2 vec(v) => Vector2(v[0], v[1]);
