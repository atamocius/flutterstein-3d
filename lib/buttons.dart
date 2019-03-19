import 'dart:ui';

typedef bool P(int btn);

class Buttons {
  double _pr;
  List<RSTransform> _t;
  List<Rect> _ur, _dr, _r;
  List<int> _m;
  List<Color> _c;
  List<RRect> _a;
  Image _i;
  Paint _p;
  int _s;

  Buttons(
      this._pr, this._t, this._ur, this._dr, this._m, this._c, this._a, this._i)
      : _s = 0,
        _r = List<Rect>.from(_ur),
        _p = Paint();

  render(Canvas c) {
    c.drawAtlas(_i, _t, _r, _c, BlendMode.dstIn, null, _p);
  }

  bool pressed(int b) => _s & _m[b] > 0;

  update(List<PointerData> p) {
    _s = 0;
    for (final d in p)
      if (d.change == PointerChange.up)
        _s = 0;
      else {
        for (int i = 0; i < _a.length; i++)
          if (_a[i].contains(Offset(d.physicalX / _pr, d.physicalY / _pr)))
            _s |= 1 << i;
      }

    for (int i = 0; i < _r.length; i++)
      _r[i] = _s & _m[i] > 0 ? _dr[i] : _ur[i];
  }
}
