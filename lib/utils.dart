import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart';

Future<Image> loadImage(String key) async {
  final data = await rootBundle.load(key);
  final buffer = Uint8List.view(data.buffer);
  final c = Completer<Image>();
  decodeImageFromList(buffer, (img) => c.complete(img));
  return c.future;
}

Future<List> loadData(String key, double scale, Rect bounds) async {
  final data = jsonDecode(await rootBundle.loadString(key));
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

List<Rect> _loadRects(List rects) =>
    rects.map((r) => Rect.fromLTWH(r[0], r[1], r[2], r[3])).toList();

updateRects(int state, List<Rect> rects, upRects, dnRects, masks) {
  for (int i = 0; i < rects.length; i++) {
    rects[i] = state & masks[i] > 0 ? dnRects[i] : upRects[i];
  }
}

int handlePointers(List<PointerData> data, double pixelRatio, areas) {
  var state = 0;
  for (final d in data) {
    if (d.change == PointerChange.up) {
      // Throw away the previously set bits since we can't determine for which
      // button the "up" action is for (the player might have moved their finger
      // outside of the button or to a different button)
      state = 0;
    } else {
      // Update the button state
      for (int i = 0; i < areas.length; i++) {
        if (areas[i].contains(
            Offset(d.physicalX / pixelRatio, d.physicalY / pixelRatio))) {
          state |= 1 << i;
        }
      }
    }
  }
  return state;
}
