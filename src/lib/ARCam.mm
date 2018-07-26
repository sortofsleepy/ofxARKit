//
//  ARCam.cpp
//
//  Created by Joseph Chow on 8/29/17.
//

#include "ARCam.h"
#include "ofxiOS.h"
using namespace std;
using namespace ARCommon;

namespace ARCore {
    ARCam::ARCam(ARSession * session){
        this->session = session;
    }
    
    void ARCam::toggleDebug(){
        debugMode = !debugMode;
    }
    
    void ARCam::setup(bool debugMode){
        nativeDimensions = ARCommon::getDeviceDimensions(true);
        ambientIntensity = 0.0;
        orientation = UIInterfaceOrientationPortrait;
        shouldBuildCameraFrame = true;
        this->debugMode = debugMode;
        needsPerspectiveAdjustment = false;
        viewportSize = CGSizeMake(nativeDimensions.x,nativeDimensions.y);
        yTexture = NULL;
        CbCrTexture = NULL;
        near = 0.1;
        far = 1000.0;
        debugMode = false;
        xShift = 0;
        yShift = 0;
        
        
        // initialize video texture cache
        CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, ofxiOSGetGLView().context, NULL, &_videoTextureCache);
        if (err){
            NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
        }
        
        // ========== CAMERA CORRECTION  ============= //
        
        // On iPads, it seems we need to re-crop and orient the image. Lets set some things up to try to do that.
        
        // get the name of the current device
        deviceType = [[UIDevice currentDevice] model];
        
        // setup zooming if we're not on an iPhone
        if([deviceType isEqualToString:@"iPad"]){
            needsPerspectiveAdjustment = true;
        }
        
        // try to fit the camera capture width within the device's viewport.
        // default capture dimensions seem to be 1280x720 regardless of device and orientation.
        cam = ofRectangle(0,0,1280,720);
        
        // this appears to fix inconsistancies in the image that occur in the difference in
        // startup orientation.
        if(UIDevice.currentDevice.orientation == UIDeviceOrientationPortrait){
            screen = ofRectangle(0,0,ofGetWindowWidth(),ofGetWindowHeight());
        }else{
            screen = ofRectangle(0,0,ofGetWindowHeight(),ofGetWindowWidth());
        }
        
        cam.scaleTo(screen,OF_ASPECT_RATIO_KEEP);
        
        // scale up rectangle based on aspect ratio of scaled capture dimensions.
        scaleVal = [[UIScreen mainScreen] scale];
        
        cam.scaleFromCenter(scaleVal);
        
        cameraDimensions.x = cam.getWidth();
        cameraDimensions.y = cam.getHeight();
        
        // correct rotation of camera image
        rotation.makeRotationMatrix(-90, ofVec3f(0,0,1));
        
