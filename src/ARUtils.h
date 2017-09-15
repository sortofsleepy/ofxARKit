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
    
    //! If you've had to pause the session for whatever reason, this will regenerate a new one.
    //! Pass in an alignment method for the ARKit to use in the new session. You can also specify as to whether
    //! or not audio data should get captured.
    //! Note that if audio data capture is desired, you need to set up your ARSession as part of a delegate class.
    //! and implement the session:didOutputAudioSampleBuffer: method.
    //! see https://developer.apple.com/documentation/arkit/arconfiguration/2923559-providesaudiodata?language=objc
    static ARSession* generateNewSession(ARWorldAlignment worldAlignment = ARWorldAlignmentCamera,bool providesAudio=false){
        
        ARSession * session = [ARSession new];
        
        // by default - we want to be able to detect planes. Check to see if that's possible
        if([ARWorldTrackingConfiguration isSupported]){
            
            ARWorldTrackingConfiguration * config = [ARWorldTrackingConfiguration new];
            config.planeDetection = ARPlaneDetectionHorizontal;
            config.lightEstimationEnabled = YES;
            config.worldAlignment = worldAlignment;
            
            
            // note that audio data is only available as part of a delegate class.
            if(providesAudio){
                config.providesAudioData = YES;
            }
            
            [session runWithConfiguration:config];
        }else {
            AROrientationTrackingConfiguration * config = [AROrientationTrackingConfiguration new];
            config.lightEstimationEnabled = YES;
            config.worldAlignment = worldAlignment;
            
            // note that audio data is only available as part of a delegate class.
            if(providesAudio){
                config.providesAudioData = YES;
            }
            
            [session runWithConfiguration:config];
        }
        
        
        return session;
    }
}



#endif /* ARToolkitComponents_h */
