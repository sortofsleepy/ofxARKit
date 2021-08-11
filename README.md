# ofxARKit
openFrameworks + ARKit


## A Basic toolkit for an IOS app with ARKit support.
This is an openFrameworks addon that provides some helper classes for working within ARKit.

# Installation and project setup
__First__
* [get Xcode](https://developer.apple.com/xcode/)
* [get the latest version of iOS](https://www.apple.com/ios)

__then__
* Download openFrameworks [here](https://openframeworks.cc/versions/v0.11.2/of_v0.11.2_ios_release.zip)
* clone this repo into your addons folder
* start a new project with the project generator.

__After you've opened up the project file__
* add a permission setting in your `ofxIOS-Info.plist` file. See Permissions below.
* set the project target for IOS 11 / 12 / 13 / 14 +
* you may need to do two things with the `Shader.metal` file
   * Add it to the list of compiled sources
   * You will also likely need to make sure to set the file designation back to it's default(for some reason it's marked as "Data" in the projectGenerator generated project)


Note that you may have to repeat these steps if you make any changes to your project via the generator.

# Possible Device limitations
Note that while most features are generally supported across all devices that support ARKit, there may be some features that require specific hardware. [See the ARKit website](https://developer.apple.com/augmented-reality/arkit/) for more details. You should see any limitations listed at the bottom of the page in the footer.

# Initializing ARKit
To get started, you need to initialize the ARKit framework. This can be done a couple of different ways. ofxARKit provides a helper api to quickly initialize a session without too much fuss.

__SessionSetup__
```c++
    ofxARKit::core::SessionFormat format;
    format.enablePlaneTracking().enableLighting();
    auto session = ARCore::generateNewSession(format);
```

The `SessionFormat` object is a way to enable various features of ARKit in a more straightforward manner. Passing an instance of an `SessionFormat` object to `ARCore::generateNewSession` will automatically generate a new `ARSession` object, while ensuring the specified features are useable on your device.


You can of course, write things by hand which isn't too difficult either.

__Raw Objective-C__
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

As to where to initialize, it really doesn't matter all that much, if your project setup is more in the form of a traditional IOS objective-c app, you can set things up in your view controller, or if your app is more like a normal oF app, you should be able to just as easily set things up in your `setup` function.

# Permissions
For ARKit and iOS in general,a there are several permissions you may need to request from the user depending on the kinds of features you're looking to utilize. At a minimum you'll have to enable the `Privacy - Camera Usage Description` in your `ofxiOS-Info.plist` file. The value for this field is just the string you want to show users when you ask for camera permissions. If you've never touched a plist file before, no worries! Its very easy to change.


For example in the screenshot below
<img width="853" alt="screen shot 2017-09-02 at 2 12 39 pm" src="https://user-images.githubusercontent.com/308302/29998801-f4f1ca7e-8fe8-11e7-8f5a-39cdb4097ef2.png">

You'll see I added it to the very end. If the permission isn't there, all you need to do is over over one of the items already in the list and click on the plus sign. This will add a new field and you can just start typing `Privacy - Camera Usage Description`. Xcode will attempt to autocomplete as well.
<br>
If you are trying to use the AirPod Motion with it, you must add an other field : `NSMotionUsageDescription`.

# Deploying to the App Store

By default `#AR_FACE_TRACKING` is turned on, allowing you to try out examples
such as `example-face-tracking` (if you have an iPhone X). We keep this
variable on by default in order to make the plugin easy to experiment with, but if **you're
not using the TrueDepth API for face tracking in your app** then you'll get [issues trying to
publish to th Apple App Store](https://forum.unity.com/threads/submitting-arkit-apps-to-appstore-without-face-tracking.504572/):

> "We noticed your app contains the TrueDepth APIs but we were unable to locate these features in your app. Please provide information about how your app uses the TrueDepth APIs."

To avoid this if you're not using TrueDepth & going to publish to the App Store change the macro defined in `ofxARKit.h` in your OpenFrameworks plugins directory to `false`:

```diff
// Line 2 of ARFaceTrackingBool.h
-  #define AR_FACE_TRACKING true
+  #define AR_FACE_TRACKING false
```

This will remove the code from compilation so you don't get flagged by Apple
for including code you're not using.

# Contributing
For me, time is unfortunately a luxury as creative coding is sadly not my day job; I can only hunt and peck at small things here and there. All that as well as a general lack of knowledge on topics required to work effectively with AR all contribute to making it difficult to keep this up to date as I ought to; sooo, if there's something you feel you can contribute, by all means, feel free to make PR's!


As long as it doesn't break anything I'll most likely accept it.

First and formost, please work from the `develop` branch. This is usually the most up-to-date branch and is intended to be a staging ground for any new features or changes. Once you are done with the feature you would like to add, please make all PRs against the `develop` branch

A big thank you to all contributors thus far!
