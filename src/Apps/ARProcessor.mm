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
    sessionSet = true;
}

void ARProcessor::setup(){
    
    ambientIntensity = 0.0;
    sessionSet = false;
    
    // setup plane and shader in order to draw the camera feed
    cameraPlane = ofMesh::plane(ofGetWindowWidth(), ofGetWindowHeight());
    cameraShader.load("shaders/camera.vert","shaders/camera.frag");
    
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

CVOpenGLESTextureRef ARProcessor::createTextureFromPixelBuffer(CVPixelBufferRef pixelBuffer,int planeIndex){
    CVOpenGLESTextureRef texture = NULL;
    
    const size_t width = CVPixelBufferGetWidthOfPlane(pixelBuffer, planeIndex);
    const size_t height = CVPixelBufferGetHeightOfPlane(pixelBuffer, planeIndex);
    
    CVReturn err = noErr;
    err =CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                      _videoTextureCache,
                                                      pixelBuffer,
                                                      NULL,
                                                      GL_TEXTURE_2D,
                                                      GL_LUMINANCE,
                                                      width,
                                                      height,
                                                      GL_LUMINANCE,
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
    
    ARFrame * currentFrame = session.currentFrame;
    
    // only act if we have the current frame
    if(currentFrame){
        
        
        // do light estimates
        if (currentFrame.lightEstimate) {
            ambientIntensity = currentFrame.lightEstimate.ambientIntensity / 1000;
        }
        // Create two textures (Y and CbCr) from the provided frame's captured image
        CVPixelBufferRef pixelBuffer = currentFrame.capturedImage;
        
        
        if (CVPixelBufferGetPlaneCount(pixelBuffer) >= 2) {
            
            // ========= RELEASE DATA PREVIOUSLY HELD ================= //
            CVPixelBufferLockBaseAddress(pixelBuffer, 0);
            CVBufferRelease(yTexture);
            CVBufferRelease(CbCrTexture);
            
            
            // ========= ROTATE IMAGES ================= //
  
            cameraShader.begin();
            cameraShader.setUniformMatrix4f("rotationMatrix", rotation);
            cameraShader.end();
            
            // ========= BUILD CAMERA TEXTURES ================= //
            yTexture = createTextureFromPixelBuffer(pixelBuffer, 0);
            CbCrTexture = createTextureFromPixelBuffer(pixelBuffer, 1);
            
            
            // correct texture wrap and filtering of Y texture
            glBindTexture(CVOpenGLESTextureGetTarget(yTexture), CVOpenGLESTextureGetName(yTexture));
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,GL_LINEAR);
            glBindTexture(CVOpenGLESTextureGetTarget(yTexture), 0);
            
            
            // correct texture wrap and filtering of CbCr texture
            glBindTexture(CVOpenGLESTextureGetTarget(CbCrTexture), CVOpenGLESTextureGetName(CbCrTexture));
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,GL_LINEAR);
            
            glBindTexture(CVOpenGLESTextureGetTarget(CbCrTexture), 0);
            
            
            
            
            
            // write uniforms values to shader
            cameraShader.begin();
            cameraShader.setUniform2f("resolution", ofGetWindowWidth(), ofGetWindowHeight());
            cameraShader.setUniformTexture("yMap", CVOpenGLESTextureGetTarget(yTexture), CVOpenGLESTextureGetName(yTexture), 0);
            
            cameraShader.setUniformTexture("uvMap", CVOpenGLESTextureGetTarget(CbCrTexture), CVOpenGLESTextureGetName(CbCrTexture), 1);
            
            cameraShader.end();
            
            
            CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        }
        
        
        
        
    }
    
    // Periodic texture cache flush every frame
    CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
}

