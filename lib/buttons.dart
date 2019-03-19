import 'dart:ui';

typedef bool Pressed(int btn);

class Buttons {
  final double _pixelRatio;
  final List<RSTransform> _transforms;
  final List<Rect> _upRects, _dnRects, _rects;
  final List<int> _masks;
  final List<Color> _colors;
  final List<RRect> _areas;
  final Image _atlas;
  final Paint _paint;
  int _state;

  // final _debugPaint = Paint()
  //   ..color = Color(0xFFFFF1E8)
  //   ..style = PaintingStyle.stroke;

  Buttons(
    this._pixelRatio,
    this._transforms,
    this._upRects,
    this._dnRects,
    this._masks,
    this._colors,
    this._areas,
    this._atlas,
  )   : _state = 0,
        _rects = List<Rect>.from(_upRects),
        _paint = Paint();

  void render(Canvas canvas) {
    canvas.drawAtlas(
      _atlas,
      _transforms,
      _rects,
      _colors,
      BlendMode.dstIn,
      null,
      _paint,
    );

    // Draw button hit areas
    // for (int i = 0; i < _areas.length; i++) {
    //   canvas.drawRRect(_areas[i], _debugPaint);
    // }
  }

  bool pressed(int btn) => _state & _masks[btn] > 0;

  void update(List<PointerData> data) {
    _state = 0;
    for (final d in data)
      if (d.change == PointerChange.up)
        // Throw away the previously set bits since we can't determine for which
        // button the "up" action is for (the player might have moved their finger
        // outside of the button or to a different button)
        _state = 0;
      else {
        // Update the button state
        for (int i = 0; i < _areas.length; i++)
          if (_areas[i].contains(
              Offset(d.physicalX / _pixelRatio, d.physicalY / _pixelRatio)))
            _state |= 1 << i;
      }

    // Update rects
    for (int i = 0; i < _rects.length; i++)
      _rects[i] = _state & _masks[i] > 0 ? _dnRects[i] : _upRects[i];
  }
}
