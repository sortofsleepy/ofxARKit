//
//  ARUtils
//
//  Created by Joseph Chow on 8/16/17.
//

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
    const ofMatrix4x4 static inline toMat4( const matrix_float4x4& mat ) {
        return convert<matrix_float4x4, ofMatrix4x4>(mat);
    }
    
    //! convert to simd based mat4
    const matrix_float4x4 toSIMDMat4(ofMatrix4x4 &mat){
           return convert<ofMatrix4x4,matrix_float4x4>(mat);
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
    
    
   
    //! Gets the official resolution of the device you're currently using under the assumption that the width/height
    //! matches the current orientation your device is in(ie landscape gives longer width than portrait)
    //! x should be considered the width, y should be considered the height.
    static ofVec2f getDeviceDimensions(){
        CGRect screenBounds = [[UIScreen mainScreen] nativeBounds];
        
        ofVec2f dimensions;
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        
        switch(orientation){
            
            case 0:
                 dimensions = ofVec2f(screenBounds.size.width, screenBounds.size.height);
                break;

            case UIInterfaceOrientationPortrait:
                  dimensions = ofVec2f(screenBounds.size.width, screenBounds.size.height);
                break;
                
            case UIInterfaceOrientationLandscapeLeft:
                dimensions = ofVec2f(screenBounds.size.height, screenBounds.size.width);
                break;
                
            case UIInterfaceOrientationLandscapeRight:
                  dimensions = ofVec2f(screenBounds.size.height, screenBounds.size.width);
                break;
        }
        
        
        return dimensions;
    }
    
    //! Returns the devices aspect ratio.
    static float getAspectRatio(){
        ofVec2f screenSize = getDeviceDimensions();
        return screenSize.x / screenSize.y;
    }
}



#endif /* ARToolkitComponents_h */
