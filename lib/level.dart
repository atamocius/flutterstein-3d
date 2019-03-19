import 'dart:ui';
import 'package:vector_math/vector_math.dart';

class Level {
  List<int> _m;
  Image i;
  int ms, ats;
  Vector2 p, d;
  List<int> c, f;

  Level(this._m, this.ms, this.i, this.ats, this.p, this.d, this.c, this.f);

  int get(num x, num y) => _m[(ms - y.floor() - 1) * ms + x.floor()];
}
