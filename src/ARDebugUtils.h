//
//  DebugCloud.hpp
//
//  Created by Joseph Chow on 8/18/17.
//  Additional code added from contributors
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
    
    class ARDebugInfo {
      
        int x,y;
        ARSession * session;
    public:
        ARDebugInfo(){}
        ARDebugInfo(ARSession * session,int x=40,int y=40){
            this->session = session;
            this->x = x;
            this->y = y;
            
        }
        void drawDebugInformation(ofTrueTypeFont font){
            
            // get tracking state reason
            ARTrackingStateReason trackingStateReason = session.currentFrame.camera.trackingStateReason;
            
    
          
            // ============== DRAW GENERAL DEBUG INFO ===================== //
            font.drawString("frame num      = " + ofToString( ofGetFrameNum() ),    x, y);
            font.drawString("frame rate     = " + ofToString( ofGetFrameRate() ),   x, y + 25);
            font.drawString("screen width   = " + ofToString( ofGetWidth() ),       x, y + 50);
            font.drawString("screen height  = " + ofToString( ofGetHeight() ),      x, y + 75);
            
            
            // ============== DRAW TRACKING INFO ===================== //
            switch(trackingStateReason){
                case ARTrackingStateReasonNone:
                    font.drawString("Tracking state: Great!",x,y + 100);
                    
                    break;
                    
                case ARTrackingStateReasonInitializing:
                    font.drawString("Tracking state: Initializing!",x,y + 100);
                    break;
                    
                case ARTrackingStateReasonExcessiveMotion:
                    font.drawString("Tracking state: Excessive Motion!",x,y + 100);
                    
                    break;
                    
                case ARTrackingStateReasonInsufficientFeatures:
                    font.drawString("Tracking state: Bad!",x,y + 100);
                    break;
            }
          
            
        }
    };
    
    
    //! Helper class for recognizing features and drawing the resulting point cloud.

    class PointCloudDebug {
        
        //! VBO for point cloud
        GLuint vbo;
        
        // shader for point cloud
        ofShader pointShader;

        // the size of the point cloud data
        NSInteger bytesCount;
        
        // number of points in the cloud.
        int pointCount;
        
        // reference to the point cloud object itself.
        ARPointCloud * pointCloud;
        
        
    public:
        PointCloudDebug(){}
        
        //! Sets up the point cloud 
        void setup(){
            pointShader.setupShaderFromSource(GL_VERTEX_SHADER, ARShaders::point_cloud_vertex);
            pointShader.setupShaderFromSource(GL_FRAGMENT_SHADER, ARShaders::point_cloud_fragment);
            pointShader.linkProgram();
 
            pointCount = 0;
            
            glGenBuffers(1, &vbo);
        }
        
        std::set<uint64_t> uniqueIds;
        
        // this method is for getting feature points once and only once
        // useful for building up a mesh overtime without getting tons of duplicates
        // these are unique points found since the start of the ar session
        vector<ofVec3f> getPoints(ARFrame * currentFrame){
            pointCloud = currentFrame.rawFeaturePoints;
            pointCount = pointCloud.count;
            
            //copy the old set to compare against
            std::set<uint64_t> oldSet;
            oldSet.clear();
            oldSet = uniqueIds;
            
            for(int i = 0; i<pointCount; i++){
                //get all unique points since start of session
                uniqueIds.insert(pointCloud.identifiers[i]);
            }
            
            //get the difference between the sets
            std::set<uint64_t> difference;
            std::set_difference(uniqueIds.begin(), uniqueIds.end(),
                                oldSet.begin(), oldSet.end(),
                                std::inserter(difference, difference.end()));
            
            //if there is anything new put it in newpoints
            vector<ofVec3f> newPoints;
            newPoints.clear();
            
            for(auto d = difference.begin(); d != difference.end(); d++){
                for(int i = 0; i<pointCount; i++){
                    
                    if(*d == pointCloud.identifiers[i]){
                        vector_float3 p = pointCloud.points[i];
                        ofVec3f v3 = ofVec3f(p.x, p.y, p.z);
                        newPoints.push_back(v3);
                    }
                }
            }
            return newPoints;
        }
        
        // this method is for getting just the current frames points
        vector<ofVec3f> getCurrentPoints(ARFrame * currentFrame){
            pointCloud = currentFrame.rawFeaturePoints;
            pointCount = pointCloud.count;
            
            vector<ofVec3f> points;
            
            for(int i = 0; i<pointCount; i++){
                vector_float3 point =  pointCloud.points[i];
                ofVec3f v = ofVec3f(point.x, point.y, point.z);
                points.push_back(v);
            }
            
            return points;
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
