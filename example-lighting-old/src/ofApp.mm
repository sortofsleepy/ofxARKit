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
    
    
    light.setAmbientColor(ofFloatColor(1,1,1));
    light.setAttenuation(5.2);
    
    
}


//--------------------------------------------------------------
void ofApp::update(){
    
    processor->update();
    
   
    
}


//--------------------------------------------------------------
void ofApp::draw() {
   
    camera.begin();
    processor->setARCameraMatrices();
    
    // adjust lighting attenuation based on the current amount of lighting detected
    // by ARKit
    light.setAttenuation(processor->getLightIntensity());
    
    // enable the light
    light.enable();
    
    // translate sphere to center
    ofTranslate(ofGetWindowWidth() / 2, ofGetWindowHeight() / 2);
    
    // draw sphere
    ofDrawSphere(0, 0, 100);
    
    
    // disable lighting
    light.disable();
    
    camera.end();
    
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


