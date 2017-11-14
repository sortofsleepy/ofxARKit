//
//  ARUtils
//
//  Created by Joseph Chow on 8/16/17.
//
#pragma once

#ifndef ARToolkitComponents_h
#define ARToolkitComponents_h

#define STRINGIFY(A) #A
#include "ofMain.h"

namespace ARCommon {
    
    //! joined camera matrices as one object.
    typedef struct {
        ofMatrix4x4 cameraTransform;
        ofMatrix4x4 cameraProjection;
        ofMatrix4x4 cameraView;
    }ARCameraMatrices;
    
    //! borrowed from https://github.com/wdlindmeier/Cinder-Metal/blob/master/include/MetalHelpers.hpp
    //! helpful converting to and from SIMD
    template <typename T, typename U >
    const U static inline convert( const T & t )
    {
        U tmp;
        memcpy(&tmp, &t, sizeof(U));
        U ret = tmp;
        return ret;
    }
    
    //! convert to oF mat4
    static const ofMatrix4x4 static inline toMat4( const matrix_float4x4& mat ) {
        return convert<matrix_float4x4, ofMatrix4x4>(mat);
    }
    
    //! convert to simd based mat4
    static const matrix_float4x4 toSIMDMat4(ofMatrix4x4 &mat){
        return convert<ofMatrix4x4,matrix_float4x4>(mat);
    }
    
    //! Extracts the xyz position from a matrix. It's assumed that the matrix you pass in
    //! is based off of a ARKit transform matrix which appears to switch some things around.
    static ofVec3f getAnchorXYZ(ofMatrix4x4 mat){
        ofVec3f vec(mat.getRowAsVec3f(3));
        return ofVec3f(vec.y,vec.x,vec.z);
    }
    
    //! Constructs a generalized model matrix for a SIMD mat4
    static ofMatrix4x4 modelMatFromTransform( matrix_float4x4 transform )
    {
        matrix_float4x4 coordinateSpaceTransform = matrix_identity_float4x4;
        // Flip Z axis to convert geometry from right handed to left handed
        coordinateSpaceTransform.columns[2].z = -1.0;
        matrix_float4x4 modelMat = matrix_multiply(transform, coordinateSpaceTransform);
        return toMat4( modelMat );
    }
    
