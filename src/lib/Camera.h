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
                                                       
                                                       
                                                        vec2 uV = position.xy * scale + scale;
                                                        vUv = vec2(uV.s, 1.0 - uV.t);
                                                                                                               
                                                        gl_Position = vec4(position,0.0,1.0);
                                                       
                                                       
                                                       
                                                   });
            
            std::string fragment = STRINGIFY(
                                                     precision highp float;
                                                     varying vec2 vUv;
                                             
                                                     uniform sampler2D tex;
                                             
                                                     void main(){
                                                        
                                                        gl_FragColor = texture2D(tex, vUv);
                
                                                     }
                                                     );
            
            
            std::string vertexMatte = STRINGIFY(

                                          
                                                   attribute vec2 position;

                                                   uniform vec4 cAffineCamABCD;
                                                   uniform vec2 cAffineCamTxTy;
                                           
                                                   varying vec2 vUv;
                                                   varying vec2 vUvCam;

                                                   // https://developer.apple.com/documentation/coregraphics/cgaffinetransform
                                                   vec2 affineTransform(vec2 uv, vec4 coeff, vec2 offset){
                                                        return vec2(uv.s * coeff.x + uv.t * coeff.z + offset.x,
                                                                    uv.s * coeff.y + uv.t * coeff.w + offset.y);
                                                   }
                                          
                                                   const vec2 scale = vec2(0.5,0.5);
                                                   void main(){
                                                       
                                                       
                                                        vec2 uV = position.xy * scale + scale;
                                                        vUv = vec2(uV.s, 1.0 - uV.t);
                                                        vUvCam = affineTransform(vUv, cAffineCamABCD, cAffineCamTxTy);
                                                                                                               
                                                        gl_Position = vec4(position,0.0,1.0);
                                                       
                                                       
                                                       
                                                   });
            
            std::string fragmentMatte = STRINGIFY(
                                                     precision highp float;
                                                     varying vec2 vUv;
                                                     varying vec2 vUvCam;
                                             
                                                     uniform sampler2D tex;
                                                     uniform sampler2D texAlphaBody;
                                                     uniform sampler2D texDepthBody;
                                                     uniform sampler2D texDepth;
                                             
                                                     uniform mat4 u_CameraProjectionMat;
                                             
                                                     uniform float u_time;
                                             
                                                     void main(){
                
                
                                                         
                                                        vec4 sceneColor = texture2D(tex, vUv);
                                                        float sceneDepth = texture2D(texDepth, vUvCam).r;


                                                        float alpha = texture2D( texAlphaBody, vUvCam).r;
                                                        float dilatedLinearDepth = texture2D(texDepthBody, vUvCam).r;

                                                        float dilatedDepth = clamp((u_CameraProjectionMat[2][2] * - dilatedLinearDepth + u_CameraProjectionMat[3][2]) / (u_CameraProjectionMat[2][3] * -dilatedLinearDepth + u_CameraProjectionMat[3][3]), 0.0, 1.0);

                                                        float showOccluder = 1.0;
                                                        showOccluder = step(dilatedDepth, sceneDepth); // forwardZ case


                                                        // camera Color is a sine of the actual color * time
                                                        vec4 cameraColor = vec4(sceneColor.r + abs(sin(u_time)), sceneColor.g + abs(cos(u_time)), sceneColor.b, sceneColor.a) * dilatedDepth;

                                                        vec4 occluderResult = mix(sceneColor, cameraColor, alpha);
                                                        vec4 mattingResult = mix(sceneColor, occluderResult, showOccluder);
                                                        gl_FragColor = occluderResult;
                

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
                        
            //======== MATTE API ============ //
#if defined( __IPHONE_13_0 )
             CVOpenGLESTextureRef getTextureMatteAlpha();
             CVOpenGLESTextureRef getTextureMatteDepth();
             CVOpenGLESTextureRef getTextureDepth();
             ofMatrix3x3 getAffineTransform();
#endif
            
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
