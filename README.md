gesluxe
=======
Inspired by Gestouch ActionScript 3 gesture recognition library

##Supported gestures:
 * Tap
 * Pan
 * Long press
 * Swipe
 * Zoom
 * Rotation
 * Transform

##Clone the repository and test
> haxelib git gesluxe https://github.com/josuigoa/gesluxe.git

##Usage
First of all, we need to initialize the gesture recognizer (initialize the touch/mouse listeners)
```
org.gesluxe.Gesluxe.init();
```
Then, create a new Gesture object (ZoomGesture, PanGesture, SwipeGesture...) for each gesture you want to handle
```
// ...
zoomGesture = new org.gesluxe.gestures.ZoomGesture();
zoomGesture.events.listen(GestureEvent.GESTURE_BEGAN, onZoomGesture);
zoomGesture.events.listen(GestureEvent.GESTURE_CHANGED, onZoomGesture);
// ...

function onZoomGesture(event: GestureEventData) {
  Luxe.camera.scale.set_xy(zoomGesture.scaleX, zoomGesture.scaleY);
}
```
If you want to try a more complete sample, you can run the test project from this repository

 * cd /path/to/gesluxe/test_project
 * haxelib run flow run web

It should work on every target supported by Luxe. Tested and working on CPP (Window, Mac, iOS, Android) and Web

##Screenshots
![](https://github.com/josuigoa/gesluxe/blob/master/screenshot1.png)
![](https://github.com/josuigoa/gesluxe/blob/master/screenshot2.png)
