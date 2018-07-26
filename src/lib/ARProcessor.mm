//
//  CameraFrameConverter.cpp
//  ARToolkit
//
//  Created by Joseph Chow on 8/4/17.
//

#include "ARProcessor.h"
using namespace ARCommon;
using namespace ARCore;

ARProcessor::ARProcessor(ARSession * session){
    this->session = session;
    
    debugInfo = ARDebugUtils::ARDebugInfo(session);
}

ARProcessor::~ARProcessor(){
    pauseSession();
    session = nullptr;
    
    // remove this instance of the ARCam - if there are other ARCams around, they will still be in memory
    camera.reset();
    anchorController.reset();
}

void ARProcessor::toggleDebug(){
    debugMode = !debugMode;
}

void ARProcessor::pauseSession(){
      [session pause];
}

void ARProcessor::logTrackingState(){
    camera->logTrackingState();
}

void ARProcessor::restartSession(){
    // note - I don't know if this actually works once a session has been
    // stopped, may have to recreate session.
    [session runWithConfiguration:session.configuration];
}

void ARProcessor::setup(bool debugMode){
    this->debugMode = debugMode;
    anchorController = ARAnchorManager::create(session);
    camera = ARCam::create(session);
    camera->setup(this->debugMode);
}

void ARProcessor::draw(){
    camera->draw();
}

void ARProcessor::update(){
    camera->update();
    if(debugMode){
        pointCloud.updatePointCloud(session.currentFrame);
    }
    
    anchorController->update();
    
}

void ARProcessor::updatePlanes(){
    anchorController->updatePlanes();
}

void ARProcessor::updateImages(){
    anchorController->updateImageAnchors();
}

void ARProcessor::drawFrame(){
    draw();
}
// =========== CAMERA API ============ //
void ARProcessor::forceInterfaceOrientation(UIInterfaceOrientation orientation){
    camera->setInterfaceOrientation(orientation);
}
void ARProcessor::setARCameraMatrices(){
    camera->setARCameraMatrices();
}

ofVec3f ARProcessor::getCameraPosition(){
    return ARCommon::getAnchorXYZ(camera->getTransformMatrix());
}

ofTexture ARProcessor::getCameraTexture(){
   return camera->getCameraTexture();
}

ARCommon::ARCameraMatrices ARProcessor::getCameraMatrices(){
     return camera->getCameraMatrices();
}

float ARProcessor::getLightIntensity(){
    return camera->getAmbientIntensity();
}

ARTrackingState ARProcessor::getTrackingState(){
    return camera->getTrackingState();
}

void ARProcessor::rotateCameraFrame(float angle){
    camera->updateRotationMatrix(angle);
}

void ARProcessor::updateDeviceInterfaceOrientation(){
    camera->updateInterfaceOrientation();
}

ARCameraMatrices ARProcessor::getMatricesForOrientation(UIInterfaceOrientation orientation,float near, float far){
    return camera->getMatricesForOrientation(orientation,near,far);
}


void ARProcessor::deviceOrientationChanged(){
    camera->updateDeviceOrientation();
}

// ======= ANCHOR API ========= //
void ARProcessor::addAnchor(float zZoom){
    anchorController->addAnchor(zZoom);
}

void ARProcessor::addAnchor(ofVec3f position){
    auto matrices = getCameraMatrices();
 
    ofMatrix4x4 model = toMat4(session.currentFrame.camera.transform);
    anchorController->addAnchor(position,matrices.cameraProjection,model * getCameraMatrices().cameraView);
}
//! Draws the current set of planes
void ARProcessor::drawPlanes(){
    anchorController->drawPlanes(camera->getCameraMatrices());
}

//! Draws the current set of plane meshes
//! TODO - who made this example again? Not sure what should go here - Joe
void ARProcessor::drawPlaneMeshes(){}


void ARProcessor::drawHorizontalPlanes(){
    anchorController->drawPlanes(camera->getCameraMatrices());
}

#if AR_FACE_TRACKING
// ======= FACE API ========= //
std::vector<FaceAnchorObject> ARProcessor::getFaces(){
    return anchorController->getFaces();
}
void ARProcessor::updateFaces(){
    anchorController->updateFaces();
}
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_3
vector<ARReferenceImage *> & ARProcessor::getARReferenceImages(){
    if ( arRefImages.empty() ){
        ARConfiguration * config = session.configuration;
        if([config isKindOfClass:[ARWorldTrackingConfiguration class]]){
            ARWorldTrackingConfiguration * wConfig = (ARWorldTrackingConfiguration*) session.configuration;
            
            NSSet<ARReferenceImage *> * images = wConfig.detectionImages;
            for(ARReferenceImage * img in images) {
                arRefImages.push_back( img );
            }
        }
    }
    
    return arRefImages;
}
#endif
// ======== DEBUG API =========== //

void ARProcessor::drawPointCloud(){
    if(debugMode){
        pointCloud.draw(camera->getProjectionMatrix(), camera->getViewMatrix());
    } else {
        ofLog(OF_LOG_WARNING, "Debug Mode not set");
    }
}
