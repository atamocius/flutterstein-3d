import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'utils.dart';
import 'game.dart';
import 'buttons.dart';

main() async {
  await SystemChrome.setEnabledSystemUIOverlays([]);
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

  var vs = Size(640, 360),
      b = Offset.zero & vs,
      dt = Float64List(16),
      ba = await loadImage('img/gui.png');

  Offset o;
  Buttons bs;

  var hmc = () async {
    var sz = window.physicalSize, r = sz.shortestSide / vs.shortestSide;

    dt
      ..[0] = r
      ..[5] = r
      ..[10] = 1
      ..[15] = 1;

    o = (sz / r - vs as Offset) * 0.5;

    bs = await loadButtons(
      'data/buttons.json',
      r,
      1 / r * window.devicePixelRatio,
      Offset.zero & sz / r,
      ba,
    );
  };

  hmc();
  window.onMetricsChanged = hmc;

  var lvl = await loadLevel('data/level.json'),
      g = Game(vs, lvl),
      z = Duration.zero,
      pv = z;

  window.onBeginFrame = (n) {
    var r = PictureRecorder(), c = Canvas(r, b), d = pv == z ? z : n - pv;
    pv = n;
    var t = d.inMicroseconds / 1000000;

    c.save();
    c.translate(o.dx, o.dy);
    c.clipRect(b);
    g.update(t, bs.pressed);
    g.render(c);
    c.restore();

    bs.render(c);

    var p = r.endRecording(),
        br = SceneBuilder()
          ..pushTransform(dt)
          ..addPicture(Offset.zero, p)
          ..pop();

    window
      ..render(br.build())
      ..scheduleFrame();
  };

  window
    ..scheduleFrame()
    ..onPointerDataPacket = (p) => bs.update(p.data);
}
