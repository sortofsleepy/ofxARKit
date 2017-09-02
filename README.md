# ofxARKit
openFrameworks + ARKit


## A Basic toolkit for an IOS app with ARKit support.
This is an openFrameworks addon that provides some helper classes for working within ARKit.

# Installation and project setup
__First__
* [get xcode beta](https://developer.apple.com/download/)
* [get ios 11 beta](https://beta.apple.com/sp/betaprogram/guide)

__then__
* Download openFrameworks [here](http://openframeworks.cc/versions/v0.9.8/of_v0.9.8_ios_release.zip)
* clone this repo into your addons folder

If you've copied one of the example projects - you should be all set, but if not you'll also need to

* add the ARKit framework to your project
* add a permission setting in your `ofxIOS-Info.plist` file. See Permissions below.
* set the project target for IOS 11

Note that if you use the openFrameworks project generator you may have to repeat these steps if you make any changes to your project via the generator.

# Initializing ARKit
To initialize the ARKit framework
```objective-c
@interface <your view controller name>()
@property (nonatomic, strong) ARSession *session;
@end


// then somewhere in your implementation block...
// official example shows you ought to declare the session in viewWillLoad and initialize in viewWillAppear, but
// that can result in tracking performance degradation in my experience (again, could just be the phone I'm borrowing,
// your milage may vary ¯\_(ツ)_/¯)

self.session = [ARSession new];

ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];

// setup horizontal plane detection
configuration.planeDetection = ARPlaneDetectionHorizontal;

[self.session runWithConfiguration:configuration];
```
note that - assuming you're using objective c++(which should be the default for ios oF projects), you could just as easily skip adding a
view controller and just initialize in ofApp.h/.mm

Lastly - include `ofxARKit.h`, this will give you access to all of the class files as well as the `ARProcessor` api class.

### Potential Hurdles in setup of ARKit
A strange occurance I've run into fairly often, and it's unclear as to why this happens; but it seems that, depending on where you initialize ARKit, that could potentially affect performance. It makes no sense I realize, but I have seen differences in where things get initialized. I have no idea why it happens or what the difference is but when it happens you may see a message like  `...tracking performance reduced due to resource constraints...` or something to that effect.

In all likelhood it's due to hardware; I don't have access to the latest iPhones and iPads, but still just something to watch out for.
Fps seems to be minimally affected if at all, though of course, as the message suggests, tracking ability might not be as good. Just something to be on the lookout for.

# Current functionality 
ARKit, while it does do a ton behind the scenes; it pretty much leaves it up to you to figure out how you want to render things. The current Apple documentation, while already moderately detailed, unfortunately leaves some stuff out. 

There are a number of classes and other files in the addon that deal with different areas relating to ARKit, like setting up the camera, dealing with feature detection, or dealing with plane detection.

The class `ARProcessor` deals with joining all of these different bits of functionality in a (hopefully) easy to use API, but each of the classes can be used as standalone classes as well.

There are the following classes/files that are part of the addon
* `ARAnchorManager` : deals with managing `ARAnchor` objects as well as `ARPlaneAnchor` objects.
* `ARCam` : deals with managing the camera data found by ARKit and generating something that can be displayed.
* `ARDebugUtils` : as the name suggests - this deals with debugging helpers. At the moment, it's able to handle feature detection and drawing a point cloud.
* `ARObject` : this is a header file that declares `PlaneAnchorObject` and `ARObject`. These structs are used to store converted ARKit data into something more oF friendly.
* `ARShaders` : this stores the core shaders needed by the addon.
* `ARUtils.h` : this stores various utility functions

Note that if you've used the addon pior to 8/29/2017, though I did my best to not make any api changes, there is a very tiny chance your code may break.


# Permissions
For ARKit - You'll have to enable the `Privacy - Camera Usage Description` in your `ofxiOS-Info.plist` file. The value for this field is just the string you want to show users when you ask for camera permissions.


# Contributing
As I certainly am not the most knowledgeable on many of the topics required to work in AR, that and with ARKit still being in beta; if there's something you feel you can contribute, by all means, feel free to make PR's!

As long as it doesn't break anything I'll most likely accept it. Please make all PRs against the `develop` branch

A big thank you to all contributors thus far!
