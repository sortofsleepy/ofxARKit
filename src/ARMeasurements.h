//
//  ARMeasurements.h
//
//  Created by Joseph Chow on 9/26/17.
//

#ifndef ARMeasurements_h
#define ARMeasurements_h

namespace ARCommon {
    
    // iPhone/iPod touch
    static const float kiPhone3_5InchScreenHeight = 0.0740f;
    static const float kiPhone3_5InchScreenWidth = 0.0493f;
    static const float kiPhone4_0InchScreenHeight = 0.0885f;
    static const float kiPhone4_0InchScreenWidth = 0.0499f;
    static const float kiPhone4_7InchScreenHeight = 0.1041f;
    static const float kiPhone4_7InchScreenWidth = 0.0585f;
    static const float kiPhone5_5InchScreenHeight = 0.1218f;
    static const float kiPhone5_5InchScreenWidth = 0.0685f;
    
    static const NSUInteger kiPhone3_5InchHeightPoints = 480;
    static const NSUInteger kiPhone4_0InchHeightPoints = 568;
    static const NSUInteger kiPhone4_7InchHeightPoints = 667;
    static const NSUInteger kiPhone5_5InchHeightPoints = 736;
    
    // iPad
    static const float kiPad7_9InchScreenHeight = 0.1605f;
    static const float kiPad7_9InchScreenWidth = 0.1204f;
    static const float kiPad9_7InchScreenHeight = 0.1971f;
    static const float kiPad9_7InchScreenWidth = 0.1478f;
    static const float kiPad10_5InchScreenHeight = 0.2134f;
    static const float kiPad10_5InchScreenWidth = 0.16f;
    static const float kiPad12_9InchScreenHeight = 0.2622f;
    static const float kiPad12_9InchScreenWidth = 0.1965f;
    
    static const NSUInteger kiPadHeightPoints = 1024;
    static const NSUInteger kiPadPro10Dot5InchHeightPoints = 1112;
    static const NSUInteger kiPadPro12Dot9InchHeightPoints = 1366;
    
    static void devicePhysicalSize() {
        UIApplication *application = UIApplication.sharedApplication;
        
        // Convert the view into the window coordinate space. Takes care of any
        // weird custom rotation stuff going on. You may get interesting results
        // from rotated views.
        UIWindow *window = view.window ?: application.keyWindow;
        
        CGRect convertedFrame = [window convertRect:view.frame
                                           fromView:view.superview];
    }
}

#endif /* ARMeasurements_h */
