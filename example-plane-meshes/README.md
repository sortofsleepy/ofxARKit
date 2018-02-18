#  example-planes

This example demonstrates plane detection and how to draw the result. Note that this example will only work if you initiailze your ARSession to account for plane detection like so


```objective-c
ARSession * session = [ARSession new];

ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];

// setup horizontal plane detection
configuration.planeDetection = ARPlaneDetectionHorizontal;

[session runWithConfiguration:configuration];
```

