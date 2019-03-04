import 'dart:math';
import 'dart:ui';
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';

// Screen size (aka projection plane)
const screenW = 640.0, screenH = 360.0;

// Map size
const mapW = 24, mapH = 24;

// Convert coordinates to map index (but Y is flipped)
int toMapIndex(int x, int y) => (mapH - y - 1) * mapW + x;

class Raycaster {
  // Camera position
  final pos = Vector2(22, 12);

  // Direction vector
  final dir = Vector2(-1, 0);

  // 2D raycaster version of camera plane
  final plane = Vector2(0, 0.66);

  // length of ray from current position to next x or y-side
  final _sideDist = Vector2.zero();

  // length of ray from one x or y-side to next x or y-side
  final _deltaDist = Vector2.zero();

  final _rayDir = Vector2.zero();

  // TODO: Compute _plane from _dir (normalized) and FOV value
  Raycaster();

  void render(Canvas canvas, List<int> map) {
    for (int x = 0; x < screenW; x++) {
      _raycast(canvas, map, x, screenW, screenH);
    }
  }

  void _raycast(Canvas canvas, List<int> map, int x, double w, double h) {
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

    // Calculate lowest and highest pixel to fill in current stripe
    var drawStart = -lineHeight / 2 + h / 2;
    if (drawStart < 0) drawStart = 0;
    var drawEnd = lineHeight / 2 + h / 2;
    if (drawEnd >= h) drawEnd = h - 1;

    // choose wall color
    Color color;
    switch (map[toMapIndex(mapX, mapY)]) {
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
    _verLine(canvas, x / 1, drawStart, drawEnd, color);
  }

  void _verLine(
    Canvas canvas,
    double x,
    double start,
    double end,
    Color color,
  ) {
    // TODO: Use drawRawPoints
    canvas.drawLine(
      Offset(x, start),
      Offset(x, end),
      Paint()
        ..color = color
        ..strokeWidth = 1,
    );
  }
}
