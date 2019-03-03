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
final worldMap = Uint32List.fromList([
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
]);

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

// w = screen width, h = screen height
void raycast(Canvas canvas, int x, double w, double h) {
  // calculate ray position and direction
  final cameraX = 2 * x / w - 1; // x-coordinate in camera space
  final rayDir = dir + plane * cameraX;

  // which box of the map we're in
  int mapX = pos.x.floor(), mapY = pos.y.floor();

  // length of ray from one x or y-side to next x or y-side
  deltaDist.x = (1 / rayDir.x).abs();
  deltaDist.y = (1 / rayDir.y).abs();

  // what direction to step in x or y-direction (either +1 or -1)
  int stepX = 0, stepY = 0;

  int hit = 0; // was there a wall hit?

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
    if (worldMap[mapY * mapWidth + mapX] > 0) hit = 1;
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
  switch (worldMap[mapY * mapWidth + mapX]) {
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

  var _rot = Matrix2.identity();
  var _moveDir = Vector2.zero();

  void update(double t, Pressed pressed) {
    // for (int i = 0; i < 7; i++) {
    //   if (pressed(i)) {
    //     print(i);
    //   }
    // }
    final scaledMoveSpeed = moveSpeed * t;
    final scaledRotSpeed = rotSpeed * t;

    if (pressed(0)) {
      _moveDir.x = dir.x * scaledMoveSpeed;
      _moveDir.y = dir.y * scaledMoveSpeed;

      final a = (pos.y ~/ 1) * mapWidth + ((pos.x + _moveDir.x) ~/ 1);
      final b = ((pos.y + _moveDir.y) ~/ 1) * mapWidth + (pos.x ~/ 1);

      if (worldMap[a] == 0) pos.x += _moveDir.x;
      if (worldMap[b] == 0) pos.y += _moveDir.y;

      print(pos);
    } else if (pressed(2)) {
      _moveDir.x = dir.x * scaledMoveSpeed;
      _moveDir.y = dir.y * scaledMoveSpeed;

      final a = (pos.y ~/ 1) * mapWidth + ((pos.x - _moveDir.x) ~/ 1);
      final b = ((pos.y - _moveDir.y) ~/ 1) * mapWidth + (pos.x ~/ 1);

      if (worldMap[a] == 0) pos.x -= _moveDir.x;
      if (worldMap[b] == 0) pos.y -= _moveDir.y;

      print(pos);
    }

    if (pressed(1)) {
      _moveDir.x = dir.y * scaledMoveSpeed;
      _moveDir.y = -dir.x * scaledMoveSpeed;

      final a = (pos.y ~/ 1) * mapWidth + ((pos.x + _moveDir.x) ~/ 1);
      final b = ((pos.y + _moveDir.y) ~/ 1) * mapWidth + (pos.x ~/ 1);

      if (worldMap[a] == 0) pos.x += _moveDir.x;
      if (worldMap[b] == 0) pos.y += _moveDir.y;
    } else if (pressed(3)) {
      _moveDir.x = dir.y * scaledMoveSpeed;
      _moveDir.y = -dir.x * scaledMoveSpeed;

      final a = (pos.y ~/ 1) * mapWidth + ((pos.x - _moveDir.x) ~/ 1);
      final b = ((pos.y - _moveDir.y) ~/ 1) * mapWidth + (pos.x ~/ 1);

      if (worldMap[a] == 0) pos.x -= _moveDir.x;
      if (worldMap[b] == 0) pos.y -= _moveDir.y;
    }

    if (pressed(4)) {
      _rot.setRotation(scaledRotSpeed);
      _rot.transform(dir);
      _rot.transform(plane);
    } else if (pressed(5)) {
      _rot.setRotation(-scaledRotSpeed);
      _rot.transform(dir);
      _rot.transform(plane);
    }
  }

  // TODO: Flip the coordinates:
  //       - Find a way to flip the formula (y * width + x) by the y-axis
  void render(double t, Canvas canvas) {
    canvas.save();
    for (int x = 0; x < screen.x; x++) {
      // int s = screen.x ~/ 1 - x - 1;
      raycast(canvas, x, screen.x, screen.y);
    }
    canvas.restore();
  }
}