    //! Returns the device dimensions. Pass in true if you want to return the dimensions in pixels. Note that
    //! when in pixels, the value is not orientation aware as opposed to getting things in points.
    static ofVec2f getDeviceDimensions(bool useNative=false){
        CGRect screenBounds;
        ofVec2f dimensions;
        
        // depending on whether or not we want pixels or points, run the correct function.
        // Note that, when points are requested, they are for some reason, the opposite of what they should be.
        if(useNative){
            screenBounds = [[UIScreen mainScreen] nativeBounds];
        }else{
            screenBounds = [[UIScreen mainScreen] bounds];
        }
        
        // set the final width and height we want to send back
        float width,height;
        
        // function to set width and height - takes the odd behavior associated with requesting points
        // into account.
        auto setWidthAndHeight = [&]()->void {
            
            if(!useNative){
                width = screenBounds.size.height;
                height = screenBounds.size.width;
            }else{
                width = screenBounds.size.width;
                height = screenBounds.size.height;
            }
            
        };
        
        // Set the dimensions as appropriate depending on our orientation.
        // Note that for some reason, and I'm not sure if it's an oF, IOS or mistake on my part, but the first time
        // it enters this switch block, dimensions are off, so there is an nested if statement to try and fix that in
        // some of the cases.
        switch(UIDevice.currentDevice.orientation){
            case UIDeviceOrientationFaceUp:
                setWidthAndHeight();
                
                // if face up - we just assume portrait
                dimensions.x = width;
                dimensions.y = height;
                break;
                
            case UIDeviceOrientationFaceDown:
                setWidthAndHeight();
                
                // if face up - we just assume portrait
                dimensions.x = width;
                dimensions.y = height;
                break;
            case UIInterfaceOrientationUnknown:
                // if unknown - we just assume portrait
                dimensions.x = width;
                dimensions.y = height;
                break;
                
                // upside down registers, but for some reason nothing happens and there might be weirdness :/
                // leaving this here anyways but probably best to just disable upsidedown portrait.
            case UIInterfaceOrientationPortraitUpsideDown:
                setWidthAndHeight();
                
                dimensions.x = width;
                dimensions.y = height;
                
                if(width > height){
                    dimensions.x = height;
                    dimensions.y = width;
                }else{
                    dimensions.x = width;
                    dimensions.y = height;
                }
                break;
                
            case UIInterfaceOrientationPortrait:
                setWidthAndHeight();
                
                
                if(width > height){
                    dimensions.x = height;
                    dimensions.y = width;
                }else{
                    dimensions.x = width;
                    dimensions.y = height;
                }
                break;
                
            case UIInterfaceOrientationLandscapeLeft:
                setWidthAndHeight();
                
                if(useNative){
                    dimensions.x = height;
                    dimensions.y = width;
                }else{
                    if(width < height){
                        dimensions.x = height;
                        dimensions.y = width;
                    }else{
                        dimensions.x = width;
                        dimensions.y = height;
                    }
                }
                
                break;
                
            case UIInterfaceOrientationLandscapeRight:
                setWidthAndHeight();
                
                if(useNative){
                    dimensions.x = height;
                    dimensions.y = width;
                }else{
                    if(width < height){
                        dimensions.x = height;
                        dimensions.y = width;
                    }else{
                        dimensions.x = width;
                        dimensions.y = height;
                    }
                }
                
                break;
        }
        
        return dimensions;
    }
    
    //! Returns the native aspect ratio in pixels.
    static float getNativeAspectRatio(){
        
        ofVec2f dimensions = getDeviceDimensions(true);
        return dimensions.x / dimensions.y;
    }
    
    //! Returns the aspect ratio in points.
    static float getAspectRatio(){
        ofVec2f dimensions = getDeviceDimensions();
        return dimensions.x / dimensions.y;
    }
    
    // convert world xyz position to screen position.
    // TODO maybe this is what we ought to use instead to factor in orientation? Found on 11/7/17
    // https://developer.apple.com/documentation/arkit/arcamera/2923538-projectpoint?language=objc
    static ofVec2f worldToScreen(ofPoint worldPoint,ofMatrix4x4 projection,ofMatrix4x4 view){
        
        ofVec4f p =  ofVec4f(worldPoint.x, worldPoint.y, worldPoint.z, 1.0);
        
        p = p * view;
        p = p * projection;
        
        p /= p.w;
        
        // convert coords to 0 - 1
        p.x = p.x * 0.5 + 0.5;
        p.y = p.y * 0.5 + 0.5;
        
        // convert coords to pixels
        p.x *= ofGetWidth();
        p.y *= ofGetHeight();
        return ofVec2f(p.x, p.y);
    }
    
    //! Convert screen position to a  world position. 
    static ofVec4f screenToWorld(ofVec3f position,ofMatrix4x4 projection,ofMatrix4x4 mvMatrix){
        ofRectangle viewport(0,0,ofGetWindowWidth(),ofGetWindowHeight());
        
        ofVec4f CameraXYZ;
        CameraXYZ.x = 2.0f * (position.x - viewport.x) / viewport.width - 1.0f;
        CameraXYZ.y = 1.0f - 2.0f *(position.y - viewport.y) / viewport.height;
        CameraXYZ.z = position.z;
        CameraXYZ.w = -10.0;
        
        ofMatrix4x4 inverseCamera;
        inverseCamera.makeInvertOf(mvMatrix * projection);
        
        return CameraXYZ * inverseCamera;
    }
}



#endif /* ARToolkitComponents_h */

