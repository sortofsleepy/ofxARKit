//
//  SessionSetup.h
//
//  Created by Joseph Chow on 11/16/17.
//  Copyright © 2017 Joseph Chow. All rights reserved.
//

#ifndef SessionSetup_h
#define SessionSetup_h

namespace ARCore {
    
    typedef struct {
        bool useFaceTracking = false;
        bool usePlaneTracking = false;
        bool useLightEstimation = false;
        bool useAudio = false;
        NSObject<ARSessionDelegate> * delegateClass = NULL;
        
        // the options for alignment are -
        // 1. ARWorldAlignmentCamera - https://developer.apple.com/documentation/arkit/arworldalignment/arworldalignmentcamera?language=objc
        // 2. ARWorldAlignmentGravityAndHeading - https://developer.apple.com/documentation/arkit/arworldalignment/arworldalignmentgravityandheading?language=objc
        // 3. ARWorldAlignmentGravity - https://developer.apple.com/documentation/arkit/arworldalignment/arworldalignmentgravity?language=objc
        
        ARWorldAlignment worldAlignment = ARWorldAlignmentGravity;
        ARPlaneDetection planeDetectionType;
    }FormatState;
    
    class SFormat {
        
      
        FormatState state;
     
        
    public:
        SFormat(){};
        
       
        FormatState getState(){
            return state;
        }
        
        NSObject<ARSessionDelegate> * getAudioState(){
            return state.delegateClass;
        }
        
        SFormat& enableLighting(){
            state.useLightEstimation = true;
            return *this;
        }
        
        SFormat& enableFaceTracking(){
            state.useFaceTracking = true;
            return *this;
        }
        
        SFormat& enablePlaneTracking(ARPlaneDetection planeDetectionType=ARPlaneDetectionHorizontal){
            // not all devices can support plane tracking, check first to make sure it's supported.
            if([ARWorldTrackingConfiguration isSupported]){
                state.usePlaneTracking = true;
                state.planeDetectionType = planeDetectionType;
            }else {
                NSLog(@"This device is unfortunately unable to use plane tracking");
            }
            
            return *this;
        }
        
        void enableAudio(NSObject<ARSessionDelegate> * delegateClass){
            state.delegateClass = delegateClass;
        }
    };
    
    //! Generates a new ARSession object. Pass in a SFormat object describing the
    //! settings you want to enable on the session.
    static ARSession * generateNewSession(SFormat format){
        ARSession * session = [ARSession new];
        
        auto state = format.getState();
        
       
        
        // first check if we want face tracking and if it's supported.
        if(state.useFaceTracking){
            
            if([ARFaceTrackingConfiguration isSupported]){
                ARFaceTrackingConfiguration * config = [ARFaceTrackingConfiguration new];
                
                if(state.useLightEstimation){
                    config.lightEstimationEnabled = YES;
                }
                
                config.worldAlignment = state.worldAlignment;
                
                if(state.delegateClass != NULL){
                    session.delegate = state.delegateClass;
                    
                    // note that audio is only available when you use a delegate class.
                    if(state.useAudio){
                        config.providesAudioData = YES;
                    }
                }
                
                [session runWithConfiguration:config];
                
                return session;
            }else{
                NSLog(@"Unable to use face tracking configuration, defaulting to a more standard config.");
            }
        }
        
        
        if([ARWorldTrackingConfiguration isSupported]){
            
            ARWorldTrackingConfiguration * config = [ARWorldTrackingConfiguration new];
            
            if(state.usePlaneTracking){
                // ofLog()<<"Using plane tracking";
                config.planeDetection = state.planeDetectionType;
            }
            
            if(state.useLightEstimation){
                config.lightEstimationEnabled = YES;
            }
            
            config.worldAlignment = state.worldAlignment;
            
            if(state.delegateClass != NULL){
                session.delegate = state.delegateClass;
                
                // note that audio is only available when you use a delegate class.
                if(state.useAudio){
                    config.providesAudioData = YES;
                }
            }
            
            [session runWithConfiguration:config];
            
            
        }else {
            
            AROrientationTrackingConfiguration * config = [AROrientationTrackingConfiguration new];
            if(state.useLightEstimation){
                config.lightEstimationEnabled = YES;
            }
            
            config.worldAlignment = state.worldAlignment;
            
            if(state.delegateClass != NULL){
                session.delegate = state.delegateClass;
                
                // note that audio is only available when you use a delegate class.
                if(state.useAudio){
                    config.providesAudioData = YES;
                }
            }
            
            [session runWithConfiguration:config];
            
        }
        
        
        
      
        return session;
        
    }
}

#endif /* SessionSetup_h */

