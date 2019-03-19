import 'dart:ui';
import 'package:vector_math/vector_math.dart';

class Level {
  final List<int> _map;
  final Image atlas;
  final int mapSize, atlasSize;
  final Vector2 pos, dir;
  final List<int> ceil, floor;

  Level(
    this._map,
    this.mapSize,
    this.atlas,
    this.atlasSize,
    this.pos,
    this.dir,
    this.ceil,
    this.floor,
  );

  int get(num x, num y) =>
      _map[(mapSize - y.floor() - 1) * mapSize + x.floor()];
}
