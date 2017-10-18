//
//  ARAnchorManager.cpp
//
//  Created by Joseph Chow on 8/18/17.
//

#include "ARAnchorManager.h"
using namespace std;
using namespace ARCommon;

namespace ARCore {
    
    ARAnchorManager::ARAnchorManager():shouldUpdatePlanes(false){
        
    }
    
    ARAnchorManager::ARAnchorManager(ARSession * session):shouldUpdatePlanes(false){
        this->session = session;
        
    }
    
    int ARAnchorManager::getNumPlanes(){
        return planes.size();
    }
    
    PlaneAnchorObject ARAnchorManager::getPlaneAt(int index){
        return planes.at(index);
    }
    
    void ARAnchorManager::addAnchor(float zZoom){
        
        
        ARFrame * currentFrame = session.currentFrame;
        
        // Create anchor using the camera's current position
        if (currentFrame) {
            
            // Create a transform with a translation of 0.2 meters in front of the camera
            matrix_float4x4 translation = matrix_identity_float4x4;
            
            translation.columns[3].z = zZoom;
            
            matrix_float4x4 transform = matrix_multiply(currentFrame.camera.transform, translation);
            
            // Add a new anchor to the session
            ARAnchor *anchor = [[ARAnchor alloc] initWithTransform:transform];
            
            
            anchors.push_back(buildARObject(anchor, toMat4(transform)));
            
            [session addAnchor:anchor];
        }
    }
    
    // TODO this still needs a bit of work but it's good enough for the time being.
    void ARAnchorManager::addAnchor(ofVec3f position){
        
        // set a default z if position.z is 0 so we can see the object. ;
        if(position.z == 0){
            position.z = -0.2;
        }
        
        if(session.currentFrame){
            
            // convert screen to world coordinates based on viewport.
            // we're just guessing on the Z pos based on sample code from Xcode.
            ofVec3f pos = camera.screenToWorld(ofVec3f(position.x,position.y,-0.2),ofRectangle(0,0,ofGetWindowWidth(),ofGetWindowHeight()));
            
            
            // Create a transform with a translation of 0.2 meters in front of the camera
            matrix_float4x4 translation = matrix_identity_float4x4;
            translation.columns[2].z = -1.0;
            
            // x is actually refering to y - multiply by -1 to flip position
            translation.columns[3].x = (pos.y * -1) * 0.01;
            
            // y is actually refering to x
            translation.columns[3].y = pos.x * 0.01;
            
            // set z
            translation.columns[3].z = position.z;
            
            // multiply translation by current camera position
            matrix_float4x4 transform = matrix_multiply(session.currentFrame.camera.transform, translation);
            
            // Add a new anchor to the session
            ARAnchor *anchor = [[ARAnchor alloc] initWithTransform:transform];
            
            // add ARObject
            anchors.push_back(buildARObject(anchor, toMat4(transform)));
            
            // add anchor to ARKit
            [session addAnchor:anchor];
            
        }
        
    }
    
    void ARAnchorManager::addAnchor(ARObject anchor){
        // add ARObject
        anchors.push_back(anchor);
        
        // add anchor to ARKit
        [session addAnchor:anchor.rawAnchor];
    }
    
    void ARAnchorManager::loopAnchors(std::function<void(ARObject)> func){
        
        for (int i = 0; i < anchors.size(); i++) {
            func(anchors[i]);
        }
        
    }
    
    void ARAnchorManager::loopAnchors(std::function<void(ARObject,int index)> func){
        
        for (int i = 0; i < anchors.size(); i++) {
            func(anchors[i],i);
        }
        
    }
    
    void ARAnchorManager::loopPlaneAnchors(std::function<void(PlaneAnchorObject)> func){
        for (int i = 0; i < planes.size(); i++) {
            func(planes[i]);
        }
    }
    
    void ARAnchorManager::loopPlaneAnchors(std::function<void(PlaneAnchorObject,int index)> func){
        for (int i = 0; i < planes.size(); i++) {
            func(planes[i],i);
        }
    }
    
    
    
    void ARAnchorManager::update(){
        
        // update number of anchors currently tracked
        anchorInstanceCount = session.currentFrame.anchors.count;
     
    }
    
