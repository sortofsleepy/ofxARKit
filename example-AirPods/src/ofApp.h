#pragma once

#include "ofxiOS.h"
#include <ARKit/ARKit.h>
#include "ofxARKit.h"
#include "ARAirPodMoves.h"
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
    
    vector < matrix_float4x4 > mats;
    vector<ARAnchor*> anchors;
    ofCamera camera;
    ofTrueTypeFont font;
    ofImage img;

    // ====== AR STUFF ======== //
    ARSession * session;
    ARRef processor;
    airPProMoves * airPodPro;
    
    glm::quat getAirPodsQuaternion(){
          
        CMQuaternion quat = airPodPro->quat();
        return glm::quat(quat.x, quat.y, quat.z, quat.w);
          
    }
    glm::vec3 getAirPodsAcceleration(){
          
          accAirPods acc = airPodPro->acc();
          return  glm::vec3(acc.x, acc.y, acc.z);
    }
    
    
    // ==== AIRPODS ==== //
    void processAirPods();
    glm::quat quatAirPods;
    glm::vec3 _accAirPods;

    
};


