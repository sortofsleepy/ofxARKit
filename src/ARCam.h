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
        
        // a vector to hold the native dimensions of the current device.
        ofVec2f nativeDimensions;
        
        // bounding objects used to calculated the scaled dimensions of the camera image in relation to the
        // device screen size
        ofRectangle cam,screen;
        
        // the amount to scale the camera image by
        float scaleVal;
        
        // The offset for how the image should be positioned.
        float xShift,yShift;
        
        // the dimensions of the calculated camera image. 
        ofVec2f cameraDimensions;
        
        //! Sets custom dimensions for drawing the camera image. 
        void setCameraImageDimensions(float x=0,float y = 0);
        
        // flag for debug mode.
        bool debugMode;
        
        //! current orientation to use to get proper projection and view matrices
        UIInterfaceOrientation orientation;
        
        //! The current device orientation;
        UIDeviceOrientation deviceOrientation;
        
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
        
        //! The near clip value to use when obtaining projection/view matrices
        float near;
        
        //! The far clip value to use when obtaining projection/view matrices
        float far;
        
        //! The current tracking state of the camera
        ARTrackingState trackingState;
        
        //! The reason for when a tracking state might be limited.
        ARTrackingStateReason trackingStateReason;
        
        // ========== PRIVATE FUNCTIONS =============== //
        
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
        
        //! Function to update and log the current tracking state from ARKit
        void logTrackingState();
        
        //! Get the current tracking state
        ARTrackingState getTrackingState();
        
        //! Toggles debug mode on/off
        void toggleDebug();
        
        //! used to help correct perspective distortion for some devices.
        float zoomLevel;
        
        //! Sets up all the necessary properties and values to get the camera running.
        void setup(bool debugMode=false);
        
        //! Updates camera values
        void update();
        
        //! draws the camera frame.
        void draw();
        
        void updatePlaneTexCoords();
        
        //! Sets the x and y position of where the camera image is placed.
        void setCameraImagePosition(float xShift=0,float yShift=0);
        
        //! Returns the calculated bounds of the camera image.
        //! Useful in calculating the x and y pos of the camera image.
        ofRectangle getCameraImageBounds();
        
        //! retrieves the current lighting conditions that ARKit is seeing.
        ARLightEstimate* getLightingConditions();
        
        //! Returns the ambient intensity of the lighting
        float getAmbientIntensity();
        
        //! helper function to run ofLoadMatrix for projection and view matrices, using
        //! the current camera matrices from ARKit.
        void setARCameraMatrices();
        
        //! sets the camera's near clip distance
        void setCameraNearClip(float near);
        
        //! sets camera far clip distance
        void setCameraFarClip(float far);
        
        //! Adjusts the camera image rotation
        void updateDeviceOrientation();
        
        //! Allows you to set a custom value for how to rotate the camera image.
        //! Keep in mind that by default - the camera image is shown rotated -90 degrees when
        //! your device is held in a portrait form and that this class already rotates the image 90 degrees on
        //! iPhone and a further -90 degrees on iPad(done to help correct image scaling issues)
        void updateRotationMatrix(float angle);
        
        //! adjusts the perspective correction zoom(Note: primarily for larger devices)
        void adjustPerspectiveCorrection(float zoomLevel);
        
        //! Updates the current Interface orientation setting so camera projection/view matrices remain correct.
        void updateInterfaceOrientation();
        
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

