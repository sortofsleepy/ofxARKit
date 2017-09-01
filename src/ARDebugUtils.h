//
//  DebugCloud.hpp
//
//  Created by Joseph Chow on 8/18/17.
//

#ifndef DebugCloud_hpp
#define DebugCloud_hpp

#include <stdio.h>
#include <ARKit/ARKit.h>
#include "ARUtils.h"
#include "ARShaders.h"

#define STRINGIFY(A) #A


#ifdef OF_TARGET_IPHONE
#include "ofMain.h"
#endif

namespace ARDebugUtils {
    
    //! Helper class for recognizing features and drawing the resulting point cloud.
    
    class PointCloudDebug {
        
        //! VBO for point cloud
        GLuint vbo;
        
#ifdef OF_TARGET_IPHONE
        // shader for point cloud
        ofShader pointShader;
#endif
   
        // the size of the point cloud data
        NSInteger bytesCount;
        
        // number of points in the cloud.
        int pointCount;
        
        // reference to the point cloud object itself.
        ARPointCloud * pointCloud;
        
        
    public:
        PointCloudDebug(){

            
        }
        
        void setup(){
            pointShader.setupShaderFromSource(GL_VERTEX_SHADER, ARShaders::point_cloud_vertex);
            pointShader.setupShaderFromSource(GL_FRAGMENT_SHADER, ARShaders::point_cloud_fragment);
            pointShader.linkProgram();
 
            pointCount = 0;
            
            glGenBuffers(1, &vbo);
        }
        
        //! update cloud data and vbo
        void updatePointCloud(ARFrame * currentFrame){
            pointCloud = currentFrame.rawFeaturePoints;
            pointCount = pointCloud.count;
            bytesCount = pointCloud.count * sizeof(vector_float3);
            
            
            glBindBuffer(GL_ARRAY_BUFFER, vbo);
                  glBufferData(GL_ARRAY_BUFFER, bytesCount, pointCloud.points, GL_DYNAMIC_DRAW);
            glBindBuffer(GL_ARRAY_BUFFER,0);
            
          
        
        }
        
        //! get the number of features detected
        int getNumFeatures(){
            return pointCount;
        }
        
        //! returns whether or not features were detected.
        bool featuresDetected(){
            if(pointCount > 0){
                return true;
            }else{
                return false;
            }
        }

        
        //! draws the resulting point cloud - pass in a projection and view matrix(usually from ARKit)
        void draw(ofMatrix4x4 projectionMatrix,ofMatrix4x4 modelViewMatrix){
    
            pointShader.begin();
            pointShader.setUniformMatrix4f("projectionMatrix", projectionMatrix);
            pointShader.setUniformMatrix4f("modelViewMatrix",modelViewMatrix);

            glBindBuffer(GL_ARRAY_BUFFER,vbo);
            GLuint positionAttribLocation = pointShader.getAttributeLocation("position");
            
            glEnableVertexAttribArray(positionAttribLocation);
            glVertexAttribPointer(positionAttribLocation, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), (char *)NULL);
            
            glDrawArrays(GL_POINTS, 0, (GLsizei)pointCount);
            glBindBuffer(GL_ARRAY_BUFFER,0);
            
            
            pointShader.end();

        }

    };
}

#endif /* DebugCloud_hpp */
