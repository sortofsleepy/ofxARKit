//
//  MenuViewController.m
//

#import "MyAppViewController.h"

#import "OFAppViewController.h"
#import "ofApp.h"
using namespace ofxARKit::core;
@interface MyAppViewController()
@property (nonatomic, strong) ARSession *session;
@end

@implementation MyAppViewController


- (void)loadView {
    [super loadView];
    
    SFormat format;
    format.enableLighting();
    self.session = generateNewSession(format);
    
    
    OFAppViewController *viewController;
    viewController = [[[OFAppViewController alloc] initWithFrame:[[UIScreen mainScreen] bounds]
                                                                 app:new ofApp(self.session)] autorelease];
    
    [self.navigationController setNavigationBarHidden:TRUE];
    [self.navigationController pushViewController:viewController animated:NO];
    self.navigationController.navigationBar.topItem.title = @"ofApp";
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    BOOL bRotate = NO;
    bRotate = bRotate || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
    bRotate = bRotate || (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
    bRotate = bRotate || (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft);
    bRotate = bRotate || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
    return bRotate;
}

@end