    void ARAnchorManager::updatePlanes(){
        // update any anchors found in the current frame by the system
        for (NSInteger index = 0; index < anchorInstanceCount; index++) {
            ARAnchor *anchor = session.currentFrame.anchors[index];
            
            // did we find a PlaneAnchor?
            // note - you need to turn on planeDetection in your configuration
            if([anchor isKindOfClass:[ARPlaneAnchor class]]){
                ARPlaneAnchor* pa = (ARPlaneAnchor*) anchor;
                
                // calc values from anchor.
                ofMatrix4x4 paTransform = convert<matrix_float4x4, ofMatrix4x4>(pa.transform);
                ofVec3f center = convert<vector_float3,ofVec3f>(pa.center);
                ofVec3f extent = convert<vector_float3,ofVec3f>(pa.extent);
                
                
                // neat trick to search in vector with c++ 11, seems to work better than for loop
                // https://stackoverflow.com/questions/15517991/search-a-vector-of-objects-by-object-attribute
                auto it = find_if(planes.begin(), planes.end(), [=](const PlaneAnchorObject& obj) {
                    return obj.uuid == anchor.identifier;
                });

                // if it == planes.end() - means an item was not found.
                if(it == planes.end()){
                    PlaneAnchorObject plane;
                    
                    plane.transform = paTransform;
                    plane.position.x = -extent.x / 2;
                    plane.position.y = -extent.y / 2;
                    plane.width = extent.x;
                    plane.height = extent.z;
                    plane.uuid = anchor.identifier;
                    plane.rawAnchor = pa;
                    
                    planes.push_back(plane);
                }
                
                // means item is found, check to see if we need to update
                if(it != planes.end()){
                    if(shouldUpdatePlanes){

                        planes[index].transform = paTransform;
                        
                        planes[index].position.x = -extent.x / 2;
                        planes[index].position.y = -extent.y / 2;
                        planes[index].width = extent.x;
                        planes[index].height = extent.z;
                        planes[index].uuid = anchor.identifier;
                        planes[index].rawAnchor = pa;
                    }
                }
                
            }
            
        }
    }
    
    void ARAnchorManager::clearAnchors(){
        // clear all anchors from ARKit session.
        for(int i = 0; i < anchors.size();++i){
            [session removeAnchor:anchors[i].rawAnchor];
        }
        
        // ensure any auto-added anchors are cleared
        for(NSInteger i = 0; i < anchorInstanceCount; i++){
            ARAnchor *anchor = session.currentFrame.anchors[i];
            [session removeAnchor:anchor];
        }
        
        // finally, clear vector
        anchors.clear();
    }
    
    void ARAnchorManager::removeAnchor(NSUUID * anchorId){
        for(int i = 0; i < anchors.size();++i){
            if(anchors[i].rawAnchor.identifier == anchorId){
                anchors.erase(anchors.begin() + i);
                [session removeAnchor:anchors[i].rawAnchor];
            }
        }
    }
    
    void ARAnchorManager::removeAnchor(int index){
        anchors.erase(anchors.begin() + index);
        [session removeAnchor:anchors[index].rawAnchor];
    }
    void ARAnchorManager::clearPlaneAnchors(){
        // clear all anchors from ARKit session.
        for(int i = 0; i < planes.size();++i){
            [session removeAnchor:planes[i].rawAnchor];
        }
        
        // finally, clear vector
        planes.clear();
    }
    void ARAnchorManager::removePlane(NSUUID * anchorId){
        for(int i = 0; i < planes.size();++i){
            if(planes[i].rawAnchor.identifier == anchorId){
                planes.erase(planes.begin() + i);
                [session removeAnchor:planes[i].rawAnchor];
            }
        }
    }
    void ARAnchorManager::removePlane(int index){
        planes.erase(planes.begin() + index);
        [session removeAnchor:planes[index].rawAnchor];
    }
    
    void ARAnchorManager::removeAnchorDirectly(int index){
        ARAnchor *anchor = session.currentFrame.anchors[index];
        [session removeAnchor:anchor];
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
            ofSetColor(102,216,254,100);
            ofRotateX(90);
            ofTranslate(anchor.position.x,anchor.position.y);
            ofDrawRectangle(-anchor.position.x/2,-anchor.position.z/2,0,anchor.width,anchor.height);
            ofSetColor(255);
            ofPopMatrix();
            
        }
        
        camera.end();
    }
    

}
