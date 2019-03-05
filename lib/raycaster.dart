// https://www.youtube.com/watch?v=eOCQfxRQ2pY

// https://permadi.com/1996/05/ray-casting-tutorial-table-of-contents/
// https://github.com/permadi-com/ray-cast

// https://github.com/ssloy/tinyraycaster/wiki

// https://lodev.org/cgtutor/
// https://lodev.org/cgtutor/raycasting.html
// https://lodev.org/cgtutor/raycasting2.html
// https://lodev.org/cgtutor/raycasting3.html
// https://lodev.org/cgtutor/raycasting4.html

// https://github.com/mdn/canvas-raycaster

import 'dart:math';
import 'dart:ui';
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';

// Map size
const mapW = 24, mapH = 24;

// Texture size
const texW = 64, texH = 64;

// Convert coordinates to map index (but Y is flipped)
int toMapIndex(num x, num y) => (mapH - (y ~/ 1) - 1) * mapW + (x ~/ 1);

class Raycaster {
  // Screen size (aka projection plane)
  final Size _screen;

  // Camera position
  final Vector2 pos; // = Vector2(22, 12);

  // Direction vector
  final Vector2 dir; // = Vector2(-1, 0);

  // 2D raycaster version of camera plane
  Vector2 plane; // = Vector2(0, 0.66);

  final _planeHalfW = 0.85;

  // length of ray from current position to next x or y-side
  final _sideDist = Vector2.zero();

  // length of ray from one x or y-side to next x or y-side
  final _deltaDist = Vector2.zero();

  final _rayDir = Vector2.zero();

  final Image _atlas;
  final int _atlasSize;

  // Draw buffers
  Float32List _sliverTransforms;
  Float32List _sliverRects;
  Int32List _sliverColors;
  final _sliverPaint = Paint();
  final _stride = 4;

  Raycaster(this._screen, this.pos, this.dir, this._atlas, this._atlasSize) {
    plane = Vector2(dir.y, -dir.x)
      ..normalize()
      ..scale(_planeHalfW);

    _sliverTransforms = Float32List(_screen.width ~/ 1 * 4);
    _sliverRects = Float32List(_screen.width ~/ 1 * 4);
    _sliverColors = Int32List(_screen.width ~/ 1);
  }

  void render(Canvas canvas, List<int> map) {
    for (int x = 0; x < _screen.width; x++) {
      _raycast(map, x, _screen.width, _screen.height);
    }

    canvas.drawRawAtlas(
      _atlas,
      _sliverTransforms,
      _sliverRects,
      _sliverColors,
      BlendMode.modulate,
      null,
      _sliverPaint,
    );
  }

  void _raycast(List<int> map, int x, double w, double h) {
    // calculate ray position and direction
    final cameraX = 2 * x / w - 1; // x-coordinate in camera space

    // dir + plane * cameraX;
    _rayDir.setZero();
    _rayDir
      ..addScaled(plane, cameraX)
      ..add(dir);

    // which box of the map we're in
    int mapX = pos.x.floor(), mapY = pos.y.floor();

    // length of ray from one x or y-side to next x or y-side
    _deltaDist.x = (1 / _rayDir.x).abs();
    _deltaDist.y = (1 / _rayDir.y).abs();

    // what direction to step in x or y-direction (either +1 or -1)
    int stepX = 0, stepY = 0;

    // calculate step and initial sideDist
    if (_rayDir.x < 0) {
      stepX = -1;
      _sideDist.x = (pos.x - mapX) * _deltaDist.x;
    } else {
      stepX = 1;
      _sideDist.x = (mapX + 1.0 - pos.x) * _deltaDist.x;
    }
    if (_rayDir.y < 0) {
      stepY = -1;
      _sideDist.y = (pos.y - mapY) * _deltaDist.y;
    } else {
      stepY = 1;
      _sideDist.y = (mapY + 1.0 - pos.y) * _deltaDist.y;
    }

    int hit = 0; // was there a wall hit?
    int side; // was a NS or a EW wall hit?

    // perform DDA
    while (hit == 0) {
      // jump to next map square, OR in x-direction, OR in y-direction
      if (_sideDist.x < _sideDist.y) {
        _sideDist.x += _deltaDist.x;
        mapX += stepX;
        side = 0;
      } else {
        _sideDist.y += _deltaDist.y;
        mapY += stepY;
        side = 1;
      }

      // Check if ray has hit a wall
      if (map[toMapIndex(mapX, mapY)] > 0) hit = 1;
    }

    // Calculate distance projected on camera direction (Euclidean distance will give fisheye effect!)
    double perpWallDist;
    if (side == 0)
      perpWallDist = (mapX - pos.x + (1 - stepX) / 2) / _rayDir.x;
    else
      perpWallDist = (mapY - pos.y + (1 - stepY) / 2) / _rayDir.y;

    // Calculate height of line to draw on screen
    final lineHeight = h / perpWallDist;

    // Calculate value of wallX (where exactly the wall was hit)
    double wallX;
    if (side == 0)
      wallX = pos.y + perpWallDist * _rayDir.y;
    else
      wallX = pos.x + perpWallDist * _rayDir.x;
    wallX -= wallX.floor();

    // x coordinate on the texture
    int texX = (wallX * texW).floor();
    if (side == 0 && _rayDir.x > 0) texX = texW - texX - 1;
    if (side == 1 && _rayDir.y < 0) texX = texW - texX - 1;

    // texturing calculations
    // 1 subtracted from it so that texture 0 can be used!
    int texNum = map[toMapIndex(mapX, mapY)] - 1;
    int texOffX = texNum % _atlasSize * texW;
    int texOffY = texNum ~/ _atlasSize * texW;

    final scale = lineHeight / texH;
    final i = x * _stride;
    _sliverTransforms
      ..[i + 0] = scale
      ..[i + 1] = 0
      ..[i + 2] = x / 1
      ..[i + 3] = -lineHeight / 2 + h / 2;
    _sliverRects
      ..[i + 0] = texOffX / 1 + texX
      ..[i + 1] = texOffY / 1
      ..[i + 2] = texOffX / 1 + texX + 1 / scale
      ..[i + 3] = texOffY / 1 + texH;
    _sliverColors[x] = side == 1 ? 0xffffffff : 0xffc8c8c8;
  }
}
