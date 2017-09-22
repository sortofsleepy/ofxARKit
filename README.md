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


### Potential Hurdles in setup of ARKit
A strange occurance I've run into fairly often, and it's unclear as to why this happens; but it seems that, depending on where you initialize ARKit, that could potentially affect performance. It makes no sense I realize, but I have seen differences in where things get initialized. I have no idea why it happens or what the difference is but when it happens you may see a message like  `...tracking performance reduced due to resource constraints...` or something to that effect.

In all likelhood it's due to hardware; I don't have access to the latest iPhones and iPads, but still just something to watch out for.
Fps seems to be minimally affected if at all, though of course, as the message suggests, tracking ability might not be as good. Just something to be on the lookout for.

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
