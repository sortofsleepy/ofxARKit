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
void ofApp::setup(){
    
    camera = new ofxARKit::core::MetalCamRenderer();
    camera->setup(
                  session,
                  CGRectMake(0, 0, ofGetWindowWidth(), ofGetWindowHeight()),
                  ofxiOSGetGLView().context
                  );
    
    
    mesh = ofMesh::plane(ofGetWindowWidth(), ofGetWindowHeight());
    shader.setupShaderFromSource(GL_VERTEX_SHADER, vertex);
    shader.setupShaderFromSource(GL_FRAGMENT_SHADER, fragment);
    
    shader.linkProgram();
    
    //glBindTexture(CVOpenGLESTextureGetTarget(tex), CVOpenGLESTextureGetName(tex));
}

//--------------------------------------------------------------
void ofApp::update(){
    
    //[camera draw];
    camera->draw();
    
    
}

//--------------------------------------------------------------
void ofApp::draw(){
    
    auto _tex = camera->getTexture();
    
    if(_tex){
        shader.begin();
        
        //shader.setUniformTexture("tex",GL_TEXTURE_2D,_openglTex,0);
        shader.setUniformTexture("tex", CVOpenGLESTextureGetTarget(_tex), CVOpenGLESTextureGetName(_tex), 0);
        mesh.draw();
        
        shader.end();
    }
}

//--------------------------------------------------------------
void ofApp::exit(){
    
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
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
