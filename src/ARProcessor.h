//
//  ARProcessor.hpp
//  ARToolkit
//
//  Created by Joseph Chow on 8/4/17.
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

typedef std::shared_ptr<class ARProcessor>ARRef;

/**
     Processing class to help deal with ARKit stuff like grabbing and converting the camera feed,
     set anchors, etc.
 */
class ARProcessor {
    
    ARSession * session;

  
    bool debugMode;
    
public:
    ARProcessor();
    ARProcessor(ARSession * session);
    ~ARProcessor();
    
    static ARRef create(ARSession * session){
        return ARRef(new ARProcessor(session));
    }
    
    void setup();
    void update();
    void draw();
    void drawFrame();
    void pauseSession();
    
    // ========== OBJECTS ==================== //
    
    // An ARAnchorManager deals with handling Anchor objects in ARKit
    ARCore::ARAnchorManager * anchorController;
    
    // A debug class to help debug when features are detected
    ARDebugUtils::PointCloudDebug pointCloud;
    
    // A class to handle camera functionality.
    ARCore::ARCamRef camera;
    
    //======== DEBUG API ============ //
    
    // draws point cloud
    void drawPointCloud();

    
    //======== PLANE API ============ //

    std::vector<PlaneAnchorObject> getHorizontalPlanes(){
        return anchorController->getPlaneAnchors();
    }
    
    void drawHorizontalPlanes();
    
   //======== CAMERA API ============ //
    
   
    void setARCameraMatrices();
    
    //! Returns Projection and View matrices for the specified orientation.
    ARCommon::ARCameraMatrices getMatricesForOrientation(UIInterfaceOrientation orientation=UIInterfaceOrientationPortrait, float near=0.01,float far=1000.0);
    ofTexture getCameraTexture(){
        return camera->getCameraTexture();
    }
};


#endif /* ARProcessor_hpp */
