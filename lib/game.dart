import 'dart:math' as math;
import 'dart:ui';

typedef bool Pressed(int btn);

// Button:
// 0 : up
// 1 : right
// 2 : down
// 3 : left
// 4 : red
// 5 : blue
// 6 : green

class Game {
  void update(double t, Pressed pressed) {
    for (int i = 0; i < 7; i++) {
      if (pressed(i)) {
        print(i);
      }
    }
  }

  void render(double t, Canvas canvas) {
    canvas.save();
    canvas.restore();
  }
}
