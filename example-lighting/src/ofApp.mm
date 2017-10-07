#include "ofApp.h"



//--------------------------------------------------------------
ofApp :: ofApp (ARSession * session){
    this->session = session;
    cout << "creating ofApp" << endl;
}

ofApp::ofApp(){}

//--------------------------------------------------------------
ofApp :: ~ofApp () {
    cout << "destroying ofApp" << endl;
}

//--------------------------------------------------------------
void ofApp::setup() {
    ofBackground(127);
    

    int fontSize = 8;
    if (ofxiOSGetOFWindow()->isRetinaSupportedOnDevice())
        fontSize *= 2;
    
    font.load("fonts/mono0755.ttf", fontSize);
    
    
    processor = ARProcessor::create(session);
    processor->setup();
    
   // camera.setupPerspective();
    light.setAmbientColor(ofFloatColor(255,0,0));
    light.setAttenuation(0.2);
    
    
    
}


//--------------------------------------------------------------
void ofApp::update(){
    
    processor->update();
    
   
    
}


//--------------------------------------------------------------
void ofApp::draw() {
   
   
    //ofEnableAlphaBlending();
    processor->draw();
    
    camera.begin();
    processor->setARCameraMatrices();
    
    // adjust lighting attenuation based on the current amount of lighting detected
    // by ARKit
    light.setAttenuation(processor->getLightIntensity());
    
    // enable the light
    light.enable();
    
    ofPushStyle();
    
    ofTranslate(0,0,-70);
    // draw sphere
    ofDrawSphere(0, 0, 20);
    ofPopStyle();
    
    // disable lighting
    light.disable();
    
    camera.end();
    /*
     //ofEnableAlphaBlending();
     processor->draw();
     
     camera.begin();
     processor->setARCameraMatrices();
     
     // adjust lighting attenuation based on the current amount of lighting detected
     // by ARKit
     light.setAttenuation(5.2);
     
     // enable the light
     light.enable();
     
     ofPushStyle();
     
     ofTranslate(0,0,-70);
     // draw sphere
     ofDrawSphere(0, 0, 20);
     ofPopStyle();
     
     // disable lighting
     light.disable();
     
     camera.end();
     */
    
}

//--------------------------------------------------------------
void ofApp::exit() {
    //
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs &touch){
    
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs &touch){
    
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs &touch){
    
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs &touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){
    
}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){
}


//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs& args){
    
}


