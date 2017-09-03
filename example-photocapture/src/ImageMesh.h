//
//  ImageMesh.hpp
//  photo-capture
//
//  Created by Joseph Chow on 9/2/17.
//

#ifndef ImageMesh_hpp
#define ImageMesh_hpp

#include <stdio.h>
#include "ARObjects.h"
#include "ARUtils.h"

#define STRINGIFY(A) #A
class ImageMesh : public ARObjects::ARObject{
  
    std::string vert = STRINGIFY(
                                 attribute vec2 position;
                                 attribute vec2 uv;
                                 uniform mat4 projectionMatrix;
                                 uniform mat4 viewMatrix;
                                 uniform mat4 modelMatrix;
                                 varying vec2 vUv;
                                 void main(){
                                     
                                   
                                  
                                     vUv = uv;
                                     gl_Position = projectionMatrix * viewMatrix * vec4(position,0.0,1.0);
                                 }
    );
    
    std::string fragment = STRINGIFY(
                                     precision highp float;
                                     uniform sampler2D image;
                                     varying vec2 vUv;
                                     
                                     void main(){
                                         //gl_FragColor = texture2D(image,vUv);
                                         gl_FragColor = vec4(1.0,1.0,0.0,1.0);
                                     }
    );
    ofShader shader;
    ofTexture texture;
public:
    
    ImageMesh();
    void setup();
    void setTexture(ofTexture tex);
    void draw(ARCommon::ARCameraMatrices cameraMatrices);
};

#endif /* ImageMesh_hpp */
