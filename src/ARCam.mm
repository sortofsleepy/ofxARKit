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
    
    void ARCam::setup(){
        ofVec2f screenSize = ARCommon::getDeviceDimensions();
        
        ambientIntensity = 0.0;
        orientation = UIInterfaceOrientationPortrait;
        shouldBuildCameraFrame = true;
        debugMode = true;
        needsPerspectiveAdjustment = false;
        viewportSize = CGSizeMake(ofGetWindowWidth(), ofGetWindowHeight());
        yTexture = NULL;
        CbCrTexture = NULL;
        near = 0.01;
        far = 1000.0;
  
        // initialize video texture cache
        CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, ofxiOSGetGLView().context, NULL, &_videoTextureCache);
        if (err){
            NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
        }
        
        // ========== CAMERA CORRECTION  ============= //
        
        // this plays into adjusting the camera image to fit the correct perspective.
        // this should THEORETICALLY be your devices aspect ratio which is what the default is.
        zoomLevel = ofGetWindowWidth() / ofGetWindowHeight();
        
        // get the name of the current device
        deviceType = [[UIDevice currentDevice] model];
        
        // setup zooming if we're not on an iPhone
        // TODO how does this affect things if we're on a smaller than standard iphone device, ie SE?
        // TODO maybe we should try to re-orient in shaderworld.
        if([deviceType isEqualToString:@"iPad"]){
            needsPerspectiveAdjustment = true;
            
            // correct video orientation
            rotation.makeRotationMatrix(90, ofVec3f(0,0,1));
            
        }else{
            // correct video orientation
            rotation.makeRotationMatrix(-90, ofVec3f(0,0,1));
            
        }

        // ========== SHADER SETUP  ============= //
        // setup plane and shader in order to draw the camera feed
        //cameraPlane = ofMesh::plane(ofGetWindowWidth(), ofGetWindowHeight());
        
        ofVec2f dimensions = ARCommon::getDeviceDimensions();
        cameraPlane = ofMesh::plane(dimensions.x,dimensions.y);
        
        cameraConvertShader.setupShaderFromSource(GL_VERTEX_SHADER, ARShaders::camera_convert_vertex);
        cameraConvertShader.setupShaderFromSource(GL_FRAGMENT_SHADER, ARShaders::camera_convert_fragment);
        cameraConvertShader.linkProgram();
        
        
        // going with a default of 1280x720 as that seems to be a consistant value that ARKit captures at
        // regardless of device, also after a contributor suggested POT textures are better.
        cameraFbo.allocate(1280,720, GL_RGBA);
    }
    
    void ARCam::setCameraNearClip(float near){
        this->near = near;
    }
    void ARCam::setCameraFarClip(float far){
        this->far = far;
    }
    void ARCam::adjustPerspectiveCorrection(float zoomLevel){
        this->zoomLevel = zoomLevel;
    }

    //void ARCam::setDeviceOrientation(UIInterfaceOrientation orientation){
    //    this->orientation = orientation;
   // }
    
    void ARCam::updateDeviceOrientation(){
        
       
      
        switch(UIDevice.currentDevice.orientation){
                
            case UIInterfaceOrientationUnknown:
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                rotation.makeRotationMatrix(270, ofVec3f(0,0,1));
                break;
                
            case UIInterfaceOrientationPortrait:
                rotation.makeRotationMatrix(-90, ofVec3f(0,0,1));
                break;
                
            case UIInterfaceOrientationLandscapeLeft:
                 rotation.makeRotationMatrix(0, ofVec3f(0,0,1));
                
                break;
                
            case UIInterfaceOrientationLandscapeRight:
                rotation.makeRotationMatrix(180, ofVec3f(0,0,1));
                break;
        }
        
    }
    
    ARLightEstimate* ARCam::getLightingConditions(){
        return session.currentFrame.lightEstimate;
    }

    void ARCam::update(){
        // if we haven't set a session - just stop things here.
        if(!session){
            return;
        }

      
        currentFrame = session.currentFrame;
        
        // update camera transform
        cameraMatrices.cameraTransform = convert<matrix_float4x4,ofMatrix4x4>(currentFrame.camera.transform);
        
        // update camera projection and view matrices.
        getMatricesForOrientation(orientation,near,far);
        
        // only act if we have the current frame
        if(currentFrame){
            
            
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
                    cameraPlane.draw();
                    cameraConvertShader.end();
                    cameraFbo.end();
                    
                }
            }
            
        }
        
        // Periodic texture cache flush every frame
        CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
    }
    void ARCam::setARCameraMatrices(){
        ofSetMatrixMode(OF_MATRIX_PROJECTION);
        ofLoadMatrix(cameraMatrices.cameraProjection);
        ofSetMatrixMode(OF_MATRIX_MODELVIEW);
        ofLoadMatrix(cameraMatrices.cameraView);
    }
    void ARCam::draw(){
        cameraFbo.draw(0,0,viewportSize.width,viewportSize.height);
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
        
        cameraConvertShader.setUniform1f("zoomRatio",zoomLevel);
        
        cameraConvertShader.setUniform1i("needsCorrection", needsPerspectiveAdjustment);
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

