#pragma once

#include "ofxiOS.h"
#include "ofxARKit.h"
#import <ARKit/ARKit.h>

#define STRINGIFY(A) #A
class ofApp : public ofxiOSApp {
    
public:
    ARSession * session;
    
    ofApp (ARSession * session);
    ofApp();
    ~ofApp ();
    void setup();
    void update();
    void draw();
    void exit();
    
    void touchDown(ofTouchEventArgs & touch);
    void touchMoved(ofTouchEventArgs & touch);
    void touchUp(ofTouchEventArgs & touch);
    void touchDoubleTap(ofTouchEventArgs & touch);
    void touchCancelled(ofTouchEventArgs & touch);
    
    void lostFocus();
    void gotFocus();
    void gotMemoryWarning();
    void deviceOrientationChanged(int newOrientation);
    
    
    ofTextureData data;
    ofTexture tex;
    ofxARKit::core::MetalCamRenderer * camera;
    ofMesh mesh;
    ofCamera cam;
    ofShader shader;
    std::string vertex = STRINGIFY(
                                   
                                   attribute vec2 position;
                                   varying vec2 vUv;
                                   
                                   
                                   
                                   const vec2 scale = vec2(0.5,0.5);
                                   void main(){
                                       
                                       
                                       vUv = position.xy * scale + scale;
                                       
                                       
                                       
                                       gl_Position = vec4(position,0.0,1.0);
                                       
                                       
                                       
                                   }
                                   
                                   );
    
    std::string fragment = STRINGIFY(
                                     precision highp float;
                                     varying vec2 vUv;
                                     uniform sampler2D tex;
                                     void main(){
                                         
                                         vec2 uv = vec2(vUv.s, 1.0 - vUv.t);
                                         
                                         
                                         vec4 _tex = texture2D(tex,uv);
                                         gl_FragColor = _tex;
                                     }
                                     );
    
};


