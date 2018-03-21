//
//  ARAnchorManager.cpp
//
//  Created by Joseph Chow on 8/18/17.
//

#include "ARAnchorManager.h"
using namespace std;
using namespace ARCommon;

namespace ARCore {

    ARAnchorManager::ARAnchorManager():
    shouldUpdatePlanes(false),
    maxTrackedPlanes(0){
        _onPlaneAdded = nullptr;
    }

    ARAnchorManager::ARAnchorManager(ARSession * session):
    shouldUpdatePlanes(false),
    maxTrackedPlanes(0){
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
    // Note that z position should still be considered in meters(anyone know of what ARKit defines as 1 meter by chance?)
    void ARAnchorManager::addAnchor(ofVec3f position,ofMatrix4x4 projection,ofMatrix4x4 viewMatrix){

        if(session.currentFrame){

            ofVec4f pos = ARCommon::screenToWorld(position, projection, viewMatrix);

            // build matrix for the anchor
            matrix_float4x4 translation = matrix_identity_float4x4;

            translation.columns[3].x = pos.x;
            translation.columns[3].y = pos.y;
            translation.columns[3].z = position.z;

            matrix_float4x4 transform = matrix_multiply(session.currentFrame.camera.transform, translation);

            // Add a new anchor to the session
            ARAnchor *anchor = [[ARAnchor alloc] initWithTransform:transform];

            anchors.push_back(buildARObject(anchor, toMat4(transform)));

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

        // if we aren't tracking the maximum number of planes or we want to track all possible planes,
        // run the for loop.
        if(getNumPlanes() < maxTrackedPlanes || maxTrackedPlanes == 0){
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

                    // if it == planes.end() - it means we aren't tracking this plane just yet.
                    // if that's the case, then add it.
                    if(it == planes.end()){

                        PlaneAnchorObject plane;

                        plane.transform = paTransform;
                        plane.position.x = -extent.x / 2;
                        plane.position.y = -extent.y / 2;
                        plane.width = extent.x;
                        plane.height = extent.z;
                        plane.uuid = anchor.identifier;
                        plane.rawAnchor = pa;

                        if(_onPlaneAdded != nullptr){
                            _onPlaneAdded(plane);
                        }

                        planes.push_back(plane);
                    }

                    // this block triggers when a plane we're already tracking is found,
                    // check to see if we need to update and update if need be
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
    }

#if AR_FACE_TRACKING
    void ARAnchorManager::updateFaces(){
        for (NSInteger index = 0; index < anchorInstanceCount; index++) {
            ARAnchor *anchor = session.currentFrame.anchors[index];

            if([anchor isKindOfClass:[ARFaceAnchor class]]){
                ARFaceAnchor * pa = (ARFaceAnchor*) anchor;
                ARFaceGeometry * geo = pa.geometry;

                // indices are const int16_t
                // vertices are const vector_float3
                // uvs are const vector_float2
                // counts are all NSIntegers
                auto it = find_if(faces.begin(), faces.end(), [=](const FaceAnchorObject& obj) {
                    return obj.uuid == anchor.identifier;
                });

                // if we haven't found a face
                if(it == faces.end()){
                    FaceAnchorObject face;
                    face.vertexCount = geo.vertexCount;
                    face.triangleCount = geo.triangleCount;

                    // transform vertices and uvs
                    for(NSInteger i = 0; i < geo.vertexCount; ++i){
                        vector_float3 vert = geo.vertices[i];
                        vector_float2 uv = geo.textureCoordinates[i];


                        face.vertices.push_back(convert<vector_float3, ofVec3f>(vert));
                        face.uvs.push_back(convert<vector_float2, ofVec2f>(uv));
                    }

                    // set indices
                    auto indices = geo.triangleIndices;

                   for(NSInteger i = 0; i < geo.triangleCount*3; ++i){
                       int16_t ii = indices[i];
                       face.indices.push_back((int)ii);

                   }

                    // store reference to raw anchor
                    face.raw = pa;

                    // store uuid
                    face.uuid = pa.identifier;

                    // push back new face
                    faces.push_back(face);

                }

                // this block triggers when a face we're already tracking is found,
                if(it != faces.end()){
                    faces[index].raw = pa;
                    faces[index].vertices.clear();
                    faces[index].uvs.clear();
                    faces[index].indices.clear();

                    // transform vertices and uvs
                    for(NSInteger i = 0; i < geo.vertexCount; ++i){
                        vector_float3 vert = geo.vertices[i];
                        vector_float2 uv = geo.textureCoordinates[i];


                        faces[index].vertices.push_back(convert<vector_float3, ofVec3f>(vert));
                        faces[index].uvs.push_back(convert<vector_float2, ofVec2f>(uv));
                    }

                    // set indices
                    faces[index].indices.clear();
                    for(NSInteger i = 0; i < geo.triangleCount*3; ++i){
                        int16_t ii = geo.triangleIndices[i];
                        faces[index].indices.push_back((int)ii);
                    }
                }

            }
        }
    }
#endif

    void ARAnchorManager::setNumberOfPlanesToTrack(int num){
        maxTrackedPlanes = num;
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

    void ARAnchorManager::drawPlaneAt(ARCameraMatrices cameraMatrices,int index){
        camera.begin();

        ofSetMatrixMode(OF_MATRIX_PROJECTION);
        ofLoadMatrix(cameraMatrices.cameraProjection);
        ofSetMatrixMode(OF_MATRIX_MODELVIEW);
        ofLoadMatrix(cameraMatrices.cameraView);

        PlaneAnchorObject anchor = getPlaneAt(index);

        ofPushMatrix();
        ofMultMatrix(anchor.transform);
        ofFill();
        ofSetColor(102,216,254,100);
        ofRotateX(90);
        ofTranslate(anchor.position.x,anchor.position.y);
        ofDrawRectangle(-anchor.position.x/2,-anchor.position.z/2,0,anchor.width,anchor.height);
        ofSetColor(255);
        ofPopMatrix();

        camera.end();
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

    void ARAnchorManager::onPlaneAdded(std::function<void(PlaneAnchorObject plane)> func){
        _onPlaneAdded = func;
    }


}
