//
//  ARCam.hpp
//
//  Created by Joseph Chow on 8/29/17
//  Additional support from contributors.
//

#ifndef ARCam_hpp
#define ARCam_hpp

#include <stdio.h>
#include <ARKit/ARKit.h>
#include "ARUtils.h"
#include "ARShaders.h"
#include "ARAnchorManager.h"
#include "ARDebugUtils.h"

namespace ARCore {
    
    typedef std::shared_ptr<class ARCam>ARCamRef;
    
    //! This class manages dealing with the camera image coming in from ARKit.
    class ARCam {
        //! current orientation to use to get proper projection and view matrices
        UIInterfaceOrientation orientation;
        
        //! a reference to an ARSession object
        ARSession * session;
        
        //! the current ambient light intensity
        float ambientIntensity;
        
        //! the current ambient color temperature
        float ambientColorTemperature;
        
        //! size of the viewport
        CGSize viewportSize;
        
        //! fbo to process and render camera manager into
        ofFbo cameraFbo;
        
        //! flag to let the shader know if we need to tweak perspective
        bool needsPerspectiveAdjustment;
        
        //! The device type
        NSString * deviceType;
        
        CVOpenGLESTextureRef yTexture;
        CVOpenGLESTextureRef CbCrTexture;
        CVOpenGLESTextureCacheRef _videoTextureCache;
        
        //! mesh to render camera image
        ofMesh cameraPlane;
        
        //! shader to color convert the camera image
        ofShader cameraConvertShader;
        
        //! this handles rotating the camera image to the correct orientation.
        ofMatrix4x4 rotation;
        
        //! joined object of both the transform and projection matrices
        ARCommon::ARCameraMatrices cameraMatrices;
        
        //! a reference to the current frame in the scene
        ARFrame * currentFrame;
        
        //! to help reduce resource strain, making building the camera frame optional
        bool shouldBuildCameraFrame;
        
        //! indicates whether or not we're in a debug mode
        bool debugMode;
        
        //! The near clip value to use when obtaining projection/view matrices
        float near;
        
        //! The far clip value to use when obtaining projection/view matrices
        float far;
        
        //! Converts the CVPixelBufferIndex into a OpenGL texture
        CVOpenGLESTextureRef createTextureFromPixelBuffer(CVPixelBufferRef pixelBuffer,int planeIndex,GLenum format=GL_LUMINANCE,int width=0,int height=0);
        
        //! Constructs camera frame from pixel data
        void buildCameraFrame(CVPixelBufferRef pixelBuffer);
        
    public:
        
        ARCam(ARSession * session);
        
        //! Creates a new ARCam reference
        static ARCamRef create(ARSession * session){
            return ARCamRef(new ARCam(session));
        }
        
        //! used to help correct perspective distortion for some devices.
        float zoomLevel;
        
        //! Sets up all the necessary properties and values to get the camera running.
        void setup();
        
        //! Updates camera values
        void update();
        
        //! draws the camera frame.
        void draw();
        
        //! retrieves the current lighting conditions that ARKit is seeing.
        ARLightEstimate* getLightingConditions();
        
        //! helper function to run ofLoadMatrix for projection and view matrices, using
        //! the current camera matrices from ARKit.
        void setARCameraMatrices();
        
        //! sets the camera's near clip distance
        void setCameraNearClip(float near);
        
        //! sets camera far clip distance
        void setCameraFarClip(float far);
        
        //! sets the device orientation at which to construct camera matrices
        //void setDeviceOrientation(UIInterfaceOrientation orientation);
        
        //! Adjusts the camera image rotation
        void updateDeviceOrientation();
        
        //! adjusts the perspective correction zoom(Note: primarily for larger devices)
        void adjustPerspectiveCorrection(float zoomLevel);
        
        //! Returns Projection and View matrices for the specified orientation.
        ARCommon::ARCameraMatrices getMatricesForOrientation(UIInterfaceOrientation orientation=UIInterfaceOrientationPortrait, float near=1.0,float far=1000.0);
        
        //! returns the current projection matrix from the camera
        ofMatrix4x4 getProjectionMatrix(){
            return cameraMatrices.cameraProjection;
        }
        
        //! returns the current view matrix from the camera
        ofMatrix4x4 getViewMatrix(){
            return cameraMatrices.cameraView;
        }
        
        //! returns the current transform with the camera's position in AR space
        ofMatrix4x4 getTransformMatrix(){
            return cameraMatrices.cameraTransform;
        }
        
        //! returns a reference to the current set of camera matrices as seen by ARKit
        ARCommon::ARCameraMatrices getCameraMatrices(){
            return cameraMatrices;
        }
        
        //! Returns the converted texture coming from ARKit after converting both layers to a single image.
        ofTexture getCameraTexture(){
            return cameraFbo.getTexture();
        }
        
        //! Returns the FBO used to join the camera image.
        ofFbo getFBO(){
            return cameraFbo;
        }
    };
}

#endif /* ARCamera_hpp */
