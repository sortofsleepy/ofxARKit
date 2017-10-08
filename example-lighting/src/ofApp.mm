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
    
    shader.load("shader.vert", "shader.frag");
    sphere = ofMesh::sphere(200);
    
    camera.setupPerspective();
    
    
}


//--------------------------------------------------------------
void ofApp::update(){
    
    processor->update();
    
   
    
}


//--------------------------------------------------------------
void ofApp::draw() {
   
   
    processor->draw();
    
    ofEnableDepthTest();
    
    
    // start camera - note that for the sake of simplicity and to best show an actual lighting change,
    // we aren't gonna use anchors or the ARKit camera matrices so that the sphere will always be in the middle of the
    // screen. If we were to use the ARKit camera, then it'd be a bit harder to test lighting since the sphere would be
    // stuck at 0,0 and would move out of frame from the camera.
    
    camera.begin();
    
    // if you'd like to use the camera though to see what it's like,
    // 1. uncomment the next line.
    // 2. comment out the ofTranslate call
    // 3. comment out the camera.setupPerspective call in setup
    //processor->setARCameraMatrices();
    
    
    ofTranslate(ofGetWindowWidth() / 2, ofGetWindowHeight() / 2);
    shader.begin();
    shader.setUniform1f("lightIntensity", processor->getLightIntensity());
    sphere.draw();
    shader.end();
    
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


