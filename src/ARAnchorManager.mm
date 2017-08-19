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

void ARAnchorManager::update(){
    
    // clear previously found planes to prepare for potential new ones.
    planes.clear();
    
    anchorInstanceCount = session.currentFrame.anchors.count;
    // update any anchors found in the current frame
    for (NSInteger index = 0; index < anchorInstanceCount; index++) {
        ARAnchor *anchor = session.currentFrame.anchors[index];
        
        // did we find a PlaneAnchor?
        // note - you need to turn on planeDetection in your configuration
        if([anchor isKindOfClass:[ARPlaneAnchor class]]){
            ARPlaneAnchor* pa = (ARPlaneAnchor*) anchor;
            PlaneAnchorObject plane;
            
            // see https://github.com/sortofsleepy/ofxARKit/issues/6
            plane.transform = convert<matrix_float4x4, ofMatrix4x4>(anchor.transform);
            ofVec3f center = convert<vector_float3,ofVec3f>(pa.center);
            ofVec3f extent = convert<vector_float3,ofVec3f>(pa.extent);
            
            plane.position.x = -extent.x / 2;
            plane.position.y = -extent.y / 2;
            plane.width = extent.x;
            plane.height = extent.z;
            
            planes.push_back(plane);
            
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
