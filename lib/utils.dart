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

int greyscale(num s, [int b = 255]) =>
    // (((255 & 0xff) << 24) |
    (0xff000000 |
        (((b * s).floor() & 0xff) << 16) |
        (((b * s).floor() & 0xff) << 8) |
        (((b * s).floor() & 0xff) << 0)) &
    0xFFFFFFFF;

void combSort(List<int> order, List<double> dist, int amount) {
  var gap = amount;
  var swapped = false;

  while (gap > 1 || swapped) {
    //shrink factor 1.3
    gap = (gap * 10) ~/ 13;
    if (gap == 9 || gap == 10) gap = 11;
    if (gap < 1) gap = 1;
    swapped = false;

    for (int i = 0; i < amount - gap; i++) {
      int j = i + gap;
      if (dist[i] < dist[j]) {
        num tmp = dist[i];
        dist[i] = dist[j];
        dist[j] = tmp;

        tmp = order[i];
        order[i] = order[j];
        order[j] = tmp;

        swapped = true;
      }
    }
  }
}

Future<Image> loadImage(String key) async {
  final data = await rootBundle.load(key);
  final buffer = Uint8List.view(data.buffer);
  final c = Completer<Image>();
  decodeImageFromList(buffer, (img) => c.complete(img));
  return c.future;
}

Future<Level> loadLevel(String key) async {
  final d = jsonDecode(await rootBundle.loadString(key));
  return Level(
    d['map'].cast<int>(),
    d['mapSize'],
    await loadImage(d['atlas']),
    d['atlasSize'],
    // origin the bottom-left of the map array
    _loadVec(d['pos'].cast<double>()),
    _loadVec(d['dir'].cast<double>()),
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
    _loadRects(d['upRects']),
    _loadRects(d['dnRects']),
    d['masks'].cast<int>(),
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

List<Rect> _loadRects(List rects) =>
    rects.map((r) => Rect.fromLTWH(r[0], r[1], r[2], r[3])).toList();

Vector2 _loadVec(v) => Vector2(v[0], v[1]);
