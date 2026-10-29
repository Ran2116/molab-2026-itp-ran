# [07-FaceMeshUI](https://github.com/molab-itp/07-FaceMeshUI)
```
Claude:
in FaceMeshUI/FaceMeshUI.xcodeproj
use ARKit to show ARFaceTrackingConfiguration
that can report features: smiling,
blinking back to ConventView as text status


update on the 07-FaceMeshUI
using the existing FaceTracker smile/wink detection,
add a full-screen emoji overlay on top of the AR face view:
- when smiling, smile emoji (😊😄🥰...) float up from the bottom of the screen
- when winking (one eye closed), 😉 emoji float up the same way
- the number of emoji should scale with the smile / eye-blink value (0–1)
- keep the detection logic consistent with the existing status text
- keep edits minimal; don't change the ARKit setup

