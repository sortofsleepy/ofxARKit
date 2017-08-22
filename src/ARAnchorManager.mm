//
//  ARAnchorManager.cpp
//  GeoBeats
//
//  Created by Joseph Chow on 8/18/17.
//

#include "ARAnchorManager.h"
using namespace std;
using namespace ARCommon;

ARAnchorManager::ARAnchorManager(){}

ARAnchorManager::ARAnchorManager(ARSession * session){
    this->session = session;
}

int ARAnchorManager::getNumPlanes(){
    return planes.size();
}

PlaneAnchorObject ARAnchorManager::getPlaneAt(int index){
    return planes.at(index);
}

void ARAnchorManager::addAnchor(){
    
    ARFrame * currentFrame = session.currentFrame;
    
    // Create anchor using the camera's current position
    if (currentFrame) {
        
        // Create a transform with a translation of 0.2 meters in front of the camera
        matrix_float4x4 translation = matrix_identity_float4x4;
        translation.columns[3].z = -0.2;
        matrix_float4x4 transform = matrix_multiply(currentFrame.camera.transform, translation);
        
        // Add a new anchor to the session
        ARAnchor *anchor = [[ARAnchor alloc] initWithTransform:transform];
        anchors.push_back(ARCommon::toMat4(transform));
        [session addAnchor:anchor];
    }
}

void ARAnchorManager::addAnchor(ofVec2f position){
    ARFrame * currentFrame = session.currentFrame;
    
   
    if(currentFrame){
        matrix_float4x4 translation = matrix_identity_float4x4;
        translation.columns[3].z = -0.2;
        matrix_float4x4 transform = matrix_multiply(currentFrame.camera.transform, translation);
        
        ofMatrix4x4 mat = ARCommon::toMat4(transform);
        mat.translate(ofVec3f(position.x,position.y,0));
        ARAnchor *anchor = [[ARAnchor alloc] initWithTransform:transform];
        ofLog()<<mat;
        anchors.push_back(mat);
        [session addAnchor:anchor];
    }
    
}

void ARAnchorManager::loopAnchors(std::function<void(ofMatrix4x4)> func){
    for (int i = 0; i < anchors.size(); i++) {
        func(anchors[i]);
    }
}

void ARAnchorManager::update(){
    
    // clear previously found planes to prepare for potential new ones.
    planes.clear();
    anchors.clear();
    
    // update number of anchors currently tracked
    anchorInstanceCount = session.currentFrame.anchors.count;
   
    // update any anchors found in the current frame by the system
    for (NSInteger index = 0; index < anchorInstanceCount; index++) {
        ARAnchor *anchor = session.currentFrame.anchors[index];
        
        // did we find a PlaneAnchor?
        // note - you need to turn on planeDetection in your configuration
        if([anchor isKindOfClass:[ARPlaneAnchor class]]){
            ARPlaneAnchor* pa = (ARPlaneAnchor*) anchor;
            PlaneAnchorObject plane;
            
            // see https://github.com/sortofsleepy/ofxARKit/issues/6
            // thanks to @stc
            plane.transform = convert<matrix_float4x4, ofMatrix4x4>(anchor.transform);
            ofVec3f center = convert<vector_float3,ofVec3f>(pa.center);
            ofVec3f extent = convert<vector_float3,ofVec3f>(pa.extent);
            
            plane.position.x = -extent.x / 2;
            plane.position.y = -extent.y / 2;
            plane.width = extent.x;
            plane.height = extent.z;
            
            planes.push_back(plane);
            
        }else {
            
            // Flip Z axis to convert geometry from right handed to left handed
            matrix_float4x4 coordinateSpaceTransform = matrix_identity_float4x4;
            coordinateSpaceTransform.columns[2].z = -1.0;
            
            matrix_float4x4 newMat = matrix_multiply(anchor.transform, coordinateSpaceTransform);
            
            anchors.push_back(ARCommon::toMat4(newMat));
        }
        
    }
}

void ARAnchorManager::drawPlanes(ARCameraMatrices cameraMatrices){
    camera.begin();
    
    ofSetMatrixMode(OF_MATRIX_PROJECTION);
    ofLoadMatrix(cameraMatrices.cameraProjection);
    ofSetMatrixMode(OF_MATRIX_MODELVIEW);
    ofLoadMatrix(cameraMatrices.cameraView);
    
   
    for(int i = 0; i < getNumPlanes(); ++i){
        PlaneAnchorObject anchor = getPlaneAt(i);

        
        ofPushMatrix();
        ofMultMatrix(anchor.transform);
        ofFill();
        ofSetColor(255);
        ofRotateX(90);
        ofTranslate(anchor.position.x,anchor.position.y);
        ofDrawRectangle(-anchor.position.x/2,-anchor.position.z/2,0,anchor.width,anchor.height);
        ofPopMatrix();
        
    }
    
    camera.end();
}
