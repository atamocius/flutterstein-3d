# Flutterstein 3D

A 3D raycaster implemented in Flutter.

> For anyone looking for the _original / unminified_ code, there is a branch named `prior-to-reduction` which is pretty much the code prior to the minification.
 
> This app was submitted as an entry to the [Flutter 5KB Challenge](https://flutter.dev/create).

![Gameplay 0](/captures/gameplay0_320x180.gif?raw=true)
![Gameplay 1](/captures/gameplay1_320x180.gif?raw=true)
![Gameplay 2](/captures/gameplay2_320x180.gif?raw=true)
![Gameplay 3](/captures/gameplay3_320x180.gif?raw=true)

## Description

This is a an implementation of the 3D raycasting algorithm as employed by games like Wolfenstein 3D. It uses the Canvas API, specifically `drawRawAtlas`, to render the level data and also to batch the draw calls.

On-screen controls have also been implemented using `PointerData`, with _inflated_ tap areas to improve responsiveness.

> ### To keep things interesting
>
> Due to the 5KB restriction, I can't really add any game logic. However, when I built the level, I hid 9 other Flutter logos (10 if you count the first logo at the start) within the level, see if you can find them all before reaching the exit (the exit is another _elevator_).
>
> If you want to see where all of the logos are hidden, [here is the map](/captures/level_map.png?raw=true)

## Running the app

```bash
flutter run --release
```

I highly recommend running this on _Android_ devices since that is where I have been testing the app on. Theoretically, it should also run on iOS since there is no platform specific code or configuration employed.

> ### Orientation
>
> Although the app supports both _portrait_ and _landscape_ orientation, it looks way better in _landscape_.
