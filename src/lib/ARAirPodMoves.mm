#include "ARAirPodMoves.h"


@implementation AttitudeOFBridge
-(void) attitudeUpdate:(attAirPods)attAPodsPro{
    self.aPodsRot = attAPodsPro;
}

-(void) accelerationUpdate:(accAirPods)accAirPods{
    self.aPodsAcc = accAirPods;
}
@end

@implementation ARAirPodMoves

id __rotationDelegate = nil;

-(void) init:(AttitudeOFBridge*)aOFB {
    
    self.motionManager = [[CMHeadphoneMotionManager alloc] init];
    self.motionManager.delegate = self;
    
    
    [self setAttitudeDelegate: aOFB];
    
    // callback finished
    
    [self startTracking];
    
}

-(void) startTracking{
    if (self.motionManager.isDeviceMotionAvailable ){
        NSLog(@"able to track headphones Movements");
        
        [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error){
            if (__rotationDelegate){
                attAirPods a;
                a.x = motion.attitude.quaternion.x;
                a.y = motion.attitude.quaternion.y;
                a.z = motion.attitude.quaternion.z;
                
                a.roll = motion.attitude.roll;
                a.pitch = motion.attitude.pitch;
                a.yaw = motion.attitude.yaw;
                
                accAirPods acc;
                acc.x = motion.userAcceleration.x + motion.gravity.x;
                acc.y = motion.userAcceleration.y + motion.gravity.y;
                acc.z = motion.userAcceleration.z + motion.gravity.z;
                

                [__rotationDelegate attitudeUpdate:a];
                [__rotationDelegate accelerationUpdate:acc];

                if(error != NULL)NSLog(@" this is the error : %@",[error localizedDescription]);
            }
        }];
    }
}

-(void) stopTracking{
    NSLog(@"finished tracking headphones Movements");
    [self.motionManager stopDeviceMotionUpdates];
    
}

-(void) setAttitudeDelegate:(id<RotationDelegate>) rotationDelegate {
    __rotationDelegate = rotationDelegate;
    NSLog(@"Set the rotation delegate");
}

-(void)dealloc {
    
    [self stopTracking];

    [super dealloc];
}

@end

@implementation RotationDelegate
-(void) attitudeUpdate:(attAirPods *)aPodsRot{
}

-(void) accelerationUpdate:(accAirPods *)aPodsRot{
}
@end
