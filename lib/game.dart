import 'dart:ui';
import 'dart:math';
import 'package:vector_math/vector_math.dart';
import 'utils.dart';
import 'raycaster.dart';
import 'level.dart';
import 'buttons.dart';

class Game {
  final Raycaster _rc;
  final Level _lvl;
  final _rotMat = Matrix2.identity(),
      _moveVec = Vector2.zero(),
      _moveSpeed = 3.0,
      _rotSpeed = 1.7,
      _wallPadding = 0.2;

  double _bobTime = 0.0;
  double _bobFreq = 10; // Frequency
  double _bobAmp = 2; // Amplitude

  Game(Size screen, this._lvl) : _rc = Raycaster(screen, _lvl);

  void update(double t, Pressed btn) {
    var fwd = btn(0),
        bwd = btn(2),
        stfL = btn(1),
        stfR = btn(3),
        rotL = btn(4),
        rotR = btn(5);

    var move = _moveSpeed * t,
        rot = _rotSpeed * t,
        dir = _rc.dir,
        pos = _rc.pos,
        plane = _rc.plane;

    if (fwd || bwd) {
      _moveVec.x = dir.x * move * (fwd ? 1 : -1);
      _moveVec.y = dir.y * move * (fwd ? 1 : -1);
    }

    if (stfL || stfR) {
      _moveVec.x = dir.y * move * (stfL ? 1 : -1);
      _moveVec.y = -dir.x * move * (stfL ? 1 : -1);
    }

    if (fwd || bwd || stfL || stfR) {
      _bobTime += t * _bobFreq;
      // if (_bob <= -1 || _bob >= 1) _bobFreq *= -1;
      _translate(_lvl, pos, _moveVec, _wallPadding);
    }

    if (rotL || rotR) {
      _rotMat.setRotation(rot * (rotL ? 1 : -1));
      _rotMat.transform(dir);
      _rotMat.transform(plane);
    }
  }

  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(0, sin((pi / 2) * _bobTime) * _bobAmp);
    _rc.render(canvas);
    canvas.restore();
  }

  void _translate(Level l, Vector2 p, Vector2 d, double w) {
    // Forecast if pos will hit a wall and then translate if it doesn't
    // aka Collision detection
    if (l.get(p.x + d.x, p.y) == 0) p.x += d.x;
    if (l.get(p.x, p.y + d.y) == 0) p.y += d.y;

    // Get the fractional part of the position coordinates
    final fX = frac(p.x);
    final fY = frac(p.y);

    // Add some padding between the camera and the walls
    if (d.x < 0) {
      // Moving left
      if (l.get(p.x - 1, p.y) > 0 && fX < w) p.x += w - fX;
    } else {
      // Moving right
      if (l.get(p.x + 1, p.y) > 0 && fX > 1 - w) p.x -= fX - (1 - w);
    }
    if (d.y < 0) {
      // Moving down
      if (l.get(p.x, p.y - 1) > 0 && fY < w) p.y += w - fY;
    } else {
      // Moving up
      if (l.get(p.x, p.y + 1) > 0 && fY > 1 - w) p.y -= fY - (1 - w);
    }
  }
}
