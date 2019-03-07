import 'dart:ui';
import 'package:vector_math/vector_math.dart';

class Level {
  // The map data
  final List<int> _map;
  // The atlas texture
  final Image atlas;
  final int
      mapSize, // The map's width and height (only square maps are supported)
      atlasSize; // The atlas' tile width and height (only square atlases are supported)
  // Camera position
  final Vector2 pos, // Camera position
      dir; // Direction vector

  Level(
    this._map,
    this.mapSize,
    this.atlas,
    this.atlasSize,
    this.pos,
    this.dir,
  );

  // Convert coordinates to map index (but Y is flipped)
  int get(num x, num y) => _map[(mapSize - (y ~/ 1) - 1) * mapSize + (x ~/ 1)];
}