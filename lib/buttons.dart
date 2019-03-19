import 'dart:ui';

typedef bool P(int btn);

class Buttons {
  double r;
  List<RSTransform> t;
  List<Rect> u, d, e;
  List<int> m;
  List<Color> o;
  List<RRect> a;
  Image i;
  Paint p;
  int s;

  Buttons(this.r, this.t, this.u, this.d, this.m, this.o, this.a, this.i)
      : s = 0,
        e = List<Rect>.from(u),
        p = Paint();

  rd(Canvas c) {
    c.drawAtlas(i, t, e, o, BlendMode.dstIn, null, p);
  }

  bool b(int b) => s & m[b] > 0;

  ud(List<PointerData> p) {
    s = 0;
    for (final d in p)
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
