import 'dart:ui';
import 'dart:math';
import 'package:vector_math/vector_math.dart';
import 'utils.dart';
import 'raycaster.dart';
import 'level.dart';
import 'buttons.dart';

class Game {
  Raycaster _r;
  Level _l;
  var _rm = Matrix2.identity(),
      _mv = Vector2.zero(),
      _s = 3.0,
      _rs = 1.7,
      _w = 0.2;

  double _bt = 0.0;
  double _bf = 10;
  double _ba = 2;

  Game(Size s, this._l) : _r = Raycaster(s, _l);

  update(double t, P b) {
    var fw = b(0), bw = b(2), sL = b(1), sR = b(3), rL = b(4), rR = b(5);

    var m = _s * t, r = _rs * t, d = _r.d, p = _r.p, pn = _r.pn;

    if (fw || bw) {
      _mv.x = d.x * m * (fw ? 1 : -1);
      _mv.y = d.y * m * (fw ? 1 : -1);
    }

    if (sL || sR) {
      _mv.x = d.y * m * (sL ? 1 : -1);
      _mv.y = -d.x * m * (sL ? 1 : -1);
    }

    if (fw || bw || sL || sR) {
      _bt += t * _bf;
      _translate(_l, p, _mv, _w);
    }

    if (rL || rR) {
      _rm.setRotation(r * (rL ? 1 : -1));
      _rm.transform(d);
      _rm.transform(pn);
    }
  }

  render(Canvas c) {
    c.save();
    c.translate(0, sin((pi / 2) * _bt) * _ba);
    _r.render(c);
    c.restore();
  }

  _translate(Level l, Vector2 p, Vector2 d, double w) {
    if (l.get(p.x + d.x, p.y) == 0) p.x += d.x;
    if (l.get(p.x, p.y + d.y) == 0) p.y += d.y;

    var fX = fr(p.x);
    var fY = fr(p.y);

    if (d.x < 0) {
      if (l.get(p.x - 1, p.y) > 0 && fX < w) p.x += w - fX;
    } else {
      if (l.get(p.x + 1, p.y) > 0 && fX > 1 - w) p.x -= fX - (1 - w);
    }
    if (d.y < 0) {
      if (l.get(p.x, p.y - 1) > 0 && fY < w) p.y += w - fY;
    } else {
      if (l.get(p.x, p.y + 1) > 0 && fY > 1 - w) p.y -= fY - (1 - w);
    }
  }
}
