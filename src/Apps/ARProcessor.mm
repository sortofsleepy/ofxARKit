//
//  CameraFrameConverter.cpp
//  ARToolkit
//
//  Created by Joseph Chow on 8/4/17.
//

#include "ARProcessor.h"

ARProcessor::ARProcessor(){
}

ARProcessor::ARProcessor(ARSession * session){
    this->session = session;
}

ARProcessor::~ARProcessor(){
    pauseSession();
    session = nullptr;
}

void ARProcessor::pauseSession(){
    [session pause];
}

void ARProcessor::startSession(){
   // ARWorldTrackingSessionConfiguration *configuration = [ARWorldTrackingSessionConfiguration new];
    
}

void ARProcessor::addAnchor(){
   
    
    currentFrame = session.currentFrame;
    
    // Create anchor using the camera's current position
    if (currentFrame) {
        
        // Create a transform with a translation of 0.2 meters in front of the camera
        matrix_float4x4 translation = matrix_identity_float4x4;
        translation.columns[3].z = -0.2;
        matrix_float4x4 transform = matrix_multiply(currentFrame.camera.transform, translation);
        
        // Add a new anchor to the session
        ARAnchor *anchor = [[ARAnchor alloc] initWithTransform:transform];
        [session addAnchor:anchor];
    }
}

void ARProcessor::setup(){
    
    ambientIntensity = 0.0;
    orientation = UIInterfaceOrientationPortrait;
    shouldBuildCameraFrame = true;
    
    // setup plane and shader in order to draw the camera feed
    cameraPlane = ofMesh::plane(ofGetWindowWidth(), ofGetWindowHeight());
    cameraShader.setupShaderFromSource(GL_VERTEX_SHADER, vertex_shader);
    cameraShader.setupShaderFromSource(GL_FRAGMENT_SHADER, fragment_shader);
    cameraShader.linkProgram();
    
    yTexture = NULL;
    CbCrTexture = NULL;
    
    // correct video orientation
    rotation.makeRotationMatrix(-90, ofVec3f(0,0,1));

    
    
    // initialize video texture cache
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, ofxiOSGetGLView().context, NULL, &_videoTextureCache);
    if (err){
        NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
    }
}

CVOpenGLESTextureRef ARProcessor::createTextureFromPixelBuffer(CVPixelBufferRef pixelBuffer,int planeIndex,GLenum format,int width,int height){
    CVOpenGLESTextureRef texture = NULL;
    
    if(width == 0 || height == 0){
        width = (int) CVPixelBufferGetWidth(pixelBuffer);
        height = (int) CVPixelBufferGetHeight(pixelBuffer);
    }
    
    CVReturn err = noErr;
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                      _videoTextureCache,
                                                      pixelBuffer,
                                                      NULL,
                                                      GL_TEXTURE_2D,
                                                      format,
                                                      width,
                                                      height,
                                                      format,
                                                      GL_UNSIGNED_BYTE,
                                                      planeIndex,
                                                      &texture);
    
    if (err != kCVReturnSuccess) {
        CVBufferRelease(texture);
        texture = nil;
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }
    
    return texture;
}

void ARProcessor::draw(){
    cameraShader.begin();
    cameraPlane.draw();
    cameraShader.end();
}

void ARProcessor::drawCameraFrame(){
    draw();
}

void ARProcessor::update(){
    
    // if we haven't set a session - just stop things here. 
    if(!session){
        return;
    }
    
    currentFrame = session.currentFrame;
    
    // update camera transform
    cameraMatrices.cameraTransform = convert<matrix_float4x4,ofMatrix4x4>(currentFrame.camera.transform);
    
    // update camera projection and view matrices.
    getMatricesForOrientation(orientation);
    
    // only act if we have the current frame
    if(currentFrame){
        
        // do light estimates
        if (currentFrame.lightEstimate) {
            ambientIntensity = currentFrame.lightEstimate.ambientIntensity / 1000;
        }
        
        
        // grab current frame pixels from camera
        CVPixelBufferRef pixelBuffer = currentFrame.capturedImage;
        
        
        // if we have both planes from the camera, build the camera frame
        // in case we want to view it.
        if(shouldBuildCameraFrame){
            if (CVPixelBufferGetPlaneCount(pixelBuffer) >= 2) {
                buildCameraFrame(pixelBuffer);
            }
        }
    
    }
    
    // Periodic texture cache flush every frame
    CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
}

