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
    
   // processor->anchorController->addAnchor(ImageMesh());
    
  
//copyFBO.allocate(ofGetWindowWidth(),ofGetWindowHeight(),GL_RGBA);

}

//--------------------------------------------------------------
void ofApp::update(){
    
    processor->update();
    
}


ofCamera camera;
//--------------------------------------------------------------
void ofApp::draw() {
  
    ofEnableAlphaBlending();
    
    ofDisableDepthTest();
    processor->drawFrame();
    ofEnableDepthTest();
   
   
    
    // This loops through all of the added anchors.
    processor->anchorController->loopAnchors([=](ARObject obj,int index) -> void {
        camera.begin();
        processor->setARCameraMatrices();
        
        ofPushMatrix();
        ofMultMatrix(obj.modelMatrix);
        
        ofSetColor(255);
        ofRotate(90,0,0,1);
        ofScale(0.0001, 0.0001);
        
        float x = ofGetWindowWidth() / 2;
        float y = ofGetWindowHeight() / 2;
        
        x *= -1;
        y *= -1;
      
        images[index].draw(x,y,ofGetWindowWidth(),ofGetWindowHeight());
        
        ofPopMatrix();
        
        camera.end();
       
        
    });
    
    
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
  
    // this will quickly build up memory so clear when we hit the max number of iamges.
    if(images.size() >= maxImages){
        images.clear();
    }
   
    ofFbo fbo;
    fbo.allocate(ofGetWindowWidth(), ofGetWindowHeight(),GL_RGBA);
    
    fbo.begin();
    ofClear(0,255);
    processor->getCameraTexture().draw(0,0,ofGetWindowWidth(),ofGetWindowHeight());
    fbo.end();
    
    images.push_back(fbo);
    processor->anchorController->addAnchor();
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


