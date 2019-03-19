# Flutterstein 3D

A 3D raycaster implemented in Flutter.

![Gameplay 0](/captures/gameplay0_320x180.gif?raw=true)
![Gameplay 1](/captures/gameplay1_320x180.gif?raw=true)
![Gameplay 2](/captures/gameplay2_320x180.gif?raw=true)
![Gameplay 3](/captures/gameplay3_320x180.gif?raw=true)

## Description

This is a an implementation of the 3D raycasting algorithm as employed by games like Wolfenstein 3D. It uses the Canvas API, specifically `drawRawAtlas`, to render the level data and also to batch the draw calls.

On-screen controls have also been implemented using `PointerData`, with _inflated_ tap areas to improve responsiveness.

## Running the app

I highly recommend running this on Android devices since that is where I have been testing the app on.

Theoretically, it should also run on iOS since there is no platform specific code or configuration employed.
