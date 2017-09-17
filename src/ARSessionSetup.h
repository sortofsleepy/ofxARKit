//
//  ARSessionSetup.h
//  example-basic
//
//  Created by Joseph Chow on 9/14/17.
//

#ifndef ARSessionSetup_h
#define ARSessionSetup_h

namespace ARCore {
    
    //! Generates a new ARSession object.
    //!
    //! Pass in an alignment method for the ARKit to use in the new session. If you prefer to use a seperate delegate class, you can pass that in as the second parameter. You can also specify as to whether
    //! or not audio data should get captured.
    //!
    //! Note that if audio data capture is desired, note that a delegate class IS required and needs to
    //! implement the session:didOutputAudioSampleBuffer: method.
    //! see https://developer.apple.com/documentation/arkit/arconfiguration/2923559-providesaudiodata?language=objc
    static ARSession* generateNewSession(
                                         ARWorldAlignment worldAlignment = ARWorldAlignmentCamera,
                                         NSObject<ARSessionDelegate> * delegateClass=NULL,
                                         bool providesAudio=false){
        
     
        ARSession * session = [ARSession new];
        
        // by default - we want to be able to detect planes. Check to see if that's possible
        if([ARWorldTrackingConfiguration isSupported]){
            
            ARWorldTrackingConfiguration * config = [ARWorldTrackingConfiguration new];
            config.planeDetection = ARPlaneDetectionHorizontal;
            config.lightEstimationEnabled = YES;
            config.worldAlignment = worldAlignment;
            
            if(delegateClass != NULL){
                session.delegate = delegateClass;
            }
            
            // note that audio data is only available as part of a delegate class.
            if(providesAudio){
                config.providesAudioData = YES;
            }
            
            [session runWithConfiguration:config];
        }else {
            AROrientationTrackingConfiguration * config = [AROrientationTrackingConfiguration new];
            config.lightEstimationEnabled = YES;
            config.worldAlignment = worldAlignment;
            
            
            if(delegateClass != NULL){
                session.delegate = delegateClass;
            }
            
            // note that audio data is only available as part of a delegate class.
            if(providesAudio){
                config.providesAudioData = YES;
            }
            
            [session runWithConfiguration:config];
        }
        
        
        return session;
    }
};

#endif /* ARSessionSetup_h */
