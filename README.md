# ofxARKit
openFrameworks + ARKit


## A Basic toolkit for an IOS app with ARKit support.
This is an openFrameworks addon that provides some helper classes for working within ARKit.

# Installation and project setup
__First__
* [get Xcode](https://developer.apple.com/xcode/)
* [get iOS 11](https://www.apple.com/ios/ios-11/)

__then__
* Download openFrameworks [here](http://openframeworks.cc/versions/v0.9.8/of_v0.9.8_ios_release.zip)
* clone this repo into your addons folder
* start a new project with the project generator. 

__After you've opened up the project file__
* add the ARKit framework to your project

<img width="872" alt="screen shot 2017-09-02 at 2 25 32 pm" src="https://user-images.githubusercontent.com/308302/29998867-ac9d93a0-8fea-11e7-8059-06beba7a172f.png">

* add a permission setting in your `ofxIOS-Info.plist` file. See Permissions below.
* set the project target for IOS 11
<img width="848" alt="screen shot 2017-09-02 at 2 25 22 pm" src="https://user-images.githubusercontent.com/308302/29998868-ac9e216c-8fea-11e7-95e2-7ff4fb218166.png">

Note that you may have to repeat these steps if you make any changes to your project via the generator.

# Initializing ARKit
To initialize the ARKit framework
```objective-c
@interface <your view controller name>()
@property (nonatomic, strong) ARSession *session;
@end


// then somewhere in your implementation block...
// official example shows you ought to declare the session in viewWillLoad and initialize in viewWillAppear but it probably doesn't matter.

self.session = [ARSession new];

// World tracking is used for 6DOF, there are other tracking configurations as well, see 
// https://developer.apple.com/documentation/arkit/arconfiguration
ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];

// setup horizontal plane detection - note that this is optional 
configuration.planeDetection = ARPlaneDetectionHorizontal;

// start the session
[self.session runWithConfiguration:configuration];
```
note that - assuming you're using objective c++(which should be the default for ios oF projects), you could just as easily skip adding a view controller and just initialize in ofApp.h/.mm. 

Lastly - include `ofxARKit.h`, this will give you access to all of the class files as well as the `ARProcessor` api class. Note that when you include `ofxARKit.h`, you'll be able to include a helper header called `ARSessionSetup.h` which includes a helper function for generating a new session.

# Current functionality 
There are a number of classes and other files in the addon that deal with different areas relating to ARKit, like setting up the camera, dealing with feature detection, or dealing with plane detection.

The class `ARProcessor` deals with joining all of these different bits of functionality in a (hopefully) easy to use API, but each of the classes can be used as standalone classes as well.

There are the following classes/files that are part of the addon
* `ARAnchorManager` : deals with managing `ARAnchor` objects as well as `ARPlaneAnchor` objects.
* `ARCam` : deals with managing the camera data found by ARKit and generating something that can be displayed.
* `ARDebugUtils` : as the name suggests - this deals with debugging helpers. At the moment, it's able to handle feature detection and drawing a point cloud.
* `ARObject` : this is a header file that declares `PlaneAnchorObject` and `ARObject`. These structs are used to store converted ARKit data into something more oF friendly.
* `ARShaders` : this stores the core shaders needed by the addon.
* `ARSessionSetup` : provides a helper function for quickly generating a new session. 
* `ARUtils.h` : this stores various utility functions

Note that if you've used the addon pior to 8/29/2017, though I did my best to not make any api changes, there is a very tiny chance your code may break.


### Potential Hurdles in setup of ARKit
Though ARKit is supported on all devices with an A9 chip(6s onwards I believe) - it is helpful to have a fairly recent device or you may experience near immediate degradation of tracking performance. That being said - ARKit is helpful in that manner by warning you of when you're loosing performance by spitting out a message to the effect of `...tracking performance reduced due to resource constraints...`

FPS appears to be minimally affected, but like the message says, things might not work as well. 

If you see the message pop up, the ARKit api offers a limited function set to see what the reason might be in the degredation of tracking quality. You can log the current tracking status by 

* calling `logTrackingState` in `ARProcessor` or `ARCam`. Will log to the console a basic string describing the status. 
* you can also call `getTrackingState` in either class to get the raw tracking state from ARKit. 

Note that in order for those functions to work, you'll need to call the `setup` function of either of those classes and pass in the boolean `true`

# Permissions
For ARKit - You'll have to enable the `Privacy - Camera Usage Description` in your `ofxiOS-Info.plist` file. The value for this field is just the string you want to show users when you ask for camera permissions. If you've never touched a plist file before, no worries! Its very easy to change. 

For example in the screenshot below
<img width="853" alt="screen shot 2017-09-02 at 2 12 39 pm" src="https://user-images.githubusercontent.com/308302/29998801-f4f1ca7e-8fe8-11e7-8f5a-39cdb4097ef2.png">

You'll see I added it to the very end. If the permission isn't there, all you need to do is over over one of the items already in the list and click on the plus sign. This will add a new field and you can just start typing `Privacy - Camera Usage Description`. Xcode will attempt to autocomplete as well. 

# Contributing
As I certainly am not the most knowledgeable on many of the topics required to work in AR, that and with ARKit still being in beta; if there's something you feel you can contribute, by all means, feel free to make PR's!

As long as it doesn't break anything I'll most likely accept it. Please make all PRs against the `develop` branch

A big thank you to all contributors thus far!
