import 'dart:ui';
import 'dart:math';
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';
import 'utils.dart';
import 'level.dart';

var tW = 32, tH = 32;

class Raycaster {
  Level _l;
  Size _s;
  Vector2 p;
  Vector2 d;
  Vector2 pn;
  var _pnhw = 0.85;
  var _sd = Vector2.zero();
  var _dd = Vector2.zero();
  var _rd = Vector2.zero();
  Image _i;
  int _is;
  Float32List _st;
  Float32List _sr;
  Int32List _sc;
  var _sp = Paint();
  var _se = 4;
  Rect _br;
  Paint _bp;

  Raycaster(this._s, this._l)
      : p = _l.p.clone(),
        d = _l.d.clone(),
        _i = _l.i,
        _is = _l.ats,
        _br = Rect.fromLTRB(0, -20, _s.width, _s.height + 20),
        _bp = Paint()
          ..shader = Gradient.linear(
            Offset.zero,
            Offset(0, _s.height),
            [
              _l.c[0],
              _l.c[1],
              0xff000000,
              0xff000000,
              _l.f[1],
              _l.f[0],
            ].map((c) => Color(c)).toList(),
            [0, 0.35, 0.45, 0.55, 0.65, 1],
          ) {
    pn = Vector2(d.y, -d.x)
      ..normalize()
      ..scale(_pnhw);

    var w = _s.width ~/ 1, s = _se;
    _st = Float32List(w * s);
    _sr = Float32List(w * s);
    _sc = Int32List(w);
  }

  render(Canvas c) {
    for (int x = 0; x < _s.width; x++) _raycast(x);
    c.drawRect(_br, _bp);
    c.drawRawAtlas(_i, _st, _sr, _sc, BlendMode.modulate, null, _sp);
  }

  _raycast(int x) {
    var w = _s.width, h = _s.height;
    var cX = 2 * x / w - 1;

    _rd.setZero();
    _rd
      ..addScaled(pn, cX)
      ..add(d);

    int mX = p.x.floor(), mY = p.y.floor();

    _dd.x = invAbs(_rd.x);
    _dd.y = invAbs(_rd.y);

    int sX = 0, sY = 0;

    if (_rd.x < 0) {
      sX = -1;
      _sd.x = (p.x - mX) * _dd.x;
    } else {
      sX = 1;
      _sd.x = (mX + 1.0 - p.x) * _dd.x;
    }
    if (_rd.y < 0) {
      sY = -1;
      _sd.y = (p.y - mY) * _dd.y;
    } else {
      sY = 1;
      _sd.y = (mY + 1.0 - p.y) * _dd.y;
    }

    int ht = 0, sd;

    while (ht == 0) {
      if (_sd.x < _sd.y) {
        _sd.x += _dd.x;
        mX += sX;
        sd = 0;
      } else {
        _sd.y += _dd.y;
        mY += sY;
        sd = 1;
      }

      if (_l.get(mX, mY) > 0) ht = 1;
    }

    var dx = mX - p.x, dy = mY - p.y;

    var pwd =
        sd == 0 ? (dx + (1 - sX) / 2) / _rd.x : (dy + (1 - sY) / 2) / _rd.y;

    var lh = h / pwd;

    var wX = sd == 0 ? p.y + pwd * _rd.y : p.x + pwd * _rd.x;
    wX = frac(wX);

    int tX = (wX * tW).floor();
    if (sd == 0 && _rd.x > 0) tX = tW - tX - 1;
    if (sd == 1 && _rd.y < 0) tX = tW - tX - 1;

    var tn = _l.get(mX, mY) - 1,
        oX = tn % _is * tW / 1,
        oY = tn ~/ _is * tH / 1;

    var i = x * _se, sc = lh / tH, ds = -lh / 2 + h / 2;

    _st
      ..[i + 0] = sc
      ..[i + 1] = 0
      ..[i + 2] = x / 1
      ..[i + 3] = ds;
    _sr
      ..[i + 0] = oX + tX
      ..[i + 1] = oY
      ..[i + 2] = oX + tX + 1 / sc
      ..[i + 3] = oY + tH;

    var distSq = sq(dx) + sq(dy);
    var att = 1 - min(sq(distSq / 100), 1);
    _sc[x] = gs(att, sd == 1 ? 255 : 200);
  }
}
