import 'dart:ui';

class Buttons {
  final int count;
  final double _pixelRatio;
  final List<RSTransform> transforms;
  final List<Rect> _upRects;
  final List<Rect> _dnRects;
  final List<int> masks;
  final List<Color> colors;
  final List<RRect> areas;
  final Image atlas;

  int state;

  Buttons(
    this.count,
    this._pixelRatio,
    this.transforms,
    this._upRects,
    this._dnRects,
    this.masks,
    this.colors,
    this.areas,
    this.atlas,
  ) : state = 0;

  updateRects(List<Rect> rects) {
    for (int i = 0; i < rects.length; i++) {
      rects[i] = state & masks[i] > 0 ? _dnRects[i] : _upRects[i];
    }
  }

  int updateState(List<PointerData> data) {
    state = 0;
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
              Offset(d.physicalX / _pixelRatio, d.physicalY / _pixelRatio))) {
            state |= 1 << i;
          }
        }
      }
    }
    return state;
  }
}
