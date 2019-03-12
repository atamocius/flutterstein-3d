import 'dart:ui';
import 'package:vector_math/vector_math.dart';

class Level {
  // The map data
  final List<int> _map;
  // The atlas texture
  final Image atlas;
  // mapSize - The map's width and height (only square maps are supported)
  // atlasSize - The atlas' tile width and height (only square atlases are supported)
  final int mapSize, atlasSize;
  // Camera position
  final Vector2 pos, // Camera position
      dir; // Direction vector
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

  // Convert coordinates to map index (but Y is flipped)
  int get(num x, num y) =>
      _map[(mapSize - y.floor() - 1) * mapSize + x.floor()];
}
