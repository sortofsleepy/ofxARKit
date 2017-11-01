#pragma once

#include "ofxiOS.h"
#include "ofxARKit.h"
#include "ofxBullet.h"
#include <vector>
#include "Button.h"
class ofApp : public ofxiOSApp {
    
public:
    
    ofApp (ARSession * session);
    ofApp();
    ~ofApp ();
    
    void setup();
    void update();
    void draw();
    void exit();
    
    void touchDown(ofTouchEventArgs &touch);
    void touchMoved(ofTouchEventArgs &touch);
    void touchUp(ofTouchEventArgs &touch);
    void touchDoubleTap(ofTouchEventArgs &touch);
    void touchCancelled(ofTouchEventArgs &touch);
    
    void lostFocus();
    void gotFocus();
    void gotMemoryWarning();
    void deviceOrientationChanged(int newOrientation);
    
    
    ofTrueTypeFont font;
    ofxBulletWorldRigid world;
    ofxBulletBox ground;
    ofCamera camera;
    
    std::vector<ofxBulletBox*> boxes;
    int maxBoxes;
    
    // button to signal you want to add a plane
    Button addPlane;
    
    // ====== AR STUFF ======== //
    ARSession * session;
    ARRef processor;
    
    ofImage img;
    
};


