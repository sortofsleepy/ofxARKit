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

typedef std::shared_ptr<class ARProcessor>ARRef;

/**
     Processing class to help deal with ARKit stuff like grabbing and converting the camera feed,
     set anchors, etc.
 */
class ARProcessor {
    
    ARSession * session;

    float ambientIntensity;
    
    CGSize viewportSize;
    // ========== OBJECTS ==================== //
    ARAnchorManager * anchorController;
    ARDebugUtils::PointCloudDebug pointCloud;
    
    // ========== CAMERA IMAGE STUFF ================= //
    
    // fbo to process and render camera manager into
    ofFbo cameraFbo;
    
    // used to help correct perspective distortion for some devices.
    float zoomLevel;
    
    // flag to let the shader know if we need to tweak perspective
    bool needsPerspectiveAdjustment;
    
    // The device type
    NSString * deviceType;
    
    CVOpenGLESTextureRef yTexture;
    CVOpenGLESTextureRef CbCrTexture;
    CVOpenGLESTextureCacheRef _videoTextureCache;
    
    // mesh to render camera image
    ofMesh cameraPlane;
    
    // shader to color convert the camera image
    ofShader cameraConvertShader;
    
    // this handles rotating the camera image to the correct orientation.
    ofMatrix4x4 rotation;
    
    // joined object of both the transform and projection matrices
    ARCommon::ARCameraMatrices cameraMatrices;

    // a reference to the current frame in the scene
    ARFrame * currentFrame;
    
    // to help reduce resource strain, making building the camera frame optional
    bool shouldBuildCameraFrame;
    
    bool debugMode;
    

    // ================ PRIVATE FUNCTIONS =================== //

    
    // Converts the CVPixelBufferIndex into a OpenGL texture
    CVOpenGLESTextureRef createTextureFromPixelBuffer(CVPixelBufferRef pixelBuffer,int planeIndex,GLenum format=GL_LUMINANCE,int width=0,int height=0);
    
    // Constructs camera frame from pixel data
    void buildCameraFrame(CVPixelBufferRef pixelBuffer);
    
public:
    ARProcessor();
    ARProcessor(ARSession * session);
    ~ARProcessor();
    
    // creates a shared_ptr of an ARProcessor instance
    static ARRef create(ARSession * session){
        return ARRef(new ARProcessor(session));
    }
    
    // TODO maybe this should just not exist and force users to set a session.
    static ARRef create(){
        return ARRef(new ARProcessor());
    }
    
    // current orientation to use to get proper projection and view matrices
    UIInterfaceOrientation orientation;
    
    // returns the current ambient light intensity
    float getAmbientIntensity();
    
    // helper function to run ofLoadMatrix for projection and view matrices, using
    // the current camera matrices from ARKit.
    void setARCameraMatrices();

    // adds a new anchor
    // TODO deprecate
    void addAnchor();
    
    // pauses the current ARSession
    void pauseSession();
    
    // returns the current frame from the camera
    ARFrame* getCurrentFrame();
    
    void setup();
    void update();
    
    // draws the camera frame
    void draw();
    
    // alias for draw
    void drawCameraFrame();

    // draws horizontal planes (if detected)
    void drawHorizontalPlanes();
    
    // draws point cloud
    void drawPointCloud();


    //! Returns Projection and View matrices for the specified orientation.
    ARCommon::ARCameraMatrices getMatricesForOrientation(UIInterfaceOrientation orientation=UIInterfaceOrientationPortrait, float near=0.01,float far=1000.0);

    // returns the current projection matrix from the camera
    ofMatrix4x4 getProjectionMatrix(){
        return cameraMatrices.cameraProjection;
    }

    // returns the current view matrix from the camera
    ofMatrix4x4 getViewMatrix(){
        return cameraMatrices.cameraView;
    }

    // returns the current transform with the camera's position in AR space
    //TODO that is what the camera transform is I belive, need to double check
    ofMatrix4x4 getTransformMatrix(){
        return cameraMatrices.cameraTransform;
    }
    
    // returns a reference to the current set of camera matrices as seen by ARKit
    ARCommon::ARCameraMatrices getCameraMatrices(){
        return cameraMatrices;
    }
    
    ofTexture getCameraTexture(){
        return cameraFbo.getTexture();
    }
    
    std::vector<PlaneAnchorObject> getHorizontalPlanes(){
        return anchorController->getPlaneAnchors();
    }
    

    //! Function for enabling camera perspective correction for some devices.
    //! Iphones appear to be ok - but iPad's may need to have the camera image corrected slightly.
    //! This makes an attempt to do so automatically, but you can pass in a custom value.
    //! This function in particular sets the perspective correction level.
    void adjustPerspectiveCorrection(float zoomLevel=1.0);
    
};


#endif /* ARProcessor_hpp */
