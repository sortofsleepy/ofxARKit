#import <CoreMotion/CoreMotion.h>

#pragma once

typedef struct
{
    double x, y, z, w;
    double roll, pitch, yaw;
} attAirPods;

typedef struct
{
    double x,y,z;
} accAirPods;


@protocol RotationDelegate <NSObject>
-(void) accelerationUpdate:(accAirPods)accAirPods;
-(void) attitudeUpdate:(attAirPods)attAPodsPro;
@end

@interface AttitudeOFBridge : NSObject<RotationDelegate>
@property (nonatomic) attAirPods aPodsRot;
@property (nonatomic) accAirPods aPodsAcc;

@end



@interface ARAirPodMoves : NSObject<CMHeadphoneMotionManagerDelegate>

@property (strong, nullable) CMHeadphoneMotionManager *motionManager;

-(void) setAttitudeDelegate:(id<RotationDelegate>) rotationDelegate;



-(void) init:(AttitudeOFBridge*)aOFB;
-(void)dealloc;
-(void) startTracking;
-(void) endTracking;

@end


static AttitudeOFBridge *attDelegate = [[AttitudeOFBridge alloc] init];


class airPProMoves {
    
    public :
    // singleton
    airPProMoves(const airPProMoves&) = delete;
    static airPProMoves& Get(){
        
        
        static airPProMoves aInstance;
        return aInstance;
    }
    
    void setup(){
        
        attDelegate = [[AttitudeOFBridge alloc] init];
        attPointer = attDelegate;
        
        airPodTracker = [ARAirPodMoves alloc];
        [airPodTracker init:attDelegate];
    }
    
    // attitude
    attAirPods att(){return attPointer.aPodsRot;}
    //quaternion
    CMQuaternion quat(){return {attPointer.aPodsRot.x, attPointer.aPodsRot.y, attPointer.aPodsRot.z, attPointer.aPodsRot.w};}
    // acceleration
    accAirPods acc(){return attPointer.aPodsAcc;}
    
    
    
    private :
    airPProMoves(){};
    ~airPProMoves(){};
    
    
    
    
    ARAirPodMoves *airPodTracker;
    AttitudeOFBridge *attPointer;
    
    
};