        // ========== SHADER SETUP  ============= //
        // setup plane and shader in order to draw the camera feed
        vMesh.setVertexData(kImagePlaneVertexData, 4, 16, GL_DYNAMIC_DRAW);
        cameraConvertShader.setupShaderFromSource(GL_VERTEX_SHADER, ARShaders::camera_convert_vertex);
        cameraConvertShader.setupShaderFromSource(GL_FRAGMENT_SHADER, ARShaders::camera_convert_fragment);
        cameraConvertShader.linkProgram();
        
        
        // allocate the fbo to draw the image with, large enough to support
        // any sized screen.
        // TODO perf tests - is 4000x4000 too big? Memory seems minimaly imapacted if at all.
        cameraFbo.allocate(4000,4000, GL_RGBA);
        cameraFbo.getTexture().getTextureData().bFlipTexture = true;
        
    }
    void ARCam::setCameraImageDimensions(float x, float y ){
        cameraDimensions.x = x;
        cameraDimensions.y = y;
    }
    
    void ARCam::drawScaled(int x, int y, float w, float h){
        
        
        if(x == 0){
            x = xShift;
        }
        
        if(y == 0){
            y = yShift;
        }
        
        if(w == 0){
            w = cameraDimensions.x;
        }
        
        if(h == 0){
            h = cameraDimensions.y;
        }
        
        if(needsPerspectiveAdjustment){
            // Adjust drawing as necessary .
            switch(UIDevice.currentDevice.orientation){
                case UIDeviceOrientationFaceUp:
                    
                    if(deviceOrientation == UIDeviceOrientationLandscapeLeft ||
                       deviceOrientation == UIDeviceOrientationLandscapeRight){
                        cameraFbo.draw(xShift,yShift,cam.getWidth(),cam.getHeight());
                    }else{
                        cameraFbo.draw(xShift,yShift,cameraDimensions.y,cameraDimensions.x);
                    }
                    break;
                    
                case UIDeviceOrientationFaceDown:
                    break;
                    
                case UIDeviceOrientationUnknown:
                    cameraFbo.draw(xShift,yShift,cameraDimensions.y,cameraDimensions.x);
                    
                    break;
                case UIDeviceOrientationPortraitUpsideDown:
                    cameraFbo.draw(xShift,yShift,cameraDimensions.y,cameraDimensions.x);
                    break;
                    
                case UIDeviceOrientationPortrait:
                    cameraFbo.draw(xShift,yShift,cameraDimensions.y,cameraDimensions.x);
                    break;
                    
                case UIDeviceOrientationLandscapeLeft:
                    cameraFbo.draw(xShift,yShift,cameraDimensions.x,cameraDimensions.y);
                    
                    break;
                    
                case UIDeviceOrientationLandscapeRight:
                    cameraFbo.draw(xShift,yShift,cameraDimensions.x,cameraDimensions.y);
                    break;
            }
            
        }else{
            // iphones seem to be impervious to this scaling issue so just draw it at the full height
            // and width of the current viewport.
            cameraFbo.draw(0,0,ofGetWindowWidth(),ofGetWindowHeight());
        }
   
    }
    
    void ARCam::draw(){
        cameraConvertShader.begin();
        
        switch(UIDevice.currentDevice.orientation){
            case UIDeviceOrientationFaceUp:
            cameraConvertShader.setUniform1i("isPortraitOrientation", true);
            break;
            case UIDeviceOrientationFaceDown:
            break;
            
            case UIDeviceOrientationUnknown:
            
            cameraConvertShader.setUniform1i("isPortraitOrientation", true);
            break;
            case UIDeviceOrientationPortraitUpsideDown:
            
            cameraConvertShader.setUniform1i("isPortraitOrientation", true);
            break;
            
            case UIDeviceOrientationPortrait:
            
            cameraConvertShader.setUniform1i("isPortraitOrientation", true);
            
            break;
            
            case UIDeviceOrientationLandscapeLeft:
            
            cameraConvertShader.setUniform1i("isPortraitOrientation", false);
            break;
            
            case UIDeviceOrientationLandscapeRight:
            
            cameraConvertShader.setUniform1i("isPortraitOrientation", false);
            break;
        }
        
        vMesh.draw(GL_TRIANGLE_STRIP, 0, 16);
        cameraConvertShader.end();
    }
    
    //! Sets the x and y position of where the camera image is placed.
    void ARCam::setCameraImagePosition(float xShift,float yShift){
        this->xShift = xShift;
        this->yShift = yShift;
    }
    
    //! Returns the calculated bounds of the camera image.
    //! Useful in calculating the x and y pos of the camera image.
    ofRectangle ARCam::getCameraImageBounds(){
        return cam;
    }
    
    void ARCam::updateInterfaceOrientation(){
        
        switch(UIDevice.currentDevice.orientation){
            case UIDeviceOrientationFaceUp:
                orientation = UIInterfaceOrientationPortrait;
                break;
                
            case UIDeviceOrientationFaceDown:
                orientation = UIInterfaceOrientationPortrait;
                break;
                
            case UIInterfaceOrientationUnknown:
                orientation = UIInterfaceOrientationPortrait;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                orientation = UIInterfaceOrientationPortrait;
                break;
                
            case UIDeviceOrientationPortrait:
                orientation = UIInterfaceOrientationPortrait;
                
                break;
                
                // for the next two cases - I know it's opposite land - but trust me it works :p
                
            case UIDeviceOrientationLandscapeLeft:
                orientation = UIInterfaceOrientationLandscapeRight;
                break;
                
                
            case UIDeviceOrientationLandscapeRight:
                orientation = UIInterfaceOrientationLandscapeLeft;
                break;
        }
        
    }
    
    void ARCam::updateDeviceOrientation(){
        
        rotation.makeIdentityMatrix();
        
        ofVec2f _viewport = ARCommon::getDeviceDimensions();
        viewportSize.width = _viewport.x;
        viewportSize.height = _viewport.y;
        
        switch(UIDevice.currentDevice.orientation){
            case UIDeviceOrientationFaceUp:
                if(deviceOrientation == UIDeviceOrientationLandscapeLeft){
                    rotation.makeRotationMatrix(0, ofVec3f(0,0,1));
                }else if(deviceOrientation == UIDeviceOrientationLandscapeRight){
                    rotation.makeRotationMatrix(180, ofVec3f(0,0,1));
                }else{
                    rotation.makeRotationMatrix(-90, ofVec3f(0,0,1));
                }
                
                break;
                
            case UIDeviceOrientationFaceDown:
                rotation.makeRotationMatrix(-90, ofVec3f(0,0,1));
                break;
                
            case UIInterfaceOrientationUnknown:
                rotation.makeRotationMatrix(-90, ofVec3f(0,0,1));
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                
                break;
                
            case UIDeviceOrientationPortrait:
                rotation.makeRotationMatrix(-90, ofVec3f(0,0,1));
                
                break;
                
            case UIDeviceOrientationLandscapeLeft:
                rotation.makeRotationMatrix(180, ofVec3f(0,0,1));
                
                break;
                
            case UIDeviceOrientationLandscapeRight:
                break;
        }
    }
    
    void ARCam::setCameraNearClip(float near){
        this->near = near;
    }
    void ARCam::setCameraFarClip(float far){
        this->far = far;
    }
    
    void ARCam::updateRotationMatrix(float angle){
        rotation.makeRotationMatrix(angle, ofVec3f(0,0,1));
    }
    
    ARLightEstimate* ARCam::getLightingConditions(){
        return session.currentFrame.lightEstimate;
    }
    
    ARTrackingState ARCam::getTrackingState(){
        return currentFrame.camera.trackingState;
    }
    
    void ARCam::updatePlaneTexCoords(){
        
        // see
        // https://developer.apple.com/documentation/arkit/arframe/2923543-displaytransformfororientation?language=objc
        // this is more or less from the default project example.
        
        CGAffineTransform displayToCameraTransform = CGAffineTransformInvert([currentFrame displayTransformForOrientation:orientation viewportSize:viewportSize]);
        
        for (NSInteger index = 0; index < 4; index++) {
            NSInteger textureCoordIndex = 4 * index + 2;
            CGPoint textureCoord = CGPointMake(kImagePlaneVertexData[textureCoordIndex], kImagePlaneVertexData[textureCoordIndex + 1]);
            CGPoint transformedCoord = CGPointApplyAffineTransform(textureCoord, displayToCameraTransform);
            kImagePlaneVertexData[textureCoordIndex] = transformedCoord.x;
            kImagePlaneVertexData[textureCoordIndex + 1] = transformedCoord.y;
            vMesh.updateVertexData(kImagePlaneVertexData, 16);
        }
    }
    
    void ARCam::logTrackingState(){
        
        if(debugMode){
            
            
            switch(trackingStateReason){
                case ARTrackingStateReasonNone:
                    ofLog(OF_LOG_NOTICE,"Tracking state is a-ok!");
                    break;
                    
                case ARTrackingStateReasonInitializing:
                    ofLog(OF_LOG_NOTICE,"Tracking is warming up and waiting for enough information to start tracking");
                    break;
                    
                case ARTrackingStateReasonExcessiveMotion:
                    ofLog(OF_LOG_ERROR,"There is excessive motion at the moment, tracking is affected.");
                    break;
                    
                case ARTrackingStateReasonInsufficientFeatures:
                    ofLog(OF_LOG_ERROR,"There are not enough features found to enable tracking");
                    break;
            }
        }
    }
    
    float ARCam::getAmbientIntensity(){
        return ambientIntensity;
    }
    
    void ARCam::setInterfaceOrientation(UIInterfaceOrientation orientation){
        this->orientation = orientation;
    }
    
    void ARCam::update(){
        // if we haven't set a session - just stop things here.
        if(!session){
            return;
        }
        
        // TODO is this call useful? So far everything seems to be captured at 1280x720 no matter the device.
        // May need to revisit later. Note it's here because calling it in setup results in 0 due to
        // camera not having captured any information.
        //CGSize size = session.currentFrame.camera.imageResolution;
       
        currentFrame = session.currentFrame;
        trackingState = currentFrame.camera.trackingState;
        
        
        if(debugMode){
            // update state and reason
            trackingStateReason = currentFrame.camera.trackingStateReason;
        }
        
        // update camera transform
        cameraMatrices.cameraTransform = convert<matrix_float4x4,ofMatrix4x4>(currentFrame.camera.transform);
        
        // update camera projection and view matrices.
        getMatricesForOrientation(orientation,near,far);
        
        // only act if we have the current frame
        if(currentFrame){
            
            // update tex coords to try and better scale the image coming from the camera.
            updatePlaneTexCoords();
            
            // do light estimates
            if (currentFrame.lightEstimate) {
                
                // note - in lumens, divide by 1000 to get a more normal value
                ambientIntensity = currentFrame.lightEstimate.ambientIntensity / 1000;
                
                // note - in kelvin,
                //A value of 6500 represents neutral (pure white) lighting; lower values indicate a "warmer" yellow or orange tint, and higher values indicate a "cooler" blue tint.
                ambientColorTemperature = currentFrame.lightEstimate.ambientColorTemperature;
            }
            
            
            // grab current frame pixels from camera
            CVPixelBufferRef pixelBuffer = currentFrame.capturedImage;
            
            // if we have both planes from the camera, build the camera frame
            // in case we want to view it.
            if(shouldBuildCameraFrame){
                if (CVPixelBufferGetPlaneCount(pixelBuffer) >= 2) {
                    buildCameraFrame(pixelBuffer);
                    
                    // write image to fbo
                    cameraFbo.begin();
                    cameraConvertShader.begin();
                    
                    switch(UIDevice.currentDevice.orientation){
                        case UIDeviceOrientationFaceUp:
                            cameraConvertShader.setUniform1i("isPortraitOrientation", true);
                            break;
                        case UIDeviceOrientationFaceDown:
                            break;
                            
                        case UIDeviceOrientationUnknown:
                            
                            cameraConvertShader.setUniform1i("isPortraitOrientation", true);
                            break;
                        case UIDeviceOrientationPortraitUpsideDown:
                            
                            cameraConvertShader.setUniform1i("isPortraitOrientation", true);
                            break;
                            
                        case UIDeviceOrientationPortrait:
                            
                            cameraConvertShader.setUniform1i("isPortraitOrientation", true);
                            
                            break;
                            
                        case UIDeviceOrientationLandscapeLeft:
                            
                            cameraConvertShader.setUniform1i("isPortraitOrientation", false);
                            break;
                            
                        case UIDeviceOrientationLandscapeRight:
                            
                            cameraConvertShader.setUniform1i("isPortraitOrientation", false);
                            break;
                    }
                    
                    vMesh.draw(GL_TRIANGLE_STRIP, 0, 16);
                    cameraConvertShader.end();
                    cameraFbo.end();
                  
                    
                }
            }
            
        }
        
        // Periodic texture cache flush every frame
        CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
    }
    
    ofTexture ARCam::getCameraImage(){
        cameraFbo.begin();
        cameraConvertShader.begin();
        
        vMesh.draw(GL_TRIANGLE_STRIP, 0, 16);
        cameraConvertShader.end();
        cameraFbo.end();
        
        return cameraFbo.getTexture();
    }
    void ARCam::setARCameraMatrices(){
        ofSetMatrixMode(OF_MATRIX_PROJECTION);
        ofLoadMatrix(cameraMatrices.cameraProjection);
        ofSetMatrixMode(OF_MATRIX_MODELVIEW);
        ofLoadMatrix(cameraMatrices.cameraView);
    }
    
    
    ARCameraMatrices ARCam::getMatricesForOrientation(UIInterfaceOrientation orientation,float near, float far){
    
        cameraMatrices.cameraView = toMat4([session.currentFrame.camera viewMatrixForOrientation:orientation]);
        cameraMatrices.cameraProjection = toMat4([session.currentFrame.camera projectionMatrixForOrientation:orientation viewportSize:viewportSize zNear:(CGFloat)near zFar:(CGFloat)far]);
        
        return cameraMatrices;
    }
    
    
    // ============= PRIVATE ================= //
    
    void ARCam::buildCameraFrame(CVPixelBufferRef pixelBuffer){
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        
        
        // ========= RELEASE DATA PREVIOUSLY HELD ================= //
        
        CVBufferRelease(yTexture);
        CVBufferRelease(CbCrTexture);
        
        
        // ========= ROTATE IMAGES ================= //
        
        cameraConvertShader.begin();
        cameraConvertShader.setUniformMatrix4f("rotationMatrix", rotation);
        
        cameraConvertShader.end();
        
        // ========= BUILD CAMERA TEXTURES ================= //
        yTexture = createTextureFromPixelBuffer(pixelBuffer, 0);
        
        int width = (int) CVPixelBufferGetWidth(pixelBuffer);
        int height = (int) CVPixelBufferGetHeight(pixelBuffer);
        
        CbCrTexture = createTextureFromPixelBuffer(pixelBuffer, 1,GL_LUMINANCE_ALPHA,width / 2, height / 2);
        
        
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
        cameraConvertShader.begin();
        
        
        cameraConvertShader.setUniform2f("resolution", viewportSize.width,viewportSize.height);
        cameraConvertShader.setUniformTexture("yMap", CVOpenGLESTextureGetTarget(yTexture), CVOpenGLESTextureGetName(yTexture), 0);
        
        cameraConvertShader.setUniformTexture("uvMap", CVOpenGLESTextureGetTarget(CbCrTexture), CVOpenGLESTextureGetName(CbCrTexture), 1);
        
        cameraConvertShader.end();
        
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        
        
    }
    
    CVOpenGLESTextureRef ARCam::createTextureFromPixelBuffer(CVPixelBufferRef pixelBuffer,int planeIndex,GLenum format,int width,int height){
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
    
}

