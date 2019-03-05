import 'dart:math';
import 'dart:ui';
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';
import 'raycaster.dart';
import 'level.dart';

typedef bool Pressed(int btn);

class Game {
  final Raycaster _raycaster;

  final Level _level;

  final _rotMat = Matrix2.identity();
  final _moveVec = Vector2.zero();

  final _moveSpeed = 3.0;
  final _rotSpeed = 2.0;

  final _wallPadding = 0.2;

  Game(Size screen, this._level)
      : _raycaster = Raycaster(
          screen,
          _level.pos.clone(),
          _level.dir.clone(),
          _level.atlas,
          _level.atlasSize,
        );

  void update(double t, Pressed btn) {
    var forward = btn(0),
        backward = btn(2),
        strafeLeft = btn(1),
        strafeRight = btn(3),
        rotLeft = btn(4),
        rotRight = btn(5),
        action = btn(6);

    var move = _moveSpeed * t;
    var rot = _rotSpeed * t;

    var dir = _raycaster.dir;
    var pos = _raycaster.pos;
    var plane = _raycaster.plane;

    if (forward || backward) {
      _moveVec.x = dir.x * move * (forward ? 1 : -1);
      _moveVec.y = dir.y * move * (forward ? 1 : -1);
      _translate(_level.map, pos);
      // print(pos);
    }

    if (strafeLeft || strafeRight) {
      _moveVec.x = dir.y * move * (strafeLeft ? 1 : -1);
      _moveVec.y = -dir.x * move * (strafeLeft ? 1 : -1);
      _translate(_level.map, pos);
      // print(pos);
    }

    if (rotLeft || rotRight) {
      _rotMat.setRotation(rot * (rotLeft ? 1 : -1));
      _rotMat.transform(dir);
      _rotMat.transform(plane);
    }
  }

  void render(Canvas canvas) {
    canvas.save();
    _raycaster.render(canvas, _level.map);
    canvas.restore();
  }

  void _translate(List<int> map, Vector2 p) {
    if (map[toMapIndex(p.x + _moveVec.x, p.y)] == 0) p.x += _moveVec.x;
    if (map[toMapIndex(p.x, p.y + _moveVec.y)] == 0) p.y += _moveVec.y;

    var posFracX = p.x - p.x.floor();
    var posFracY = p.y - p.y.floor();

    // Add some padding between the camera and the walls
    if (_moveVec.x < 0) {
      // Moving left
      if (map[toMapIndex(p.x - 1, p.y)] > 0 && posFracX < _wallPadding)
        p.x += _wallPadding - posFracX;
    } else {
      // Moving right
      if (map[toMapIndex(p.x + 1, p.y)] > 0 && posFracX > 1 - _wallPadding)
        p.x -= posFracX - (1 - _wallPadding);
    }
    if (_moveVec.y < 0) {
      // Moving down
      if (map[toMapIndex(p.x, p.y - 1)] > 0 && posFracY < _wallPadding)
        p.y += _wallPadding - posFracY;
    } else {
      // Moving up
      if (map[toMapIndex(p.x, p.y + 1)] > 0 && posFracY > 1 - _wallPadding)
        p.y -= posFracY - (1 - _wallPadding);
    }
  }
}
