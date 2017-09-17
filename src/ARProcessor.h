//
//  ARProcessor.hpp
//
//  Created by Joseph Chow on 8/4/17.
//  With additional help by contributors.
//

#ifndef ARProcessor_hpp
#define ARProcessor_hpp


#include "ofMain.h"
#include "ofxiOS.h"
#include <memory>
#include <ARKit/ARKit.h>
#include "ARUtils.h"
#include "ARShaders.h"
#include "ARAnchorManager.h"
#include "ARDebugUtils.h"
#include "ARCam.h"
#include "ARSessionSetup.h"

typedef std::shared_ptr<class ARProcessor>ARRef;

//! An API class for doing things in ARKit. Consider this the kitchen sink of everything,
//! consisting of all possible functionality currently offered by the addon.
class ARProcessor {
    
    //! A reference to the ARSession
    ARSession * session;

    //! A flag to indicate whether or not we're in debug mode
    bool debugMode;
    
public:
    //! Default constructor
    ARProcessor();
    
    //! Constructor - pass in ARSession reference
    ARProcessor(ARSession * session);
    
    //! Destructor
    ~ARProcessor();
    
    //! creates a new ARRef
    static ARRef create(ARSession * session){
        return ARRef(new ARProcessor(session));
    }
    
    //! Sets up all the necessary components for ARKit
    void setup();
    
    //! Updates all the ARKit components
    void update();
    
    //! Draws the camera frame
    void draw();
    
    //! Alias for drawing the camera frame for better semantics
    void drawFrame();
    
    //! Pauses the ARKit session
    void pauseSession();
    
    //! Restarts ARKit session
    //! TODO needs testing - unknown if we can just pull the previous config. 
    void restartSession();
    
    void toggleDebug(){
        debugMode = !debugMode;
    }
    // ========== OBJECTS ==================== //
    
    //! An ARAnchorManager deals with handling Anchor objects in ARKit
    ARCore::AnchorManagerRef anchorController;
    
    //! A debug class to help debug when features are detected
    ARDebugUtils::PointCloudDebug pointCloud;
    
    //! A class to handle camera functionality.
    ARCore::ARCamRef camera;
    
    //======== DEBUG API ============ //
    
    //! draws point cloud
    void drawPointCloud();

    //======== ANCHORS API ============ //
    void addAnchor(float zZoom);
    void addAnchor(ofVec3f position);
    //======== PLANE API ============ //

    //! Returns the current set of horizontal planes.
    std::vector<PlaneAnchorObject> getHorizontalPlanes(){
        return anchorController->getPlaneAnchors();
    }
    
    //! Draws the current set of horizontal planes
    void drawHorizontalPlanes();
    
    //! updates plane information
    void updatePlanes();
    
   //======== CAMERA API ============ //
    
    void deviceOrientationChanged();
    
    void updateDeviceInterfaceOrientation();
    
    void rotateCameraFrame(float angle);
    
    //! Helper to quickly set up ARKit projection and view matrices for 2D drawing in oF
    void setARCameraMatrices();
    
    //! adjusts the perspective correction zoom(Note: primarily for larger devices)
    void adjustPerspectiveCorrection(float zoomLevel);
    
    //! Returns Projection and View matrices for the specified orientation.
    ARCommon::ARCameraMatrices getMatricesForOrientation(UIInterfaceOrientation orientation=UIInterfaceOrientationPortrait, float near=0.01,float far=1000.0);
    
    //! Return the camera image as a texture.
    ofTexture getCameraTexture(){
        return camera->getCameraTexture();
    }
    
    //! Get the camera matrix set
    ARCommon::ARCameraMatrices getCameraMatrices(){
        return camera->getCameraMatrices();
    }
    
    // returns the current projection matrix from the camera
    ofMatrix4x4 getProjectionMatrix(){
        return camera->getProjectionMatrix();
    }
    
    //! returns the current view matrix from the camera
    ofMatrix4x4 getViewMatrix(){
        return camera->getViewMatrix();
    }
    
    //! Returns the camera's current transform matrix.
    ofMatrix4x4 getCameraTransformMatrix(){
        return camera->getTransformMatrix();
    }
    
    //! Returns the camera's FBO.
    ofFbo getFBO(){
        return camera->getFBO();
    }
};


#endif /* ARProcessor_hpp */
