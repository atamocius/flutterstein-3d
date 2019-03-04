import 'dart:ui';
import 'package:vector_math/vector_math.dart';

class Level {
  final List<int> map;
  final Image texAtlas;
  // Camera position
  final Vector2 pos;
  // Direction vector
  final Vector2 dir;

  Level(this.map, this.texAtlas, this.pos, this.dir);
}
