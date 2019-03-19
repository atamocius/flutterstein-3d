import 'dart:ui';

typedef bool Pressed(int btn);

class Buttons {
  double _pixelRatio;
  List<RSTransform> _transforms;
  List<Rect> _upRects, _dnRects, _rects;
  List<int> _masks;
  List<Color> _colors;
  List<RRect> _areas;
  Image _atlas;
  Paint _paint;
  int _state;

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

  render(Canvas c) {
    c.drawAtlas(
      _atlas,
      _transforms,
      _rects,
      _colors,
      BlendMode.dstIn,
      null,
      _paint,
    );
  }

  bool pressed(int btn) => _state & _masks[btn] > 0;

  update(List<PointerData> p) {
    _state = 0;
    for (final d in p)
      if (d.change == PointerChange.up)
        _state = 0;
      else {
        for (int i = 0; i < _areas.length; i++)
          if (_areas[i].contains(
              Offset(d.physicalX / _pixelRatio, d.physicalY / _pixelRatio)))
            _state |= 1 << i;
      }

    for (int i = 0; i < _rects.length; i++)
      _rects[i] = _state & _masks[i] > 0 ? _dnRects[i] : _upRects[i];
  }
}