void ARProcessor::updatePlanes(){
    if(currentFrame){
        
    }
}

void ARProcessor::buildCameraFrame(CVPixelBufferRef pixelBuffer){
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    
    // ========= RELEASE DATA PREVIOUSLY HELD ================= //
    
    CVBufferRelease(yTexture);
    CVBufferRelease(CbCrTexture);
    
    
    // ========= ROTATE IMAGES ================= //
    
    cameraShader.begin();
    cameraShader.setUniformMatrix4f("rotationMatrix", rotation);
    cameraShader.end();
    
    // ========= BUILD CAMERA TEXTURES ================= //
    yTexture = createTextureFromPixelBuffer(pixelBuffer, 0);
    
    int width = (int) CVPixelBufferGetWidth(pixelBuffer);
    int height = (int) CVPixelBufferGetHeight(pixelBuffer);
    
    CbCrTexture = createTextureFromPixelBuffer(pixelBuffer, 1,GL_LUMINANCE_ALPHA,width / 2, height / 2);
    
    
    // correct texture wrap and filtering of Y texture
    glBindTexture(CVOpenGLESTextureGetTarget(yTexture), CVOpenGLESTextureGetName(yTexture));
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    //glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    //glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glBindTexture(CVOpenGLESTextureGetTarget(yTexture), 0);
    
    
    // correct texture wrap and filtering of CbCr texture
    glBindTexture(CVOpenGLESTextureGetTarget(CbCrTexture), CVOpenGLESTextureGetName(CbCrTexture));
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    //glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    //glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    
    glBindTexture(CVOpenGLESTextureGetTarget(CbCrTexture), 0);
    
    
    
    
    
    // write uniforms values to shader
    cameraShader.begin();
    cameraShader.setUniform2f("resolution", ofGetWindowWidth(), ofGetWindowHeight());
    cameraShader.setUniformTexture("yMap", CVOpenGLESTextureGetTarget(yTexture), CVOpenGLESTextureGetName(yTexture), 0);
    
    cameraShader.setUniformTexture("uvMap", CVOpenGLESTextureGetTarget(CbCrTexture), CVOpenGLESTextureGetName(CbCrTexture), 1);
    
    cameraShader.end();
    
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    
}

void ARProcessor::setARCameraMatrices(){
    ofSetMatrixMode(OF_MATRIX_PROJECTION);
    ofLoadMatrix(cameraMatrices.cameraProjection);
    ofSetMatrixMode(OF_MATRIX_MODELVIEW);
    ofLoadMatrix(cameraMatrices.cameraView);           
}


float ARProcessor::getAmbientIntensity(){
    return ambientIntensity;
}

 ARCameraMatrices ARProcessor::getMatricesForOrientation(UIInterfaceOrientation orientation,float near, float far){
   
     CGSize _viewportSize = CGSizeMake(ofGetWindowWidth(), ofGetWindowHeight());
     
    cameraMatrices.cameraView = convert<matrix_float4x4,ofMatrix4x4>([session.currentFrame.camera viewMatrixForOrientation:orientation]);
     
     cameraMatrices.cameraProjection = convert<matrix_float4x4,ofMatrix4x4>([session.currentFrame.camera projectionMatrixWithViewportSize:_viewportSize orientation:orientation zNear:near zFar:far]);
     
    
    return cameraMatrices;
 }
