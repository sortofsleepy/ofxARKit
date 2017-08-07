//
//  CameraFrameConverter.hpp
//  ARToolkit
//
//  Created by Joseph Chow on 8/4/17.
//

#ifndef CameraFrameConverter_hpp
#define CameraFrameConverter_hpp

#include "ofMain.h"
#include "ofxiOS.h"
#include <ARKit/ARKit.h>
#define STRINGIFY(A) #A

/**
     Processing class to help deal with ARKit stuff like grabbing and converting the camera feed,
     set anchors, etc.
 */
class ARProcessor {
    
    ARSession * session;

    bool sessionSet;
    float ambientIntensity;
    
    
    // ========== CAMERA IMAGE STUFF ================= //
    CVOpenGLESTextureRef yTexture;
    CVOpenGLESTextureRef CbCrTexture;
    CVOpenGLESTextureCacheRef _videoTextureCache;
    
    // mesh to render camera image
    ofMesh cameraPlane;
    
    // shader to color convert and render the camera image
    ofShader cameraShader;
    
    // this handles rotating the camera image to the correct orientation.
    ofMatrix4x4 rotation;
    
    
    // Converts the CVPixelBufferIndex into a OpenGL texture
    CVOpenGLESTextureRef createTextureFromPixelBuffer(CVPixelBufferRef pixelBuffer,int planeIndex,GLenum format=GL_LUMINANCE,int width=0,int height=0);
  
    std::string vertex_shader = STRINGIFY(
                                          attribute vec2 position;
                                          varying vec2 vUv;
                                          uniform mat4 rotationMatrix;
                                          
                                          const vec2 scale = vec2(0.5,0.5);
                                          void main(){
                                              vUv = position.xy * scale + scale;
                                              
                                              gl_Position = rotationMatrix * vec4(position,0.0,1.0);
                                          }
                                          

    );
    
    std::string fragment_shader = STRINGIFY(
                                            precision highp float;
                                            
                                            // this is the yyuv texture from ARKit split from 2 planes
                                            uniform sampler2D yMap;
                                            uniform sampler2D uvMap;
                                            
                                            varying vec2 vUv;
                                            uniform vec2 resolution;
                                            uniform mat4 rotationMatrix;
                                            
                                            void main(){
                                                
                                                // flip uvs so image isn't inverted.
                                                vec2 uv = vec2(vUv.s,1.0 - vUv.t);
                                                vec4 capturedImageTextureY = texture2D(yMap, uv);
                                                vec4 capturedImageTextureCbCr = texture2D(uvMap, uv);
                                                
                                                
                                                gl_FragColor = vec4(1.);
                                            }
                                            
                                            

        
    );
public:
    ARProcessor();
    ARProcessor(ARSession * session);
    void setup();
    void update();
    
    // draws the camera frame
    void draw();
    
    // alias for draw
    void drawCameraFrame();
    bool hasSetSession(){
        return sessionSet;
    }
};


#endif /* CameraFrameConverter_hpp */
