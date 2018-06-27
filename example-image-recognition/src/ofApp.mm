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
 
}



//--------------------------------------------------------------
void ofApp::update(){
    
    processor->update();
    processor->updateImages();
}

//--------------------------------------------------------------
void ofApp::draw() {
    ofDisableDepthTest();
    processor->draw();
    ofEnableDepthTest();
   
    // if we have a valid frame - render something!
    if(processor->isValidFrame()){
        camera.begin();
        processor->setARCameraMatrices();
        
        auto imageAnchors = processor->getImages();
        
        for(int i = 0; i < imageAnchors.size(); ++i){
            auto anchor = imageAnchors[i];
            auto w = anchor.width;
            auto h = anchor.height;
            
            
            ofPushMatrix();
            ofMultMatrix(anchor.transform);
            
            // for simplicity - just gonna draw a white plane.
            // Note - there may be a slight delay before something is drawn.
            // TODO figure out why there is a delay and how to avoid if possible. 
            ofRotateXDeg(90);
            ofDrawRectangle(-w / 2, -h / 2, w, h);
            
            ofPopMatrix();
        }
        
        
        camera.end();
    }
    
    
    
    
    // ========== DEBUG STUFF ============= //
    processor->debugInfo.drawDebugInformation(font);
   
    
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
    processor->anchorController->clearAnchors();
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


