import 'dart:ui';
import 'package:vector_math/vector_math.dart';

class Level {
  final List<int> map;
  final Image atlas;
  final int atlasSize;
  // Camera position
  final Vector2 pos;
  // Direction vector
  final Vector2 dir;

  Level(this.map, this.atlas, this.atlasSize, this.pos, this.dir);
}
