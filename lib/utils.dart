import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math.dart';
import 'buttons.dart';
import 'level.dart';

var rb = rootBundle;

num fr(num v) => v - v.floor();
num iA(num v) => (1 / v).abs();
num sq(num v) => v * v;
int co(b, s, p) => (((b * s).floor() & 0xff) << p);

int gs(num s, [int b = 255]) =>
    (0xff000000 | co(b, s, 16) | co(b, s, 8) | co(b, s, 0)) & 0xFFFFFFFF;

it(d) => d.cast<int>();
dt(d) => d.cast<double>();

Future<Image> li(String k) async {
  var d = await rb.load(k),
      b = Uint8List.view(d.buffer),
      c = Completer<Image>();
  decodeImageFromList(b, (i) => c.complete(i));
  return c.future;
}

Future<Level> ll(String k) async {
  var d = jsonDecode(await rb.loadString(k));
  return Level(it(d['m']), d['ms'], await li(d['i']), d['is'], v(dt(d['p'])),
      v(dt(d['d'])), it(d['c']), it(d['f']));
}

Future<Buttons> lb(String k, double r, double s, Rect b, Image i) async {
  var d = jsonDecode(await rb.loadString(k));
  return Buttons(
      r,
      (d['t'] as List)
          .map((t) => RSTransform.fromComponents(
                rotation: t[0],
                scale: s,
                anchorX: 0,
                anchorY: 0,
                translateX: t[1] * b.width + t[3] * s,
                translateY: t[2] * b.height + t[4] * s,
              ))
          .toList(),
      rt(d['ur']),
      rt(d['dr']),
      it(d['m']),
      (d['c'] as List).map((c) => Color(c)).toList(),
      (d['a'] as List)
          .map((a) => RRect.fromRectAndRadius(
                Rect.fromCircle(
                  center: Offset(a[0], a[1]) * s +
                      Offset(a[3] * b.width, a[4] * b.height),
                  radius: a[2] * s,
                ),
                Radius.circular(a[2] * s),
              ))
          .toList(),
      i);
}

List<Rect> rt(List l) =>
    l.map((r) => Rect.fromLTWH(r[0], r[1], r[2], r[3])).toList();

Vector2 v(v) => Vector2(v[0], v[1]);
