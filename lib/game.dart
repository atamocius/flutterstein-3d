import 'dart:math';
import 'dart:ui';
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';
import 'raycaster.dart';

typedef bool Pressed(int btn);

final worldMap = [
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, //
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, //
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, //
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, //
  1, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 0, 0, 0, 0, 3, 0, 3, 0, 3, 0, 0, 0, 1, //
  1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, //
  1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, 1, //
  1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, //
  1, 0, 0, 0, 0, 0, 2, 2, 0, 2, 2, 0, 0, 0, 0, 3, 0, 3, 0, 3, 0, 0, 0, 1, //
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, //
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, //
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, //
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, //
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, //
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, //
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, //
  1, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, //
  1, 4, 0, 4, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, //
  1, 4, 0, 0, 0, 0, 5, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, //
  1, 4, 0, 4, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, //
  1, 4, 0, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, //
  1, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, //
  1, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, //
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 //
];

class Game {
  // TODO: Inject raycaster instance
  final _raycaster = Raycaster(
    Vector2(640, 360),
    Vector2(22, 12),
    Vector2(-1, 0),
  );
  final _rotMat = Matrix2.identity();
  final _moveVec = Vector2.zero();

  final _moveSpeed = 5.0;
  final _rotSpeed = 2.0;

  // TODO: Pass level data instead of just the map array
  //       - Level data should also include textures
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
      _translate(worldMap, pos);
    }

    if (strafeLeft || strafeRight) {
      _moveVec.x = dir.y * move * (strafeLeft ? 1 : -1);
      _moveVec.y = -dir.x * move * (strafeLeft ? 1 : -1);
      _translate(worldMap, pos);
    }

    if (rotLeft || rotRight) {
      _rotMat.setRotation(rot * (rotLeft ? 1 : -1));
      _rotMat.transform(dir);
      _rotMat.transform(plane);
    }
  }

  void render(Canvas canvas) {
    canvas.save();
    _raycaster.render(canvas, worldMap);
    canvas.restore();
  }

  void _translate(List<int> map, Vector2 p) {
    if (map[toMapIndex(p.x + _moveVec.x, p.y)] == 0) p.x += _moveVec.x;
    if (map[toMapIndex(p.x, p.y + _moveVec.y)] == 0) p.y += _moveVec.y;
  }
}
