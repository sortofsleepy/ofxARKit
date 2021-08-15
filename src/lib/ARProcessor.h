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
#include "ARSessionSetup.h"
#include "Camera.h"



namespace ofxARKit {
    typedef std::shared_ptr<class ARProcessor>ARRef;

    //! An API class for doing things in ARKit. Consider this the kitchen sink of everything,
    //! consisting of all possible functionality currently offered by the addon.
    class ARProcessor {
        
        //! A reference to the ARSession
        ARSession * session;
        
        //! A flag to indicate whether or not we're in debug mode
        bool debugMode;
        
    protected:
        //! ARReferenceImages
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_3
        vector<ARReferenceImage * > arRefImages;
#endif
    public:
        //! Constructor - pass in ARSession reference
        ARProcessor(ARSession * session);
        
        //! Destructor
        ~ARProcessor();
        
        //! creates a new ARRef
        static ARRef create(ARSession * session){
            return ARRef(new ARProcessor(session));
        }
        
        //! Sets up all the necessary components for ARKit
        void setup(bool debugMode=false);
        
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
        
        //! Toggles debug mode
        void toggleDebug();

        // ========== OBJECTS ==================== //
        
        //! An ARAnchorManager deals with handling Anchor objects in ARKit
        core::AnchorManagerRef anchorController;
        
        //! A debug class to help visualize feature detection.
        ofxARKit::PointCloudDebug pointCloud;
        
        //! Debug class to help render common debugging information.
        ofxARKit::ARDebugInfo debugInfo;
        
        //! A class to handle camera functionality.
        ofxARKit::core::CameraRef camera;
        
        //! Returns the current tracking state of the ARKit framework.
        ARTrackingStateReason getTrackingState();
        
        //! Logs the current tracking state of the ARKit framework.
        void logTrackingState();
        
        //======== DEBUG API ============ //
        
        //! draws point cloud
        void drawPointCloud();
        
        //======== ANCHORS API ============ //
        
        //! Adds an anchor at the origin. Allows to optionally pass in a custom z value.
        void addAnchor(float zZoom=-0.2);
        
        //! Adds an anchor at a specified position. Note that z value is up to you to set.
        void addAnchor(ofVec3f position);
        //======== PLANE API ============ //
        
        //! Returns the current set of planes.
        std::vector<PlaneAnchorObject> getPlanes(){
            return anchorController->getPlaneAnchors();
            
        }
        
        float getLightTemperature();
        float getLightIntensity();
        
     

        //! Draw horizontal planes
        void drawHorizontalPlanes();
        
        //! Draws the current set of planes
        void drawPlanes();
        
        //! Draws the current set of plane meshes
        void drawPlaneMeshes();
        
        //! updates plane information
        void updatePlanes();
        
        void updateImages();
        
        //! Helps ensure we are able to start making use of
        //! ARKit found features.
        bool isValidFrame(){
            if(session.currentFrame){
                if(session.currentFrame.camera){
                    return true;
                }
            }else{
                return false;
            }
        }
        //! returns raw ARImageReference array
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_3
        vector<ARReferenceImage *> & getARReferenceImages();
#endif
        //======== IMAGE API ============ //
        // to-do: make other getters return reference—lots of copying happening!
        // to-do: probably should be getImages() const
        std::vector<ImageAnchorObject>  getImages(){
            return anchorController->getImageAnchors();
        }
        
        //! returns a list of names of all reference images
        vector<string> getReferenceImages();
        
        //======== FACE API ============ //
#if AR_FACE_TRACKING
        void updateFaces();
        std::vector<FaceAnchorObject> getFaces();
#endif
        

        //======== MATTE API ============ //
#if defined( __IPHONE_13_0 )

        //! Returns the alpha texture from matte generator
        CVOpenGLESTextureRef getTextureMatteAlpha(){ return camera->getTextureMatteAlpha();}

        //! Returns the depth texture from the matte generator
        CVOpenGLESTextureRef getTextureMatteDepth(){ return camera->getTextureMatteDepth();}

        //! returns the depth texture from the camera
        CVOpenGLESTextureRef getTextureDepth(){ return camera->getTextureDepth();}

        // Returns the affine transformation matrix used to do person segmentation.
        ofMatrix3x3 getAffineTransform(){ return camera->getAffineTransform();}

        //! Draws a debug view of camera image along with person segmentation

//        void drawCameraDebugPersonSegmentation(){ camera->drawDebugPersonSegmentation(); }

#endif
        
    
        
        
        //======== CAMERA API ============ //
        
        //! In the event a device is used while locking the orientation, this allows you to
        //! force a certain interface orientation so you can still obtain the correct camera matrices.
        void forceInterfaceOrientation(UIInterfaceOrientation orientation);
        
        //! Signals when the device orientation has changed - which also adjusts
        //! rotation of the camera image depending on the orientation.
        void deviceOrientationChanged(int newOrientation);
        
        //! Returns the camera's current transform matrix as a vec3.
        glm::vec3 getCameraPosition();
        
        //! Helper to quickly set up ARKit projection and view matrices for 2D drawing in oF
        void setARCameraMatrices();
        
        //! Returns Projection and View matrices for the specified orientation.
        ofxARKit::common::ARCameraMatrices getMatricesForOrientation(UIInterfaceOrientation orientation=UIInterfaceOrientationPortrait, float near=0.01,float far=1000.0);
        
        //! Return the camera image as a texture.
        CVOpenGLESTextureRef getCameraTexture(){return camera->getTexture();}
        
        //! Get the camera matrix set
        ofxARKit::common::ARCameraMatrices getCameraMatrices();
        
        // returns the current projection matrix from the camera
        ofMatrix4x4 getProjectionMatrix(){
            return camera->getCameraMatrices().cameraProjection;
            
        }
        
        //! returns the current view matrix from the camera
        ofMatrix4x4 getViewMatrix(){
            return camera->getCameraMatrices().cameraView;
        }
        
        //! Returns the camera's current transform matrix.
        ofMatrix4x4 getCameraTransformMatrix(){
            return camera->getCameraMatrices().cameraTransform;
        }
        
    };

}

#endif /* ARProcessor_hpp */
