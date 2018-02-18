#include "ofApp.h"



void logSIMD(const simd::float4x4 &matrix)
{
    std::stringstream output;
    int columnCount = sizeof(matrix.columns) / sizeof(matrix.columns[0]);
    for (int column = 0; column < columnCount; column++) {
        int rowCount = sizeof(matrix.columns[column]) / sizeof(matrix.columns[column][0]);
        for (int row = 0; row < rowCount; row++) {
            output << std::setfill(' ') << std::setw(9) << matrix.columns[column][row];
            output << ' ';
        }
        output << std::endl;
    }
    output << std::endl;
}

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
    
    // of 1, 2, 3
    for (int i=0; i<3;i++){
        images.push_back(ofImage());
        images.back().load("OpenFrameworks"+ofToString(i+1)+".png");
    }
    
    int fontSize = 8;
    if (ofxiOSGetOFWindow()->isRetinaSupportedOnDevice())
        fontSize *= 2;
    
    font.load("fonts/mono0755.ttf", fontSize);
    
    processor = ARProcessor::create(session);
    processor->setup();
    
    // image names aren't loaded until session is ready
    // could use a callback or something, but for now
    // stuff is in update
}



//--------------------------------------------------------------
void ofApp::update(){
    
    processor->update();
    processor->updateImages();
    
    static bool bImagesSetup = false;
    
    if ( !bImagesSetup ){
        
        // a not very exciting way to do different stuff for different images
        vector<string> names = processor->getReferenceImages();
        
        if (names.size() > 0 ){
            bImagesSetup = true;
            int index = 0;
            for ( auto name : names ){
                // associate image to name
                ofLogError()<<(images[index].isAllocated())<<":"<<name;
                imageMessages[name] = images[index];
                index++;
                // loop around if made more AR images than OF ones
                if ( index >= images.size() ){
                    index = 0;
                }
            }
        }
    }
}

//--------------------------------------------------------------
void ofApp::draw() {
    ofEnableAlphaBlending();
    
    ofDisableDepthTest();
    processor->draw();
    ofEnableDepthTest();
    
    
    if (session.currentFrame){
        if (session.currentFrame.camera){
           
            camera.begin();
            processor->setARCameraMatrices();
            
            for (int i = 0; i < session.currentFrame.anchors.count; i++){
                ARAnchor * anchor = session.currentFrame.anchors[i];
                
                ofPushMatrix();
                ofMatrix4x4 mat = ARCommon::convert<matrix_float4x4, ofMatrix4x4>(anchor.transform);
                ofMultMatrix(mat);
                
                ofSetColor(255);
                ofRotateX(90);
                if([anchor isKindOfClass:[ARImageAnchor class]]) {
                    ARImageAnchor * im = (ARImageAnchor*) anchor;
                    auto w = im.referenceImage.physicalSize.width;
                    auto h = im.referenceImage.physicalSize.height;
                    
                    // get corresponding image
                    // change name to string
                    string str = im.referenceImage.name.UTF8String;
                    ofImage & image = imageMessages[str];
                    image.draw(-w/2., -h/2., w, h);
                }
                
                ofPopMatrix();
            }
          
            camera.end();
        }
        
    }
    ofDisableDepthTest();
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


