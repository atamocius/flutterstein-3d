import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'buttons.dart';

Future<Image> loadImage(String key) async {
  final data = await rootBundle.load(key);
  final buffer = Uint8List.view(data.buffer);
  final c = Completer<Image>();
  decodeImageFromList(buffer, (img) => c.complete(img));
  return c.future;
}

Future<Buttons> loadButtons(
  String key,
  double pixelRatio,
  double scale,
  Rect bounds,
  Image atlas,
) async {
  final data = jsonDecode(await rootBundle.loadString(key));
  final d = data['buttons'];
  final m = d['masks'].cast<int>();
  return Buttons(
    m.length,
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
    m,
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
