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
}PlaneAnchorObject;

typedef std::shared_ptr<class ARAnchorManager>AnchorManagerRef;

//! Helper class to deal with anchors
class ARAnchorManager {
    
    //! reference to the transform matrix of all currently found planes
    std::vector<PlaneAnchorObject> planes;
    
    //! reference to all currently found or added regular anchors
    std::vector<ofMatrix4x4> anchors;
    
    //! The number of anchors currently found
    NSInteger anchorInstanceCount;
    
    //! The session to draw from
    ARSession * session;
    
    //! camera object to help draw the anchors
#ifdef OF_TARGET_IPHONE
    ofCamera camera;
    
#endif
public:
    ARAnchorManager();
    ARAnchorManager(ARSession * session);
    
    void addAnchor();
    void addAnchor(ofVec2f position);
    
    
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
    //! with each anchor.
    void loopAnchors(std::function<void(ofMatrix4x4)> func);
    
    //! Returns the PlaneAnchorObject associated with found planes
    PlaneAnchorObject getPlaneAt(int index=0);
    
    //! Clears all existing anchors
    void clearAnchors();
    
    //! Get the number of planes detected.
    int getNumPlanes();
    
    void drawPlanes(ARCommon::ARCameraMatrices cameraMatrices);
    
    void update();
    
};

#endif /* ARAnchor_h */
