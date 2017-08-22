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
        

        anchors.push_back(buildARObject(anchor, toMat4(transform)));
        [session addAnchor:anchor];
    }
}

void ARAnchorManager::addAnchor(ofVec2f position){
    ARFrame * currentFrame = session.currentFrame;
    
   
    if(currentFrame){
        matrix_float4x4 translation = matrix_identity_float4x4;
        
        // translate back a bit.
        translation.columns[3].z = -0.2;
        
         // Flip Z axis to convert geometry from right handed to left handed
        translation.columns[2].z = -1.0;
        
        matrix_float4x4 transform = matrix_multiply(currentFrame.camera.transform, translation);
        
        // build a new transform matrix
        ofMatrix4x4 mat = ARCommon::toMat4(transform);
        
        // translate it by the specified amount.
        mat.translate(ofVec3f(position.x,position.y,0));
        
        ARAnchor * anchor = [[ARAnchor alloc] initWithTransform:convert<ofMatrix4x4,matrix_float4x4>(mat)];
        
        ARObject obj;
        obj.modelMatrix = mat;
        obj.rawAnchor = anchor;
        
        anchors.push_back(obj);
        
        // add anchor to ARKit.
        [session addAnchor:anchor];
    }
    
}

void ARAnchorManager::loopAnchors(std::function<void(ARObject)> func){
    for (int i = 0; i < anchors.size(); i++) {
        func(anchors[i]);
    }
}

// TODO - how do we account for ARKit found anchors better. Seems like a cpu waste to continuously
// loop through currently tracked anchors for matching uuids.
void ARAnchorManager::update(){
    
    // clear previously found planes to prepare for potential new ones.
    planes.clear();
    
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
            
            // account for ARAnchor objects that may have been found by ARKit itself and not manually added.
            // we need to be able to track that too.
            // TODO is there a better way to do this?
            for(int i = 0; i < anchors.size();++i){
                if(anchors[i].rawAnchor.identifier != anchor.identifier){
                    
                    matrix_float4x4 coordinateSpaceTransform = matrix_identity_float4x4;
                    coordinateSpaceTransform.columns[2].z = -1.0;
                    matrix_float4x4 newMat = matrix_multiply(anchor.transform, coordinateSpaceTransform);
                    ofMatrix4x4 m = ARCommon::toMat4(newMat);
                    
                    anchors.push_back(buildARObject(anchor, m, true));
                    
                }
            }
            
            
            // Flip Z axis to convert geometry from right handed to left handed
            //matrix_float4x4 coordinateSpaceTransform = matrix_identity_float4x4;
            //coordinateSpaceTransform.columns[2].z = -1.0;
            
            //matrix_float4x4 newMat = matrix_multiply(anchor.transform, coordinateSpaceTransform);
            //ofMatrix4x4 m = ARCommon::toMat4(newMat);
            //ofLog()<<m;
            //anchors.push_back(m);
        }
        
    }
}

void ARAnchorManager::clearAnchors(){
    // clear all anchors from ARKit session.
    for(int i = 0; i < anchors.size();++i){
        [session removeAnchor:anchors[i].rawAnchor];
    }
    
    // finally, clear vector
    anchors.clear();
}

void ARAnchorManager::removeAnchor(NSUUID * anchorId){
    for(int i = 0; i < anchors.size();++i){
        if(anchors[i].rawAnchor.identifier == anchorId){
            [session removeAnchor:anchors[i].rawAnchor];
        }
    }
}

void ARAnchorManager::removeAnchor(int index){
    [session removeAnchor:anchors[index].rawAnchor];
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

ARObject ARAnchorManager::buildARObject(ARAnchor * rawAnchor,ofMatrix4x4 modelMatrix,bool systemAdded){
    ARObject obj;
    obj.rawAnchor = rawAnchor;
    obj.modelMatrix = modelMatrix;
    obj.systemAdded = systemAdded;
    
    return obj;
}
