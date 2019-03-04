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

typedef bool Pressed(int btn);

final moveSpeed = 5.0;
final rotSpeed = 2.0;

// final mapSize = Vector2(24, 24);
final mapWidth = 24, mapHeight = 24;
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

// Convert coorddinates to map index (but Y is flipped)
int toIndex(int x, int y) => (mapHeight - y - 1) * mapWidth + x;

// Screen size (aka projection plane)
final screen = Vector2(640, 360);

// Player attributes
final pos = Vector2(22, 12);

// Direction vector
final dir = Vector2(-1, 0);

// 2D raycaster version of camera plane
final plane = Vector2(0, 0.66);

// length of ray from current position to next x or y-side
final sideDist = Vector2.zero();

// length of ray from one x or y-side to next x or y-side
final deltaDist = Vector2.zero();

final rayDir = Vector2.zero();

// w = screen width, h = screen height
void raycast(Canvas canvas, int x, double w, double h) {
  // calculate ray position and direction
  final cameraX = 2 * x / w - 1; // x-coordinate in camera space

  // dir + plane * cameraX;
  rayDir.setZero();
  rayDir
    ..addScaled(plane, cameraX)
    ..add(dir);

  // which box of the map we're in
  int mapX = pos.x.floor(), mapY = pos.y.floor();

  // length of ray from one x or y-side to next x or y-side
  deltaDist.x = (1 / rayDir.x).abs();
  deltaDist.y = (1 / rayDir.y).abs();

  // what direction to step in x or y-direction (either +1 or -1)
  int stepX = 0, stepY = 0;

  // calculate step and initial sideDist
  if (rayDir.x < 0) {
    stepX = -1;
    sideDist.x = (pos.x - mapX) * deltaDist.x;
  } else {
    stepX = 1;
    sideDist.x = (mapX + 1.0 - pos.x) * deltaDist.x;
  }
  if (rayDir.y < 0) {
    stepY = -1;
    sideDist.y = (pos.y - mapY) * deltaDist.y;
  } else {
    stepY = 1;
    sideDist.y = (mapY + 1.0 - pos.y) * deltaDist.y;
  }

  int hit = 0; // was there a wall hit?
  int side; // was a NS or a EW wall hit?

  // perform DDA
  while (hit == 0) {
    // jump to next map square, OR in x-direction, OR in y-direction
    if (sideDist.x < sideDist.y) {
      sideDist.x += deltaDist.x;
      mapX += stepX;
      side = 0;
    } else {
      sideDist.y += deltaDist.y;
      mapY += stepY;
      side = 1;
    }

    // Check if ray has hit a wall
    if (worldMap[toIndex(mapX, mapY)] > 0) hit = 1;
  }

  // Calculate distance projected on camera direction (Euclidean distance will give fisheye effect!)
  double perpWallDist;
  if (side == 0)
    perpWallDist = (mapX - pos.x + (1 - stepX) / 2) / rayDir.x;
  else
    perpWallDist = (mapY - pos.y + (1 - stepY) / 2) / rayDir.y;

  // Calculate height of line to draw on screen
  final lineHeight = h / perpWallDist;

  // Calculate lowest and highest pixel to fill in current stripe
  var drawStart = -lineHeight / 2 + h / 2;
  if (drawStart < 0) drawStart = 0;
  var drawEnd = lineHeight / 2 + h / 2;
  if (drawEnd >= h) drawEnd = h - 1;

  // choose wall color
  Color color;
  switch (worldMap[toIndex(mapX, mapY)]) {
    case 1:
      color = Color(side == 0 ? 0xffff0000 : 0xff7f0000);
      break; //red
    case 2:
      color = Color(side == 0 ? 0xff00ff00 : 0xff007f00);
      break; //green
    case 3:
      color = Color(side == 0 ? 0xff0000ff : 0xff00007f);
      break; //blue
    case 4:
      color = Color(side == 0 ? 0xffffffff : 0xff7f7f7f);
      break; //white
    default:
      color = Color(side == 0 ? 0xffffff00 : 0xff7f7f00);
      break; //yellow
  }

  // draw the pixels of the stripe as a vertical line
  verLine(canvas, x / 1, drawStart, drawEnd, color);
}

void verLine(
  Canvas canvas,
  double x,
  double start,
  double end,
  Color color,
) {
  canvas.drawLine(
    Offset(x, start),
    Offset(x, end),
    Paint()
      ..color = color
      ..strokeWidth = 1,
  );
}

class Game {
  // Button:
  // 0 : up
  // 1 : right
  // 2 : down
  // 3 : left
  // 4 : red
  // 5 : blue
  // 6 : green

  final _rotMat = Matrix2.identity();
  final _moveDir = Vector2.zero();
  var _move = 0.0;
  var _rot = 0.0;

  void _translate(List<int> map, Vector2 p) {
    if (map[toIndex((p.x + _moveDir.x) ~/ 1, p.y ~/ 1)] == 0) p.x += _moveDir.x;
    if (map[toIndex(p.x ~/ 1, (p.y + _moveDir.y) ~/ 1)] == 0) p.y += _moveDir.y;
  }

  void update(double t, Pressed pressed) {
    // for (int i = 0; i < 7; i++) {
    //   if (pressed(i)) {
    //     print(i);
    //   }
    // }
    _move = moveSpeed * t;
    _rot = rotSpeed * t;
    _moveDir.setZero();

    var forward = pressed(0),
        backward = pressed(2),
        strafeLeft = pressed(1),
        strafeRight = pressed(3),
        rotLeft = pressed(4),
        rotRight = pressed(5);

    if (forward || backward) {
      _moveDir.x += dir.x * _move * (forward ? 1 : -1);
      _moveDir.y += dir.y * _move * (forward ? 1 : -1);
      _translate(worldMap, pos);
    }

    if (strafeLeft || strafeRight) {
      _moveDir.x += dir.y * _move * (strafeLeft ? 1 : -1);
      _moveDir.y += -dir.x * _move * (strafeLeft ? 1 : -1);
      _translate(worldMap, pos);
    }

    if (rotLeft || rotRight) {
      _rotMat.setRotation(_rot * (rotLeft ? 1 : -1));
      _rotMat.transform(dir);
      _rotMat.transform(plane);
    }
  }

  void render(double t, Canvas canvas) {
    canvas.save();
    for (int x = 0; x < screen.x; x++) {
      raycast(canvas, x, screen.x, screen.y);
    }
    canvas.restore();
  }
}
