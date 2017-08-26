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

#define STRINGIFY(A) #A

typedef std::shared_ptr<class ARProcessor>ARRef;

/**
     Processing class to help deal with ARKit stuff like grabbing and converting the camera feed,
     set anchors, etc.
 */
class ARProcessor {
    
    ARSession * session;

    float ambientIntensity;
    
    CGSize viewportSize;
    // ========== ANCHORS ==================== //
    ARAnchorManager * anchorController;
    
    // ========== CAMERA IMAGE STUFF ================= //
    ofFbo cameraFbo;
    CVOpenGLESTextureRef yTexture;
    CVOpenGLESTextureRef CbCrTexture;
    CVOpenGLESTextureCacheRef _videoTextureCache;
    
    // mesh to render camera image
    ofMesh cameraPlane;
    
    // shader to color convert the camera image
    ofShader cameraConvertShader;
    
    // shader to render camera image
    ofShader cameraRenderShader;
    
    // this handles rotating the camera image to the correct orientation.
    ofMatrix4x4 rotation;
    
    // joined object of both the transform and projection matrices
    ARCommon::ARCameraMatrices cameraMatrices;

    // a reference to the current frame in the scene
    ARFrame * currentFrame;
    
    // to help reduce resource strain, making building the camera frame optional
    bool shouldBuildCameraFrame;
    
    bool debugMode;

    ARDebugUtils::PointCloudDebug pointCloud;
    // ================ PRIVATE FUNCTIONS =================== //

    
    // Converts the CVPixelBufferIndex into a OpenGL texture
    CVOpenGLESTextureRef createTextureFromPixelBuffer(CVPixelBufferRef pixelBuffer,int planeIndex,GLenum format=GL_LUMINANCE,int width=0,int height=0);
    
    // Constructs camera frame from pixel data
    void buildCameraFrame(CVPixelBufferRef pixelBuffer);
public:
    ARProcessor();
    ARProcessor(ARSession * session);
    ~ARProcessor();
    
    static ARRef create(ARSession * session){
        return ARRef(new ARProcessor(session));
    }
    static ARRef create(){
        return ARRef(new ARProcessor());
    }
    
    // current orientation to use to get proper projection and view matrices
    UIInterfaceOrientation orientation;
    
    float getAmbientIntensity();
    void setARCameraMatrices();

    void addAnchor();
    void pauseSession();
    
    ARFrame* getCurrentFrame();
    
    void setup();
    void update();
    
    // draws the camera frame
    void draw();
    
    // alias for draw
    void drawCameraFrame();


    // draws horizontal planes (if detected)
    void drawHorizontalPlanes();
    

    void drawPointCloud();

    // TODO add matrix retrival for other orientations
    // ps thanks zach for finding this!
    ARCommon::ARCameraMatrices getMatricesForOrientation(UIInterfaceOrientation orientation=UIInterfaceOrientationPortrait, float near=0.01,float far=1000.0);

    ofMatrix4x4 getProjectionMatrix(){
        return cameraMatrices.cameraProjection;
    }

    ofMatrix4x4 getViewMatrix(){
        return cameraMatrices.cameraView;
    }

    ofMatrix4x4 getTransformMatrix(){
        return cameraMatrices.cameraTransform;
    }
    ARCommon::ARCameraMatrices getCameraMatrices(){
        return cameraMatrices;
    }
    
    ofTexture getCameraTexture(){
        return cameraFbo.getTexture();
    }
    
    std::vector<PlaneAnchorObject> getHorizontalPlanes(){
        return anchorController->getPlaneAnchors();
    }
    
};


#endif /* ARProcessor_hpp */
