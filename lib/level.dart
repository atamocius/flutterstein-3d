import 'dart:ui';
import 'package:vector_math/vector_math.dart';

class Level {
  Image i;
  int s, a;
  Vector2 p, d;
  List<int> m, c, f;

  Level(this.m, this.s, this.i, this.a, this.p, this.d, this.c, this.f);

  int get(num x, num y) => m[(s - y.floor() - 1) * s + x.floor()];
}
