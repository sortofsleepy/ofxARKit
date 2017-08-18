//
//  ARToolkitComponents.h
//  example-basic
//
//  Created by Joseph Chow on 8/16/17.
//

#ifndef ARToolkitComponents_h
#define ARToolkitComponents_h

#define STRINGIFY(A) #A

namespace ARCommon {
    
    // borrowed from https://github.com/wdlindmeier/Cinder-Metal/blob/master/include/MetalHelpers.hpp
    // helpful converting to and from SIMD
    template <typename T, typename U >
    const U static inline convert( const T & t )
    {
        U tmp;
        memcpy(&tmp, &t, sizeof(U));
        U ret = tmp;
        return ret;
    }
    
    
    const std::string camera_render_vertex = STRINGIFY (
                                                        attribute vec2 position;
                                                        varying vec2 vUv;
                                                        
                                                        const vec2 scale = vec2(0.5,0.5);
                                                        void main(){
                                                            vUv = position.xy * scale + scale;
                                                            
                                                            gl_Position = vec4(position,0.0,1.0);
                                                        }
    
    );
    
    const std::string camera_render_fragment = STRINGIFY (
                                                          precision highp float;
                                                          
                                                          // this is the yyuv texture from ARKit
                                                          uniform sampler2D cameraTexture;
                                                          varying vec2 vUv;
                                                          
                                                          
                                                          void main(){
                                                              
                                                              // flip uvs so image isn't inverted.
                                                              vec2 textureCoordinate = vec2(vUv.s,1.0 - vUv.t);
                                                              
                                                              
                                                              gl_FragColor = texture2D(cameraTexture,textureCoordinate);
                                                          }
                                                          
                                                          
                                                          
                                                          
    );
    
    // keep camera image shader source in directly since this will never really have to change.
    // Shaders built with the help of
    // https://github.com/BradLarson/GPUImage
    
    //Specifically between these couple files
    // https://github.com/BradLarson/GPUImage/blob/167b0389bc6e9dc4bb0121550f91d8d5d6412c53/framework/Source/GPUImageColorConversion.m
    // https://github.com/BradLarson/GPUImage/blob/167b0389bc6e9dc4bb0121550f91d8d5d6412c53/framework/Source/GPUImageVideoCamera.m
    const std::string camera_convert_vertex = STRINGIFY(
                                                attribute vec2 position;
                                                varying vec2 vUv;
                                                uniform mat4 rotationMatrix;
                                                
                                                const vec2 scale = vec2(0.5,0.5);
                                                void main(){
                                                    vUv = position.xy * scale + scale;
                                                    
                                                    gl_Position = rotationMatrix * vec4(position,0.0,1.0);
                                                }
                                                
                                                
                                                );
    
    
    
    const std::string camera_convert_fragment = STRINGIFY(
                                                  precision highp float;
                                                  
                                                  // this is the yyuv texture from ARKit
                                                  uniform sampler2D yMap;
                                                  uniform sampler2D uvMap;
                                                  varying vec2 vUv;
                                                  
                                                  
                                                  void main(){
                                                      
                                                      // flip uvs so image isn't inverted.
                                                      vec2 textureCoordinate = vec2(vUv.s,1.0 - vUv.t);
                                                      
                                                      // Using BT.709 which is the standard for HDTV
                                                      mat3 colorConversionMatrix = mat3(
                                                                                        1.164,  1.164, 1.164,
                                                                                        0.0, -0.213, 2.112,
                                                                                        1.793, -0.533,   0.0
                                                                                        );
                                                      
                                                      
                                                      mediump vec3 yuv;
                                                      lowp vec3 rgb;
                                                      
                                                      yuv.x = texture2D(yMap, textureCoordinate).r - (16.0/255.0);
                                                      yuv.yz = texture2D(uvMap, textureCoordinate).ra - vec2(0.5, 0.5);
                                                      
                                                      rgb = colorConversionMatrix * yuv;
                                                      
                                                      gl_FragColor = vec4(rgb,1.);
                                                  }
                                                  
                                                  
                                                  
                                                  
                                                  
                                                  
                                                  );
}

#endif /* ARToolkitComponents_h */
