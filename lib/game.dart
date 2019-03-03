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
final rotSpeed = 3.0;

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
  // TODO: Use Vector2.floor()
  int mapX = pos.x ~/ 1;
  int mapY = pos.y ~/ 1;

  // length of ray from one x or y-side to next x or y-side
  deltaDist.x = (1 / rayDir.x).abs();
  deltaDist.y = (1 / rayDir.y).abs();
  // double deltaDistX = (1 / rayDir.x).abs();
  // double deltaDistY = (1 / rayDir.y).abs();
  // double perpWallDist;

  //what direction to step in x or y-direction (either +1 or -1)
  int stepX = 0;
  int stepY = 0;

  int hit = 0; // was there a wall hit?
  int side; // was a NS or a EW wall hit?

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
      color = Color(0xffff0000);
      break; //red
    case 2:
      color = Color(0xff00ff00);
      break; //green
    case 3:
      color = Color(0xff0000ff);
      break; //blue
    case 4:
      color = Color(0xffffffff);
      break; //white
    default:
      color = Color(0xffff00ff);
      break; //yellow
  }

  // give x and y sides different brightness
  // if (side == 1) {
  //   color = color / 2;
  // }

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

  void update(double t, Pressed pressed) {
    // for (int i = 0; i < 7; i++) {
    //   if (pressed(i)) {
    //     print(i);
    //   }
    // }
    if (pressed(0)) {
      final a =
          (pos.y ~/ 1) * mapWidth + ((pos.x + dir.x * moveSpeed * t) ~/ 1);
      final b =
          ((pos.y + dir.y * moveSpeed * t) ~/ 1) * mapWidth + (pos.x ~/ 1);

      if (worldMap[a] == 0) pos.x += dir.x * moveSpeed * t;
      if (worldMap[b] == 0) pos.y += dir.y * moveSpeed * t;

      print(pos);
    } else if (pressed(2)) {
      final a =
          (pos.y ~/ 1) * mapWidth + ((pos.x - dir.x * moveSpeed * t) ~/ 1);
      final b =
          ((pos.y - dir.y * moveSpeed * t) ~/ 1) * mapWidth + (pos.x ~/ 1);

      if (worldMap[a] == 0) pos.x -= dir.x * moveSpeed * t;
      if (worldMap[b] == 0) pos.y -= dir.y * moveSpeed * t;

      print(pos);
    }

    if (pressed(1)) {
    } else if (pressed(3)) {}

    // var f = dir.floor();
    if (pressed(4)) {
      _rot.setRotation(rotSpeed * t);
      _rot.transform(dir);
      _rot.transform(plane);
    } else if (pressed(5)) {
      _rot.setRotation(-rotSpeed * t);
      _rot.transform(dir);
      _rot.transform(plane);
    }
  }

  void render(double t, Canvas canvas) {
    canvas.save();
    for (int x = 0; x < screen.x; x++) {
      // int s = screen.x ~/ 1 - x - 1;
      raycast(canvas, x, screen.x, screen.y);
    }
    canvas.restore();
  }
}
