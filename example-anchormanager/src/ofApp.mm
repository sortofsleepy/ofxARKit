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
    
    img.load("OpenFrameworks.png");
    
    int fontSize = 8;
    if (ofxiOSGetOFWindow()->isRetinaSupportedOnDevice())
        fontSize *= 2;
    
    font.load("fonts/mono0755.ttf", fontSize);
    
    processor = ARProcessor::create(session);
    processor->setup();
}

//--------------------------------------------------------------
void ofApp::update(){
    processor->update();
}

//--------------------------------------------------------------
void ofApp::draw() {
    ofEnableAlphaBlending();
    
    ofDisableDepthTest();
    processor->draw();
    ofEnableDepthTest();
    
  
    /*
     processor->anchorController->loopAnchors([=](ARObject obj)->void {
     camera.begin();
     processor->setARCameraMatrices();
     
     ofPushMatrix();
     ofMultMatrix(obj.modelMatrix);
     
     ofSetColor(255);
     ofRotate(90,0,0,1);
     
     float aspect = ARCommon::getNativeAspectRatio();
     img.draw(-aspect/8,-0.125,aspect/4,0.25);
     
     ofPopMatrix();
     
     camera.end();
     });
     */
    
    ofDisableDepthTest();
    // ========== DEBUG STUFF ============= //
    int w = MIN(ofGetWidth(), ofGetHeight()) * 0.6;
    int h = w;
    int x = (ofGetWidth() - w)  * 0.5;
    int y = (ofGetHeight() - h) * 0.5;
    int p = 0;
    
    x = ofGetWidth()  * 0.2;
    y = ofGetHeight() * 0.11;
    p = ofGetHeight() * 0.035;
    
    
    font.drawString("frame num      = " + ofToString( ofGetFrameNum() ),    x, y+=p);
    font.drawString("frame rate     = " + ofToString( ofGetFrameRate() ),   x, y+=p);
    font.drawString("screen width   = " + ofToString( ofGetWidth() ),       x, y+=p);
    font.drawString("screen height  = " + ofToString( ofGetHeight() ),      x, y+=p);
    

    
}

//--------------------------------------------------------------
void ofApp::exit() {
    //
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs &touch){
    
    processor->addAnchor(ofVec3f(touch.x,touch.y,0.0));
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
    processor->updateDeviceInterfaceOrientation();
    processor->deviceOrientationChanged();
}


//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs& args){
    
}


