//
//  ImageMesh.cpp
//  photo-capture
//
//  Created by Joseph Chow on 9/2/17.
//

#include "ImageMesh.h"


ImageMesh::ImageMesh(){
 
  
}
void ImageMesh::setup(){
    mesh = ofMesh::plane(ofGetWindowWidth(),ofGetWindowHeight());
    shader.setupShaderFromSource(GL_VERTEX_SHADER, vert);
    shader.setupShaderFromSource(GL_FRAGMENT_SHADER, fragment);
    shader.linkProgram();
}

void ImageMesh::setTexture(ofTexture tex){
    texture = tex;
}

void ImageMesh::draw(ARCommon::ARCameraMatrices cameraMatrices){
    shader.begin();
    shader.setUniformMatrix4f("projectionMatrix", cameraMatrices.cameraTransform);
    shader.setUniformMatrix4f("viewMatrix", cameraMatrices.cameraView);
    
    mesh.draw();
    shader.end();
}
