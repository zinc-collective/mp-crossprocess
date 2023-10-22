//
//  CPAppDelegate.h
//  CrossProcess
//
//  Copyright 2019 Zinc Collective LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCAppDelegate.h"

@class CPViewController;
@class CLLocationManager;
@class CPScaledImageCreator;

@interface CPAppDelegate : UIResponder<UIApplicationDelegate, BCAppDelegate>

@property (strong, nonatomic) UIWindow*                     window;
@property (strong, nonatomic) CPViewController*             viewController;
@property (strong, nonatomic) CLLocationManager*            locationManager;
@property (assign, nonatomic) BOOL                          appInBackground;
@property (strong, nonatomic) NSOperationQueue*             workQueue;
@property (strong, atomic) CPScaledImageCreator*            imageCreator;           // obsolete

- (NSString*)version;

@end
