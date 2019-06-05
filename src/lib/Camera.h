//
//  Camera.h
//  example-metalcam
//
//  Created by Joseph Chow on 7/26/18.
//

#ifndef Camera_h
#define Camera_h

#include "MetalCam.h"
#include "ofMain.h"
#include "ofxiOS.h"
#include "ARUtils.h"

#define STRINGIFY(A) #A

namespace ofxARKit {
    namespace core {
        
        typedef std::shared_ptr<class Camera> CameraRef;
        
        class Camera : public MetalCamRenderer{
            
            ofShader shader;
            ofMesh mesh;
            
            //MetalCamView * _view;
            //ARSession * session;
            CGRect viewport;
            
            UIInterfaceOrientation orientation;
            ofxARKit::common::ARCameraMatrices cameraMatrices;
            float near,far;
            
            std::string vertex = STRINGIFY(
                                          
                                                   attribute vec2 position;
                                                   varying vec2 vUv;
                                          
                                          
                                          
                                                   const vec2 scale = vec2(0.5,0.5);
                                                   void main(){
                                                       
                                                       
                                                       vUv = position.xy * scale + scale;
                                                       
                                                       
                                                       
                                                       gl_Position = vec4(position,0.0,1.0);
                                                       
                                                       
                                                       
                                                   }
                                          
                                                   );
            
            std::string fragment = STRINGIFY(
                                                     precision highp float;
                                                     varying vec2 vUv;
                                                     uniform sampler2D tex;
                                                     void main(){
                                                         
                                                         vec2 uv = vec2(vUv.s, 1.0 - vUv.t);
                                                         
                                                         
                                                         vec4 _tex = texture2D(tex,uv);
                                                         gl_FragColor = _tex;
                                                     }
                                                     );
            
        public:
            //! The current tracking state of the camera
            ARTrackingState trackingState;
            
            //! The reason for when a tracking state might be limited.
            ARTrackingStateReason trackingStateReason;
            
            //! Flag for turning debug mode on/off
            bool debugMode;
            
            Camera(ARSession * session);
            
            static CameraRef create(ARSession * session){
                return CameraRef(new Camera(session));
            }
            
            //TODO see about converting to ofTexture
            CVOpenGLESTextureRef getTexture();
            ofTexture getOfTexture();
            
            ARTrackingStateReason getTrackingState();
            
            glm::mat4 getProjectionMatrix();
            glm::mat4 getViewMatrix();
            glm::mat4 getTransformMatrix();
            
            ofxARKit::common::ARCameraMatrices getMatricesForOrientation(UIInterfaceOrientation orientation,float near, float far);
            ofxARKit::common::ARCameraMatrices getCameraMatrices();
            void updateInterfaceOrientation(int newOrientation);
            void setARCameraMatrices();
            void logTrackingState();
            void update();
            void draw();

            
            
        };
        
       
    }
}

#endif /* Camera_h */
