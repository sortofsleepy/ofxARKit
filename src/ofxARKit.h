//
//  ofxARKit.h
//
//  Created by Joseph Chow on 8/19/17.
//  With additional help by contributors.
//

#ifndef ofxARKit_h
#define ofxARKit_h

#ifndef AR_FACE_TRACKING
#define AR_FACE_TRACKING true
#endif

#ifdef AIRPODS 
#define AIRPODS
#endif 

#include <ARKit/ARKit.h>
#include "lib/ARUtils.h"
#include "lib/ARDebugUtils.h"
#include "lib/ARProcessor.h"
#include "lib/ARAnchorManager.h"
#include "lib/ARShaders.h"
#include "lib/ARCam.h"
#include "lib/ARSessionSetup.h"
#include "lib/MetalCam.h"

#endif /* ofxARKit_h */
