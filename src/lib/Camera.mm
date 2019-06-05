//
//  Camera.cpp
//  example-metalcam
//
//  Created by Joseph Chow on 7/26/18.
//

#include <stdio.h>
#include "Camera.h"

using namespace ofxARKit::common;

namespace ofxARKit {
    namespace core {
        
        Camera::Camera(ARSession * session){
            this->session = session;
            viewport = CGRectMake(0,0,ofGetWindowWidth(),ofGetWindowHeight());
            auto context = ofxiOSGetGLView().context;
            
            setup(session,viewport,context);
            
            mesh = ofMesh::plane(ofGetWindowWidth(), ofGetWindowHeight());
            shader.setupShaderFromSource(GL_VERTEX_SHADER, vertex);
            shader.setupShaderFromSource(GL_FRAGMENT_SHADER, fragment);
            
            shader.linkProgram();
            
            near = 0.1f;
            far = 1000.0f;
        }
        
        CVOpenGLESTextureRef Camera::getTexture(){
            
            // remember - you'll need to flip the uv on the y-axis to get the correctly oriented image.
            return [_view getConvertedTexture];
        }
        
        void Camera::update(){
            [_view draw];
            
            cameraMatrices.cameraTransform = common::convert<matrix_float4x4,ofMatrix4x4>(session.currentFrame.camera.transform);
            
            getMatricesForOrientation(orientation, near, far);
        }
        ofxARKit::common::ARCameraMatrices Camera::getCameraMatrices(){
            return cameraMatrices;
        }
        common::ARCameraMatrices Camera::getMatricesForOrientation(UIInterfaceOrientation orientation,float near, float far){
            
            cameraMatrices.cameraView = toMat4([session.currentFrame.camera viewMatrixForOrientation:orientation]);
            cameraMatrices.cameraProjection = toMat4([session.currentFrame.camera projectionMatrixForOrientation:orientation viewportSize:viewport.size zNear:(CGFloat)near zFar:(CGFloat)far]);
            
            return cameraMatrices;
        }
        
        ARTrackingStateReason Camera::getTrackingState(){
            return session.currentFrame.camera.trackingStateReason;
        }
        
        void Camera::logTrackingState(){
            
            if(debugMode){
                trackingStateReason = session.currentFrame.camera.trackingStateReason;
                

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
                    case ARTrackingStateReasonRelocalizing:
                        
                        break;
                }
            }
        }
        void Camera::setARCameraMatrices(){
            ofSetMatrixMode(OF_MATRIX_PROJECTION);
            ofLoadMatrix(cameraMatrices.cameraProjection);
            ofSetMatrixMode(OF_MATRIX_MODELVIEW);
            ofLoadMatrix(cameraMatrices.cameraView);
        }
        
        void Camera::updateInterfaceOrientation(int newOrientation){
            orientation = (UIInterfaceOrientation)newOrientation;
          
            auto width = ofGetWindowWidth();
            auto height = ofGetWindowHeight();
            
            // this might be an oF thing - but values seem to be reversed after the first call when calling ofGetWindowWidth
            switch(orientation){
                case UIInterfaceOrientationPortrait:
                    
                    if(width > height){
                        viewport = CGRectMake(0,0,ofGetWindowHeight(),ofGetWindowWidth());
                    }
                    break;
                    
                case UIInterfaceOrientationLandscapeLeft:
                    
                    if(width < height){
                        viewport = CGRectMake(0,0,ofGetWindowHeight(),ofGetWindowWidth());
                    }
                    break;
                    
                case UIInterfaceOrientationLandscapeRight:
                    
                    if(width < height){
                        viewport = CGRectMake(0,0,ofGetWindowHeight(),ofGetWindowWidth());
                    }
                    break;
                    
                case UIInterfaceOrientationUnknown:
                    
                    if(width > height){
                        viewport = CGRectMake(0,0,ofGetWindowHeight(),ofGetWindowWidth());
                    }
                    break;
                    
                case UIInterfaceOrientationPortraitUpsideDown:
                    
                    if(width > height){
                        viewport = CGRectMake(0,0,ofGetWindowHeight(),ofGetWindowWidth());
                    }
                    break;
                    
            }
            
            //NSLog(@"view is %@",NSStringFromCGRect(viewport));
        }
        
        void Camera::draw(){
            
            
            // get and draw texture
            auto _tex = [_view getConvertedTexture];
            
            if(_tex){
                shader.begin();
                shader.setUniformTexture("tex", CVOpenGLESTextureGetTarget(_tex), CVOpenGLESTextureGetName(_tex), 0);
                mesh.draw();
                
                shader.end();
            }
        }
        
        // TODO move all ARCameraMatrices stuff to glm - using conversion function in the meantime. 
        
        glm::mat4 Camera::getProjectionMatrix(){
            return convert<ofMatrix4x4, glm::mat4>(cameraMatrices.cameraProjection);
        }
        glm::mat4 Camera::getViewMatrix(){
            return convert<ofMatrix4x4, glm::mat4>(cameraMatrices.cameraView);
        }
        
        glm::mat4 Camera::getTransformMatrix(){
             return convert<ofMatrix4x4, glm::mat4>(cameraMatrices.cameraTransform);
        }
        
        
        ofTexture Camera::getOfTexture(){
            
            CVOpenGLESTextureRef ref = [_view getConvertedTexture];
            unsigned int textureCacheID = CVOpenGLESTextureGetName(ref);
            
            ofTexture ofTex;
            //hardcoded vals for better speed
            ofTex.allocate(1920, 1080, GL_RGBA);
            ofTex.setUseExternalTextureID(textureCacheID);
            
            
            ofTex.setTextureMinMagFilter(GL_LINEAR, GL_LINEAR);
            ofTex.setTextureWrap(GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE);
            
            if(!ofIsGLProgrammableRenderer()) {
                ofTex.bind();
                glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
                ofTex.unbind();
            }
            
            return ofTex;
            
        }
    }
}
