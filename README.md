# ofxARKit
openFrameworks + ARKit


## A Basic toolkit for an IOS app with ARKit support.
This is an openFrameworks addon that provides some helper classes for working within ARKit.

# Installation
* Download openFrameworks [here](http://openframeworks.cc/versions/v0.9.8/of_v0.9.8_ios_release.zip)
* clone this repo into your addons folder 

# Current functionality 
ARKit, while it does do a ton behind the scenes; it pretty much leaves it up to you to figure out how you want to render things. The current Apple documentation, while already moderately detailed, unfortunately leaves some stuff out. I've started a class called `ARProcessor.h`, the intent being to help manage the heavy lifting of certain bit's of functionality.


* For whatever reason - Apple neglected to provide a way to easily render the camera image that the ARKit framwork is seeing at every frame. ARProcessor.h provides a way to render the camera image. 
* management of camera transform and projection matrices.
* basic light estimation
* anchor management
* feature detection with the built in point cloud


# Setting up ARKit
ARKit actually does a ton of things in and of itself. All you really have to do is initialize the framework in your ViewController, then you manipulate that session object to grab information the framework provides. 

The goal with how this is setup is to be as flexible as possible so this can be integrated into a wide variety of situations. 
Also because it's really only a few lines to initialize ARKit. 

__First__
* [get xcode beta](https://developer.apple.com/download/)
* [get ios 11 beta](https://beta.apple.com/sp/betaprogram/guide)
* In your project, remember to edit your `ofxIOS-Info.plist` file to include the `Privacy - Camera Usage Description` key with a description for the alert dialog that pops up asking the user for use of their camera.

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

Lastly - include "ofxARKit.h"

### Potential Hurdles in setup of ARKit
A strange occurance I've run into fairly often, and it's unclear as to why this happens; but it seems that, depending on where you initialize ARKit, that could potentially affect performance. ARKit will output console messages when there are issues, specifically in this case you may see as message along the lines of `...tracking performance reduced due to resource constraints...` In all likelihood it's simply hardware related as I don't have access to the latest iDevices but I have had situations where things have run well without ever seeing that message. 

That all being said, fps seems to be minimally affected if at all, though of course, as the message suggests, tracking ability might not be as good. Just something to be on the lookout for.


# Contributing
As I certainly am not the most knowledgeable on many of the topics required to work in AR, that and with ARKit still being in beta; if there's something you feel you can contribute, by all means, feel free to make PR's! (especially now that my time to work on this will be severely limited for the next few weeks :/)
As long as it doesn't break anything I'll most likely accept it. Please make all PRs against the `develop` branch
