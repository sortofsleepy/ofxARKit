# artoolkit
openFrameworks + ARKit


## Basic toolkit for an IOS app with ARKit support.
This is an openFrameworks app that integrates ARKit

# Installation
* Download openFrameworks [here](http://openframeworks.cc/versions/v0.9.8/of_v0.9.8_ios_release.zip)
* In every openFrameworks release, theres always a `apps` folder that contains a `myApps` folder. Clone this repo into the `myApps` folder. If you'd like to move the project
elsewhere, it is possible, but for consistancy and simplicity of getting up and running, it's best to just put it in `myApps`
* You should be able to then, open the project build and go! Note that the first build might take awhile but after that it should be much faster.

# ARKit setup 
ARKit actually does a ton of things for you right off the bat. The way things are set up is that you initialize the toolkit in your ViewController, then pass that session into the class `ARProcessor.h`. The reason for this being that, in my initial testing, the location of where you initialize the framework can affect performance. I'm not sure why or how, but if you're not careful about where you initialize, ARKit might spit out the messsage along the lines of "... tracking performance is reduced due to resource constraints"
or something to that effect. The documentation is currently a bit lacking as to proper setup and even following the example bundled in the XCode 9 beta can still result in the above message. It could just be my hardware ¯\_(ツ)_/¯

To initialize the ARKit framework it's just a few lines
```objective-c
    @interface <your view controller name>()
      @property (nonatomic, strong) ARSession *session;
    @end


    // then somewhere in your implementation block...
    // official example shows you ought to declare the session in viewWillLoad and initialize in viewWillAppear, but 
    // that can result in tracking performance degradation in my experience (again, could just be the phone I'm borrowing, 
    // your milage may vary ¯\_(ツ)_/¯)

   self.session = [ARSession new];
    
    // TODO should be ARWorldTrackingConfiguration now but not in current API(might need to re-download sdk)
    ARWorldTrackingSessionConfiguration *configuration = [ARWorldTrackingSessionConfiguration new];

    // setup horizontal plane detection
    configuration.planeDetection = ARPlaneDetectionHorizontal;
    
    [self.session runWithConfiguration:configuration];
```



# Project structure 
This is following the iOSNative example. This is done to allow for a little more flexibility if more native functionality is needed. The code is more or less exactly the same, minus the extra classes and "apps" I don't need for this.


All that you really need to worry about for the most part is the `ofApp` class in `src/Apps`

# Why openFrameworks?
It provides a unified standard of code across a variety of different contexts. On top of being beginner friendly code, it'll make it possible to develop graphics and phone code seperately


[if you're new to oF, take a look over here.](http://openframeworks.cc/learning/)

