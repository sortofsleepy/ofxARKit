//
//  ARAnchor.h
//
//  Created by Joseph Chow on 8/18/17
//  with support from contributors.
//

#ifndef ARAnchor_h
#define ARAnchor_h

#include "ofMain.h"
#include <vector>
#include <ARKit/ARKit.h>
#include "ARUtils.h"
#include "ARObjects.h"
using namespace ARObjects;

/**
 Basic helper class to help with managing anchors.
 Note that Apple specifies ARKit dimensions in "meters" as opposed to
 pixels like a regular oF app.
 */
namespace ARCore {
    typedef std::shared_ptr<class ARAnchorManager>AnchorManagerRef;

    class ARAnchorManager {

        //! Stores data of all currently found planes.
        std::vector<PlaneAnchorObject> planes;

        //! reference to all currently found or added regular anchors
        std::vector<ARObject> anchors;

#if AR_FACE_TRACKING
        //! Reference to all currently found faces
        std::vector<FaceAnchorObject> faces;
#endif
        
        //! The number of anchors currently found
        NSInteger anchorInstanceCount;

        //! The session to draw from
        ARSession * session;

        //! camera object to help draw the anchors
        ofCamera camera;

        //! The number of planes we want to be tracking at any given point.
        //! If 0 - it means we want to track every available plane
        int maxTrackedPlanes;

        //! The callback function to run when a plane is added.
        std::function<void(PlaneAnchorObject plane)> _onPlaneAdded;
    public:
        ARAnchorManager();
        ARAnchorManager(ARSession * session);

        //! Flag for whether or not planes should be updated
        bool shouldUpdatePlanes;

        //! Adds an anchor based on the current position of the camera - basically at (0,0) with a slight z offset.
        void addAnchor(float zZoom=-0.2);

        //! adds an anchor at the specified position.
        void addAnchor(ofVec3f position,ofMatrix4x4 projection,ofMatrix4x4 viewMatrix);

        //! adds an ARObject to be tracked by ARKit.
        void addAnchor(ARObject anchor);

        static AnchorManagerRef create(ARSession * session){
            if(!session){
                NSLog(@"Error - AnchorManagerRef requires an ARSession object");
            }else{
                return AnchorManagerRef(new ARAnchorManager(session));
            }
        }

        //! Sets the number of planes we want to track. By default, we track all available planes.
        void setNumberOfPlanesToTrack(int num=0);

        //! Returns the vector of currently found planes
        std::vector<PlaneAnchorObject> getPlaneAnchors(){
            return planes;
        }
#if AR_FACE_TRACKING
        std::vector<FaceAnchorObject> getFaces(){
            return faces;
        }
#endif

        //! Returns the current number of anchors.
        int getNumAnchors(){
            return anchors.size();
        }

        //! Allows you to loop through the anchors and do something
        //! with each anchor. Pass in a lambda function
        void loopAnchors(std::function<void(ARObject)> func);

        //! Allows you to loop through the anchors and do something
        //! with each anchor. Pass in a lambda function. Returns the current index in the loop
        //! as well as it's anchor.
        void loopAnchors(std::function<void(ARObject,int index)> func);

        //! Allows you to loop through planes and do something with each plane
        void loopPlaneAnchors(std::function<void(PlaneAnchorObject)> func);

        //! Allows you to loop through planes and do something with each plane
        void loopPlaneAnchors(std::function<void(PlaneAnchorObject,int index)> func);


        //! Returns the PlaneAnchorObject associated with found planes
        PlaneAnchorObject getPlaneAt(int index=0);

        //! Toggles whether or not planes should be updated at each iteration.
        void togglePlaneUpate(){
            shouldUpdatePlanes = !shouldUpdatePlanes;
        }

        //! same as above but removes the anchor directly from the ARSession instance.
        //! Note that it does not remove a corresponding ARObject though, but simply removes
        //! stuff directly from the session in an effort to provide another way to remove ARKit added objects.
        void removeAnchorDirectly(int index=0);

        //! clears all existing plane anchors being tracked.
        void clearPlaneAnchors();

        //! Removes a plane anchor based on it's UUID
        void removePlane(NSUUID * anchorId);

        //! removes a plane anchor based on it's index in the planes vector
        void removePlane(int index=0);

        //! Clears all existing anchors
        void clearAnchors();

        //! removes anchor with the specified uuid
        void removeAnchor(NSUUID * anchorId);

        //! removes the anchor with the specified index.
        void removeAnchor(int index=0);

        //! Get the number of planes detected.
        int getNumPlanes();

        //! Draws all currently found planes.
        void drawPlanes(ARCommon::ARCameraMatrices cameraMatrices);

        //! general update function, currently increments the counter to keep track of the number of system + user anchors.
        void update();

        //! update function for dealing with planes.
        void updatePlanes();

#if AR_FACE_TRACKING
        //! updates face tracking info
        void updateFaces();
#endif

        //! draw a specific plane
        void drawPlaneAt(ARCommon::ARCameraMatrices cameraMatrices,int index=0);

        //! Allows you to set a callback function to run when a new plane is added.
        //! Returns the reference to that plane.
        void onPlaneAdded(std::function<void(PlaneAnchorObject plane)> func);
    };
}

#endif /* ARAnchor_h */
