//
//  ARObjects.hpp
//
//  Created by Joseph Chow on 8/25/17.
//

#ifndef ARObjects_hpp
#define ARObjects_hpp

#include <stdio.h>
#include "ofMain.h"
#include <ARKit/ARKit.h>

namespace ARObjects {
    
    //! This defines the basic data structure of a Plane
    typedef struct {
        ofVec3f position;
        float width;
        float height;
        ofMatrix4x4 transform;
        NSUUID * uuid;
        ARPlaneAnchor * rawAnchor;        
    }PlaneAnchorObject;
    
    //! The base class you can use to build your AR object. Provides a model matrix and a mesh for easy tracking by ARKit.
    typedef struct {
        
        // a flag indicating whether or not this object was found by ARKit itself, or whether or not it was user added.
        bool systemAdded=false;
        
        // mesh for drawing a 3d object
        ofMesh mesh;
        
        // model matrix to store anchor tranform info
        ofMatrix4x4 modelMatrix;
        
        // a reference to the anchor itself.
        ARAnchor * rawAnchor;
        
        NSUUID * getUUID(){
            return rawAnchor.identifier;
        }
    }ARObject;
    
    //! The base class to build a Face geometry
    typedef struct {
        
        // raw anchor
        ARFaceAnchor * raw;
        
        // reference to vertices
        vector<ofVec3f> vertices;
        
        // reference to uvs
        vector<ofVec2f> uvs;
        
        // reference to indices
        vector<uint16_t> indices;
        
        NSUUID * uuid;
        
        // here for convinience, but you may want to build your own.
        ofMesh faceMesh;
        
        void rebuildFace(){
            
            // clear previous contents
            faceMesh.clear();
            
            faceMesh.addVertices(vertices);
            faceMesh.addTexCoords(uvs);
            faceMesh.addIndices(indices);
        }
        
    }FaceAnchorObject;
    
    //! quickly constructs an standard ARObject 
    static inline ARObject buildARObject(ARAnchor * rawAnchor,ofMatrix4x4 modelMatrix,bool systemAdded=false){
        ARObject obj;
        obj.rawAnchor = rawAnchor;
        obj.modelMatrix = modelMatrix;
        obj.systemAdded = systemAdded;
        
        return obj;
    }
};

#endif /* ARObjects_hpp */

