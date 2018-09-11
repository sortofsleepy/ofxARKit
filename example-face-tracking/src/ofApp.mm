#include "ofApp.h"
using namespace ofxARKit::common;
//--------------------------------------------------------------
ofApp :: ofApp (ARSession * session){
    ARFaceTrackingConfiguration *configuration = [ARFaceTrackingConfiguration new];
    
    [session runWithConfiguration:configuration];
    
    this->session = session;
}

ofApp::ofApp(){}

//--------------------------------------------------------------
ofApp :: ~ofApp () {
}

vector <ofPrimitiveMode> primModes;
int currentPrimIndex;

//--------------------------------------------------------------
void ofApp::setup() {
    ofBackground(127);
    ofSetFrameRate(60);
    ofEnableDepthTest();

    int fontSize = 8;
    if (ofxiOSGetOFWindow()->isRetinaSupportedOnDevice())
        fontSize *= 2;

    processor = ARProcessor::create(session);
    processor->setup();
    
    ofSetFrameRate(60);
    
    verandaFont.load("fonts/verdana.ttf", 30);
}

//--------------------------------------------------------------
void ofApp::update(){
    processor->update();
    processor->updateFaces();
}

void drawEachTriangle(ofMesh faceMesh) {
    ofPushStyle();
    for (auto face : faceMesh.getUniqueFaces()) {
        ofSetColor(ofColor::fromHsb(ofRandom(255), 255, 255));
        ofDrawTriangle(face.getVertex(0), face.getVertex(1), face.getVertex(2));
    }
    ofPopStyle();
}

void drawFaceCircles(ofMesh faceMesh) {
    ofPushStyle();
    ofSetColor(0, 0, 255);
    auto verts = faceMesh.getVertices();
    for (int i = 0; i < verts.size(); ++i){
        ofDrawCircle(verts[i] * ofVec3f(1, 1, 1), 0.001);
    }
    ofPopStyle();
}

void ofApp::drawFaceMeshNormals(ofMesh mesh) {
    vector<ofMeshFace> faces = mesh.getUniqueFaces();
    ofMeshFace face;
    ofVec3f c, n;
    ofPushStyle();
    ofSetColor(ofColor::white);
    for(unsigned int i = 0; i < faces.size(); i++){
        face = faces[i];
        c = calculateCenter(&face);
        n = face.getFaceNormal();
        ofDrawLine(c.x, c.y, c.z, c.x+n.x*normalSize, c.y+n.y*normalSize, c.z+n.z*normalSize);
    }
    ofPopStyle();
}

void ofApp::printInfo() {
    std::string infoString = std::string("Current mode: ") + std::string(bDrawTriangles ? "mesh triangles" : "circles");
    infoString += "\nNormals: " + std::string(bDrawNormals ? "on" : "off");
    infoString += std::string("\n\nTap right side of the screen to change drawing mode.");
    infoString += "\nTap left side of the screen to toggle normals.";
    verandaFont.drawString(infoString, 10, ofGetHeight() * 0.85);
}

//--------------------------------------------------------------
void ofApp::draw() {
    
    ofDisableDepthTest();
    processor->draw();
    
    camera.begin();
    processor->setARCameraMatrices();

    for (auto & face : processor->getFaces()){
        ofFill();
        ofMatrix4x4 temp = toMat4(face.raw.transform);

        ofPushMatrix();
        ofMultMatrix(temp);
        
        mesh.addVertices(face.vertices);
        mesh.addTexCoords(face.uvs);
        mesh.addIndices(face.indices);
        
        if (bDrawTriangles) {
            drawEachTriangle(mesh);
        } else {
            drawFaceCircles(mesh);
        }
        
        if (bDrawNormals) {
            drawFaceMeshNormals(mesh);
        }

        mesh.clear();
        
        ofPopMatrix();
    }
    camera.end();
    
    printInfo();
}

void ofApp::exit() {}

void ofApp::touchDown(ofTouchEventArgs &touch){
    if (touch.x > ofGetWidth() * 0.5) {
        bDrawTriangles = !bDrawTriangles;
    } else if (touch.x < ofGetWidth() * 0.5) {
        bDrawNormals = !bDrawNormals;
    }
}

void ofApp::touchMoved(ofTouchEventArgs &touch){}

void ofApp::touchUp(ofTouchEventArgs &touch){}

void ofApp::touchDoubleTap(ofTouchEventArgs &touch){}

void ofApp::lostFocus(){}

void ofApp::gotFocus(){}

void ofApp::gotMemoryWarning(){}

void ofApp::deviceOrientationChanged(int newOrientation){
    processor->deviceOrientationChanged(newOrientation);
}

void ofApp::touchCancelled(ofTouchEventArgs& args){}
