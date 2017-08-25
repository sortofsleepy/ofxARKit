//
//  ARAnchor.h
//  GeoBeats
//
//  Created by Joseph Chow on 8/18/17.
//

#ifndef ARAnchor_h
#define ARAnchor_h

#include "ofMain.h"
#include <vector>
#include <ARKit/ARKit.h>
#include "ARUtils.h"

typedef struct {
    ofVec3f position;
    float width;
    float height;
    ofMatrix4x4 transform;
    NSUUID * uuid;
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

typedef std::shared_ptr<class ARAnchorManager>AnchorManagerRef;

//! Helper class to deal with anchors
class ARAnchorManager {
    
    //! reference to the transform matrix of all currently found planes
    std::vector<PlaneAnchorObject> planes;
    
    //! reference to all currently found or added regular anchors
    std::vector<ARObject> anchors;
    
    //! The number of anchors currently found
    NSInteger anchorInstanceCount;
    
    //! The session to draw from
    ARSession * session;
    
    //! camera object to help draw the anchors
#ifdef OF_TARGET_IPHONE
    ofCamera camera;
#endif
    
    bool shouldLookForPlanes;
    ofCamera transformCamera;
    ARObject buildARObject(ARAnchor * rawAnchor,ofMatrix4x4 modelMatrix,bool systemAdded=false);
public:
    ARAnchorManager();
    ARAnchorManager(ARSession * session);
    
    // a way to loop through existing regular anchors and 
    dispatch_queue_t uuid_check;
    
    //! Adds an anchor based on the current position of the camera - basically at (0,0) with a slight z offset.
    void addAnchor();
    
    //! adds an anchor at the specified position. Expects normalized coordinates
    void addAnchor(ofVec2f position,ARCommon::ARCameraMatrices cameraMatrices);
    
    //! adds an ARObject to be tracked by ARKit.
    void addAnchor(ARObject anchor);
    
    static AnchorManagerRef create(ARSession * session){
        if(!session){
            NSLog(@"Error - AnchorManagerRef requires an ARSession object");
        }else{
            return AnchorManagerRef(new ARAnchorManager(session));
        }
    }
    
    //! Returns the vector of currently found planes
    std::vector<PlaneAnchorObject> getPlaneAnchors(){
        return planes;
    }
    
    //! Allows you to loop through the anchors and do something
    //! with each anchor. Pass in a lambda function
    void loopAnchors(std::function<void(ARObject)> func);
    
    //! Returns the PlaneAnchorObject associated with found planes
    PlaneAnchorObject getPlaneAt(int index=0);
    
    //! Clears all existing anchors
    void clearAnchors();
    
    //! removes anchor with the specified uuid
    void removeAnchor(NSUUID * anchorId);
    
    //! removes the anchor with the specified index.
    void removeAnchor(int index=0);
    
    //! Get the number of planes detected.
    int getNumPlanes();
    
    void drawPlanes(ARCommon::ARCameraMatrices cameraMatrices);
    
    void update();
    
};

#endif /* ARAnchor_h */
