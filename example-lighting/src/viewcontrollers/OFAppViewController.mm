//
//  CustomAppViewController.m
//  Created by lukasz karluk on 8/02/12.
//

#import "OFAppViewController.h"
#include "ofxiOSExtras.h"
#include "ofAppiOSWindow.h"



@implementation OFAppViewController
- (void) viewDidLoad {
    [super viewDidLoad];

    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    

}


- (id) initWithFrame:(CGRect)frame app:(ofxiOSApp *)app {
    
    ofxiOSGetOFWindow()->setOrientation( OF_ORIENTATION_DEFAULT );   //-- default portait orientation.    
    
    return self = [super initWithFrame:frame app:app];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

@end
