import 'dart:ui';
import 'dart:math';
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';
import 'utils.dart';
import 'level.dart';

var texW = 32, texH = 32;

class Raycaster {
  Level _lvl;
  Size _screen;
  Vector2 pos;
  Vector2 dir;
  Vector2 plane;
  var _planeHalfW = 0.85;
  var _sideDist = Vector2.zero();
  var _deltaDist = Vector2.zero();
  var _rayDir = Vector2.zero();
  Image _atlas;
  int _atlasSize;
  Float32List _sliverTransforms;
  Float32List _sliverRects;
  Int32List _sliverColors;
  var _sliverPaint = Paint();
  var _stride = 4;
  Rect _bgRect;
  Paint _bgPaint;

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

  render(Canvas c) {
    for (int x = 0; x < _screen.width; x++) _raycast(x);

    c.drawRect(_bgRect, _bgPaint);

    c.drawRawAtlas(
      _atlas,
      _sliverTransforms,
      _sliverRects,
      _sliverColors,
      BlendMode.modulate,
      null,
      _sliverPaint,
    );
  }

  _raycast(int x) {
    var w = _screen.width, h = _screen.height;
    var cameraX = 2 * x / w - 1;

    _rayDir.setZero();
    _rayDir
      ..addScaled(plane, cameraX)
      ..add(dir);

    int mapX = pos.x.floor(), mapY = pos.y.floor();

    _deltaDist.x = invAbs(_rayDir.x);
    _deltaDist.y = invAbs(_rayDir.y);

    int stepX = 0, stepY = 0;

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

    int hit = 0, side;

    while (hit == 0) {
      if (_sideDist.x < _sideDist.y) {
        _sideDist.x += _deltaDist.x;
        mapX += stepX;
        side = 0;
      } else {
        _sideDist.y += _deltaDist.y;
        mapY += stepY;
        side = 1;
      }

      if (_lvl.get(mapX, mapY) > 0) hit = 1;
    }

    var dx = mapX - pos.x;
    var dy = mapY - pos.y;

    var perpWallDist = side == 0
        ? (dx + (1 - stepX) / 2) / _rayDir.x
        : (dy + (1 - stepY) / 2) / _rayDir.y;

    var lineHeight = h / perpWallDist;

    var wallX = side == 0
        ? pos.y + perpWallDist * _rayDir.y
        : pos.x + perpWallDist * _rayDir.x;
    wallX = frac(wallX);

    int texX = (wallX * texW).floor();
    if (side == 0 && _rayDir.x > 0) texX = texW - texX - 1;
    if (side == 1 && _rayDir.y < 0) texX = texW - texX - 1;

    var texNum = _lvl.get(mapX, mapY) - 1,
        oX = texNum % _atlasSize * texW / 1,
        oY = texNum ~/ _atlasSize * texH / 1;

    var i = x * _stride,
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

    var distSq = sq(dx) + sq(dy);
    var att = 1 - min(sq(distSq / 100), 1);
    _sliverColors[x] = greyscale(att, side == 1 ? 255 : 200);
  }
}
