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

import 'dart:ui';
import 'dart:math';
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';
import 'utils.dart';
import 'level.dart';

// Texture size
const texW = 64, texH = 64;

class Raycaster {
  final Level _lvl;

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

  // Wall draw buffers
  Float32List _sliverTransforms;
  Float32List _sliverRects;
  Int32List _sliverColors;

  final _sliverPaint = Paint();
  final _stride = 4;

  final Rect _bgRect;
  final Paint _bgPaint;

  Raycaster(this._screen, this._lvl)
      : pos = _lvl.pos.clone(),
        dir = _lvl.dir.clone(),
        _atlas = _lvl.atlas,
        _atlasSize = _lvl.atlasSize,
        _bgRect = Rect.fromLTRB(0, -20, _screen.width, _screen.height + 20),
        _bgPaint = Paint()
          ..shader = Gradient.linear(
            Offset.zero,
            Offset(0, _screen.height),
            [
              _lvl.ceil[0],
              _lvl.ceil[1],
              0xff000000,
              0xff000000,
              _lvl.floor[1],
              _lvl.floor[0],
            ].map((c) => Color(c)).toList(),
            [0, 0.35, 0.45, 0.55, 0.65, 1],
          ) {
    plane = Vector2(dir.y, -dir.x)
      ..normalize()
      ..scale(_planeHalfW);

    final w = _screen.width ~/ 1, s = _stride;
    _sliverTransforms = Float32List(w * s);
    _sliverRects = Float32List(w * s);
    _sliverColors = Int32List(w);
  }

  void render(Canvas canvas) {
    for (int x = 0; x < _screen.width; x++) _raycast(x);

    canvas.drawRect(_bgRect, _bgPaint);

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

  void _raycast(int x) {
    final w = _screen.width, h = _screen.height;

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
    _deltaDist.x = invAbs(_rayDir.x);
    _deltaDist.y = invAbs(_rayDir.y);

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

    int hit = 0, // was there a wall hit?
        side; // was a NS or a EW wall hit?

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
      if (_lvl.get(mapX, mapY) > 0) hit = 1;
    }

    final dx = mapX - pos.x;
    final dy = mapY - pos.y;

    // Calculate distance projected on camera direction (Euclidean distance will give fisheye effect!)
    final perpWallDist = side == 0
        ? (dx + (1 - stepX) / 2) / _rayDir.x
        : (dy + (1 - stepY) / 2) / _rayDir.y;

    // Calculate height of line to draw on screen
    final lineHeight = h / perpWallDist;

    // Calculate value of wallX (where exactly the wall was hit)
    var wallX = side == 0
        ? pos.y + perpWallDist * _rayDir.y
        : pos.x + perpWallDist * _rayDir.x;
    wallX = frac(wallX);

    // x coordinate on the texture
    int texX = (wallX * texW).floor();
    if (side == 0 && _rayDir.x > 0) texX = texW - texX - 1;
    if (side == 1 && _rayDir.y < 0) texX = texW - texX - 1;

    // texturing calculations
    // 1 subtracted from it so that texture 0 can be used!
    final texNum = _lvl.get(mapX, mapY) - 1,
        // texture offset
        oX = texNum % _atlasSize * texW / 1,
        oY = texNum ~/ _atlasSize * texH / 1;

    final i = x * _stride,
        scale = lineHeight / texH,
        drawStart = -lineHeight / 2 + h / 2;

    _sliverTransforms
      ..[i + 0] = scale
      ..[i + 1] = 0
      ..[i + 2] = x / 1
      ..[i + 3] = drawStart;
    _sliverRects
      ..[i + 0] = oX + texX
      ..[i + 1] = oY
      ..[i + 2] = oX + texX + 1 / scale
      ..[i + 3] = oY + texH;

    final distSq = sq(dx) + sq(dy);
    final att = 1 - min(sq(distSq / 100), 1);
    _sliverColors[x] = greyscale(att, side == 1 ? 255 : 200);
  }
}
