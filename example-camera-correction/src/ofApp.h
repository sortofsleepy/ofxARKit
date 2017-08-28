#pragma once

#include "ofxiOS.h"
#include <ARKit/ARKit.h>
#include "ofxARKit.h"
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
    
    
    ofVbo vbo;
    
    
    ofTrueTypeFont font;
    
    //CVOpenGLESTextureRef createTextureFromPixelBuffer(CVPixelBufferRef pixelBuffer,int planeIndex);
    
    
    
    // ====== AR STUFF ======== //
    ARSession * session;
    
    ARRef processor;
    
    /*
     int32_t cameraWidth;
     int32_t cameraHeight;
     
     */
    
    ofImage img;
    
};


