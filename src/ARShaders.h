//
//  ARShaders.h
//
//  Created by Joseph Chow on 8/19/17.
//

#ifndef ARShaders_h
#define ARShaders_h

// keep camera image shader source in directly since this will never really have to change.
// Same with point cloud shaders.
#define STRINGIFY(A) #A
namespace ARShaders {
    
    

// Shaders built with the help of
// https://github.com/BradLarson/GPUImage

//Specifically between these couple files
// https://github.com/BradLarson/GPUImage/blob/167b0389bc6e9dc4bb0121550f91d8d5d6412c53/framework/Source/GPUImageColorConversion.m
// https://github.com/BradLarson/GPUImage/blob/167b0389bc6e9dc4bb0121550f91d8d5d6412c53/framework/Source/GPUImageVideoCamera.m
    
const std::string camera_convert_vertex = STRINGIFY(
                                                    attribute vec2 position;
                                                    varying vec2 vUv;
                                                    uniform mat4 rotationMatrix;
                                                    uniform float zoomRatio;
                                                    uniform bool needsCorrection;
                                                    
                                                    const vec2 scale = vec2(0.5,0.5);
                                                    void main(){
                                                       
                                                        
                                                        vUv = position.xy * scale + scale;
                                                        
                               
                                                        
                                                       gl_Position = rotationMatrix* vec4(position,0.0,1.0);
                                                    
                                                        
                                                        
                                                    }
                                                    
                                                    
                                                    );

    


const std::string camera_convert_fragment = STRINGIFY(
                                                      precision highp float;
                                                      
                                                      // this is the yyuv texture from ARKit
                                                      uniform sampler2D yMap;
                                                      uniform sampler2D uvMap;
                                                      uniform bool isPortraitOrientation;
                                                      uniform vec2 aspectRatio;
                                                      varying vec2 vUv;
                                                      
                                                      
                                                      void main(){
                                                          
                                                          // flip uvs so image isn't inverted.
                                                          vec2 textureCoordinate;
                                                          
                                                          // uv when portrait
                                                          //vec2 textureCoordinate = vec2(vUv.s, 1.0 - vUv.t);
                                                          
                                                          // uv when landsape
                                                          //vec2 textureCoordinate = vec2(1.0 - vUv.s,vUv.t);
                                                          
                                                          if(isPortraitOrientation){
                                                              textureCoordinate = vec2(vUv.s, 1.0 - vUv.t);
                                                             
                                                          }else{
                                                              textureCoordinate = vec2(1.0 - vUv.s,vUv.t);
                                                          }
                                                          
                                                          //textureCoordinate.x *= aspectRatio.x;
                                                          //textureCoordinate.y *= aspectRatio.y;
                                                          
                                                          
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

const std::string point_cloud_vertex = STRINGIFY(
                                                 attribute vec3 position;
                                                 uniform mat4 projectionMatrix;
                                                 uniform mat4 modelViewMatrix;
                                                 void main(){
                                                     mat4 mv = modelViewMatrix;
                                                     gl_PointSize = 20.0;
                                                     gl_Position = projectionMatrix * mv * vec4(position,1.0);
                                                 }
                                                 
                                                 );

const std::string point_cloud_fragment = STRINGIFY(
                                                   precision highp float;
                                                   
                                                   
                                                   
                                                   
                                                   void main(){
                                                       vec2 uv = gl_PointCoord.st;
                                                       uv = step(0.99, sin(uv*3.14) * 0.5 + 0.5);
                                                       uv += uv.yx;
                                                       if(uv.x < 0.1){discard;}
                                                       gl_FragColor = vec4(uv,0.0,1.);
                                                   }
                                                   
                                                   
                                                   
                                                   );
}
#endif /* ARShaders_h */

/*
 // if we need to correct perspective distortion,
 if(needsCorrection){
 
 
 
 //this method sort of works -
 //https://stackoverflow.com/questions/24651369/blend-textures-of-different-size-coordinates-in-glsl/24654919#24654919
 
vec2 fromCenter = vUv - scale;
vec2 scaleFromCenter = fromCenter * vec2(zoomRatio);

vUv -= scaleFromCenter;
}
*/
