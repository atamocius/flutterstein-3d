import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math.dart';

var w = window, rb = rootBundle, vz = Vector2.zero(), c0 = 0xff000000;
typedef bool P(int btn);

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

Future<L> ll(String k) async {
  var d = jsonDecode(await rb.loadString(k));
  return L(it(d['m']), d['ms'], await li(d['i']), d['is'], v(dt(d['p'])),
      v(dt(d['d'])), it(d['c']), it(d['f']));
}

Future<B> lb(String k, double r, double s, Rect b, Image i) async {
  var d = jsonDecode(await rb.loadString(k));
  return B(
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

class L {
  Image i;
  int s, a;
  Vector2 p, d;
  List<int> m, c, f;

  L(this.m, this.s, this.i, this.a, this.p, this.d, this.c, this.f);

  int get(num x, num y) => m[(s - y.floor() - 1) * s + x.floor()];
}

class B {
  double r;
  List<RSTransform> t;
  List<Rect> u, d, e;
  List<int> m;
  List<Color> o;
  List<RRect> a;
  Image i;
  Paint p;
  int s;

  B(this.r, this.t, this.u, this.d, this.m, this.o, this.a, this.i)
      : s = 0,
        e = List<Rect>.from(u),
        p = Paint();

  rd(Canvas c) {
    c.drawAtlas(i, t, e, o, BlendMode.dstIn, null, p);
  }

  bool b(int b) => s & m[b] > 0;

  ud(List<PointerData> p) {
    s = 0;
    for (var d in p)
      if (d.change == PointerChange.up)
        s = 0;
      else {
        for (int i = 0; i < a.length; i++)
          if (a[i].contains(Offset(d.physicalX / r, d.physicalY / r)))
            s |= 1 << i;
      }

    for (int i = 0; i < e.length; i++) e[i] = s & m[i] > 0 ? d[i] : u[i];
  }
}

class R {
  L _l;
  Size _s;
  Vector2 p, d, pn;
  Image _i;
  int _is;
  Float32List _st, _sr;
  Int32List _sc;
  Rect _br;
  Paint _bp;
  var tW = 32,
      _hw = 0.85,
      _sd = vz.clone(),
      _dd = vz.clone(),
      _rd = vz.clone(),
      _sp = Paint(),
      _se = 4;

  R(this._s, this._l)
      : p = _l.p.clone(),
        d = _l.d.clone(),
        _i = _l.i,
        _is = _l.a,
        _br = Rect.fromLTRB(0, -20, _s.width, _s.height + 20),
        _bp = Paint()
          ..shader = Gradient.linear(
            Offset.zero,
            Offset(0, _s.height),
            [_l.c[0], _l.c[1], c0, c0, _l.f[1], _l.f[0]]
                .map((c) => Color(c))
                .toList(),
            [0, 0.35, 0.45, 0.55, 0.65, 1],
          ) {
    pn = Vector2(d.y, -d.x)
      ..normalize()
      ..scale(_hw);

    var w = _s.width ~/ 1, s = _se;
    _st = Float32List(w * s);
    _sr = Float32List(w * s);
    _sc = Int32List(w);
  }

  r(Canvas c) {
    for (int x = 0; x < _s.width; x++) _rc(x);
    c.drawRect(_br, _bp);
    c.drawRawAtlas(_i, _st, _sr, _sc, BlendMode.modulate, null, _sp);
  }

  _rc(int x) {
    var w = _s.width, h = _s.height, cX = 2 * x / w - 1;

    _rd
      ..setZero()
      ..addScaled(pn, cX)
      ..add(d);

    int mX = p.x.floor(), mY = p.y.floor(), sX = 0, sY = 0, ht = 0, sd;

    _dd.x = iA(_rd.x);
    _dd.y = iA(_rd.y);

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

    var dx = mX - p.x,
        dy = mY - p.y,
        pwd =
            sd == 0 ? (dx + (1 - sX) / 2) / _rd.x : (dy + (1 - sY) / 2) / _rd.y,
        lh = h / pwd,
        wX = sd == 0 ? p.y + pwd * _rd.y : p.x + pwd * _rd.x;
    wX = fr(wX);

    int tX = (wX * tW).floor();
    if (sd == 0 && _rd.x > 0) tX = tW - tX - 1;
    if (sd == 1 && _rd.y < 0) tX = tW - tX - 1;

    var tn = _l.get(mX, mY) - 1,
        oX = tn % _is * tW / 1,
        oY = tn ~/ _is * tW / 1,
        i = x * _se,
        sc = lh / tW,
        ds = -lh / 2 + h / 2;

    _st
      ..[i + 0] = sc
      ..[i + 1] = 0
      ..[i + 2] = x / 1
      ..[i + 3] = ds;
    _sr
      ..[i + 0] = oX + tX
      ..[i + 1] = oY
      ..[i + 2] = oX + tX + 1 / sc
      ..[i + 3] = oY + tW;

    var distSq = sq(dx) + sq(dy), att = 1 - min(sq(distSq / 100), 1);
    _sc[x] = gs(att, sd == 1 ? 255 : 200);
  }
}

class G {
  R _r;
  L _l;
  var _rm = Matrix2.identity(),
      _mv = Vector2.zero(),
      _s = 3.0,
      _rs = 1.7,
      _w = 0.2;

  double _bt = 0.0, _bf = 10, _ba = 2;

  G(Size s, this._l) : _r = R(s, _l);

  u(double t, P b) {
    var fw = b(0),
        bw = b(2),
        sL = b(1),
        sR = b(3),
        rL = b(4),
        rR = b(5),
        m = _s * t,
        r = _rs * t,
        d = _r.d,
        p = _r.p,
        pn = _r.pn;

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
      _tl(_l, p, _mv, _w);
    }

    if (rL || rR) {
      _rm
        ..setRotation(r * (rL ? 1 : -1))
        ..transform(d)
        ..transform(pn);
    }
  }

  r(Canvas c) {
    c
      ..save()
      ..translate(0, sin((pi / 2) * _bt) * _ba);
    _r.r(c);
    c.restore();
  }

  _tl(L l, Vector2 p, Vector2 d, double w) {
    if (l.get(p.x + d.x, p.y) == 0) p.x += d.x;
    if (l.get(p.x, p.y + d.y) == 0) p.y += d.y;

    var fX = fr(p.x), fY = fr(p.y);

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

main() async {
  await SystemChrome.setEnabledSystemUIOverlays([]);

  var vs = Size(640, 360),
      b = Offset.zero & vs,
      dt = Float64List(16),
      ba = await li('img/gui.png');

  Offset o;
  B bs;

  var hmc = () async {
    var sz = w.physicalSize, r = sz.shortestSide / vs.shortestSide;

    dt
      ..[0] = r
      ..[5] = r
      ..[10] = 1
      ..[15] = 1;

    o = (sz / r - vs as Offset) * 0.5;

    bs = await lb('data/buttons.json', r, 1 / r * w.devicePixelRatio,
        Offset.zero & sz / r, ba);
  };

  hmc();
  w.onMetricsChanged = hmc;

  var lvl = await ll('data/level.json'),
      g = G(vs, lvl),
      z = Duration.zero,
      pv = z;

  w.onBeginFrame = (n) {
    var r = PictureRecorder(),
        c = Canvas(r, b),
        d = pv == z ? z : n - pv,
        t = d.inMicroseconds / 1000000;
    pv = n;

    c
      ..save()
      ..translate(o.dx, o.dy)
      ..clipRect(b);
    g
      ..u(t, bs.b)
      ..r(c);
    c.restore();

    bs.rd(c);

    var p = r.endRecording(),
        br = SceneBuilder()
          ..pushTransform(dt)
          ..addPicture(Offset.zero, p)
          ..pop();

    w
      ..render(br.build())
      ..scheduleFrame();
  };

  w
    ..scheduleFrame()
    ..onPointerDataPacket = (p) => bs.ud(p.data);
}
