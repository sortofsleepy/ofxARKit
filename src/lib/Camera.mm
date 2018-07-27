//
//  Camera.cpp
//  example-metalcam
//
//  Created by Joseph Chow on 7/26/18.
//

#include <stdio.h>
#include "Camera.h"

using namespace ARCommon;

namespace ofxARKit {
    namespace core {
        
        Camera::Camera(ARSession * session){
            this->session = session;
            viewport = CGRectMake(0,0,ofGetWindowWidth(),ofGetWindowHeight());
            this->session = session;
            
            
            _view = [[MetalCamView alloc] initWithFrame:viewport device:MTLCreateSystemDefaultDevice()];
            _view.session = session;
            _view.framebufferOnly = NO;
            _view.paused = YES;
            _view.enableSetNeedsDisplay = NO;
            
            auto context = ofxiOSGetGLView().context;
            
            [_view loadMetal];
            [_view setupOpenGLCompatibility:context];
            
            mesh = ofMesh::plane(ofGetWindowWidth(), ofGetWindowHeight());
            shader.setupShaderFromSource(GL_VERTEX_SHADER, vertex);
            shader.setupShaderFromSource(GL_FRAGMENT_SHADER, fragment);
            
            shader.linkProgram();
            
            near = 0.1f;
            far = 1000.0f;
        }
        
        CVOpenGLESTextureRef Camera::getTexture(){
            return [_view getConvertedTexture];
        }
        
        void Camera::update(){
            [_view draw];
            cameraMatrices.cameraTransform = convert<matrix_float4x4,ofMatrix4x4>(session.currentFrame.camera.transform);
            
            getMatricesForOrientation([[UIApplication sharedApplication] statusBarOrientation], near, far);
        }
        
        ARCameraMatrices Camera::getMatricesForOrientation(UIInterfaceOrientation orientation,float near, float far){
            
            cameraMatrices.cameraView = toMat4([session.currentFrame.camera viewMatrixForOrientation:orientation]);
            cameraMatrices.cameraProjection = toMat4([session.currentFrame.camera projectionMatrixForOrientation:orientation viewportSize:viewport.size zNear:(CGFloat)near zFar:(CGFloat)far]);
            
            return cameraMatrices;
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
    }
}
