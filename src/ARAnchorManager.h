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
#include "ARToolkitComponents.h"

typedef struct {
    ofVec3f position;
    float width;
    float height;
    ofMatrix4x4 transform;
}PlaneAnchorObject;

class ARAnchorManager {
    
    //! reference to the transform matrix of all currently found planes
    std::vector<PlaneAnchorObject> planes;
    
    //! The number of anchors currently found
    NSInteger anchorInstanceCount;
    
    //! The session to draw from
    ARSession * session;
    
public:
    ARAnchorManager();
    ARAnchorManager(ARSession * session);
    
    
    //! Returns the vector of currently found planes
    std::vector<PlaneAnchorObject> getPlaneAnchors(){
        return planes;
    }
    
    void update();
    
};

#endif /* ARAnchor_h */
