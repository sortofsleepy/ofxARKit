//
//  ARObjects.hpp
//  example-basic
//
//  Created by Joseph Chow on 8/25/17.
//

#ifndef ARObjects_hpp
#define ARObjects_hpp

#include <stdio.h>
#include "ofMain.h"
#include <ARKit/ARKit.h>

namespace ARObjects {
    typedef struct {
        ofVec3f position;
        float width;
        float height;
        ofMatrix4x4 transform;
        NSUUID * uuid;
        ARPlaneAnchor * rawAnchor;
    }PlaneAnchorObject;
    
    // The base class you can use to build your AR object. Provides a model matrix and a mesh for
    // easy tracking by ARKit.
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
    
    // quickly constructs an standard ARObject 
    static inline ARObject buildARObject(ARAnchor * rawAnchor,ofMatrix4x4 modelMatrix,bool systemAdded=false){
        ARObject obj;
        obj.rawAnchor = rawAnchor;
        obj.modelMatrix = modelMatrix;
        obj.systemAdded = systemAdded;
        
        return obj;
    }
};

#endif /* ARObjects_hpp */

