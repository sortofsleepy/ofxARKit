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
#include "ARToolkitComponents.h"

#define STRINGIFY(A) #A

typedef std::shared_ptr<class ARProcessor>ARRef;

// joined camera matrices as one object.
typedef struct {
    ofMatrix4x4 cameraTransform;
    ofMatrix4x4 cameraProjection;
    ofMatrix4x4 cameraView;
}ARCameraMatrices;

/**
     Processing class to help deal with ARKit stuff like grabbing and converting the camera feed,
     set anchors, etc.
 */
class ARProcessor {
    
    ARSession * session;

    float ambientIntensity;
    
    ofVec2f viewportSize;
    
    // ========== CAMERA IMAGE STUFF ================= //
    ofFbo cameraFbo;
    ofVec2f bufferSize;
    bool bufferSizeSet;
    
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
    ARCameraMatrices cameraMatrices;

    // a reference to the current frame in the scene
    ARFrame * currentFrame;
    
    // to help reduce resource strain, making building the camera frame optional
    bool shouldBuildCameraFrame;

    // ========== SHADERS ================ //
    
    
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

    void updatePlanes();
    void addAnchor();
    void pauseSession();
    void startSession();
    
    void setup();
    void update();
    
    // draws the camera frame
    void draw();
    
    // alias for draw
    void drawCameraFrame();


    // TODO add matrix retrival for other orientations
    // ps thanks zach for finding this!
    ARCameraMatrices getMatricesForOrientation(UIInterfaceOrientation orientation=UIInterfaceOrientationPortrait, float near=0.01,float far=1000.0);

    ofMatrix4x4 getProjectionMatrix(){
        return cameraMatrices.cameraProjection;
    }

    ofMatrix4x4 getViewMatrix(){
        return cameraMatrices.cameraView;
    }

    ofMatrix4x4 getTransformMatrix(){
        return cameraMatrices.cameraTransform;
    }
    ARCameraMatrices getCameraMatrices(){
        return cameraMatrices;
    }

    // borrowed from https://github.com/wdlindmeier/Cinder-Metal/blob/master/include/MetalHelpers.hpp
    // helpful converting to and from SIMD 
    template <typename T, typename U >
    const U static inline convert( const T & t )
    {
        U tmp;
        memcpy(&tmp, &t, sizeof(U));
        U ret = tmp;
        return ret;
    }

  
};


#endif /* ARProcessor_hpp */
