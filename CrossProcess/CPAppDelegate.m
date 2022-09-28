//
//  CPAppDelegate.m
//  CrossProcess
//
//  Copyright 2019 Zinc Collective LLC. All rights reserved.
//

#import "CPAppDelegate.h"
#import "CPViewController.h"
#import "CPAppConstants.h"
#import "BCMiscellaneous.h"
#import <CoreLocation/CoreLocation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImageAdditions.h"

@interface CPAppDelegate()
- (BOOL) pManageFirstLaunchScenario;
@end

@implementation CPAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize locationManager = _locationManager;
@synthesize appInBackground = _appInBackground;
@synthesize workQueue = _workQueue;
@synthesize appSupportURL = _appSupportURL;
@synthesize youTubeHelpURL = _youTubeHelpURL;
@synthesize imageCreator = _imageCreator;

- (NSString*)version {
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];

    NSString *version = infoDictionary[@"CFBundleShortVersionString"];
    NSString *build = infoDictionary[(NSString*)kCFBundleVersionKey];
    NSString *bundleName = infoDictionary[(NSString *)kCFBundleNameKey];
    return [NSString stringWithFormat:@"%@ - %@ (%@)", bundleName, version, build];
}

- (BOOL) application: (UIApplication*) application didFinishLaunchingWithOptions: (NSDictionary*) launchOptions
{

    NSLog(@"[CPAppDelegate] didFinishLaunchingWithOptions - %@", [self version]);

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[CPViewController alloc] initWithNibName:@"CPViewController" bundle:nil];
    self.viewController.applicationLaunching = YES;

    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] == YES)
	{
		self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self.viewController;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.distanceFilter = 5.0f;
		[self.locationManager startUpdatingLocation];
	}

    self.workQueue = [[NSOperationQueue alloc] init];

    /* OBSOLETE
    self.imageCreator = [[CPScaledImageCreator alloc] init];
    self.imageCreator.queuePriority = NSOperationQueuePriorityNormal;
    [self.imageCreator addObserver: self forKeyPath: @"isFinished"  options: 0 context: &_imageCreator];
    [self.workQueue addOperation: self.imageCreator];
     */

    if(![self pManageFirstLaunchScenario])
    {
    }

    //self.assetLibrary = [[ALAssetsLibrary alloc] init];

    return YES;
}

- (void) applicationWillResignActive: (UIApplication*) application
{
}

- (void) applicationDidEnterBackground: (UIApplication*) application
{
    self.appInBackground = YES;
    [self.locationManager stopUpdatingLocation];
}

- (void) applicationWillEnterForeground: (UIApplication*) application
{
    self.appInBackground = NO;
    [self.locationManager startUpdatingLocation];

    [self.viewController presentDefaultPhotoController];
}

- (void) applicationDidBecomeActive: (UIApplication*) application
{
}

- (void) applicationWillTerminate: (UIApplication*) application
{
}

#pragma mark - KVO

- (void) observeValueForKeyPath: (NSString*) keyPath ofObject: (id) object change: (NSDictionary*) change context: (void*) context
{
    if(context == &_imageCreator)
    {
        CPScaledImageCreator*    ic = BCCastAsClass(CPScaledImageCreator, object);
        assert(ic);
        assert([keyPath isEqual: @"isFinished"]);
        assert([ic isFinished]);

        // cleanup
        self.imageCreator = nil;
    }
    else
    {
        [super observeValueForKeyPath: keyPath ofObject: object change: change context: context];
    }
}

- (NSURL*) youTubeHelpURL
{
    if(_youTubeHelpURL == nil)
    {
        _youTubeHelpURL = [NSURL URLWithString: @"http://www.youtube.com/watch?v=0w2jUZrkHiE"];
    }

    return _youTubeHelpURL;
}

- (NSURL*) appSupportURL
{
    if(_appSupportURL == nil)
    {
        NSString*       bundleID = [[NSBundle mainBundle] bundleIdentifier];
        NSFileManager*  fm = [NSFileManager defaultManager];
        NSURL*          dirURL = nil;

        // Find the application support directory in the home directory.
        NSArray* appSupportDir = [fm URLsForDirectory: NSApplicationSupportDirectory inDomains: NSUserDomainMask];
        if([appSupportDir count] > 0)
        {
            // Append the bundle ID to the URL for the application support directory
            dirURL = [[appSupportDir objectAtIndex: 0] URLByAppendingPathComponent: bundleID];

            NSError*    error = nil;
            BOOL        created = NO;

            created = [fm createDirectoryAtPath: [dirURL path] withIntermediateDirectories: YES attributes: nil error: &error];
            assert(created && !error);
        }

        _appSupportURL = dirURL;
    }

    return _appSupportURL;
}

- (NSArray*) imageAssetsNames
{
    return [NSArray arrayWithObjects: @"border", @"vignette", @"screen", nil];
}

#pragma mark - Private Methods

- (BOOL) pManageFirstLaunchScenario
{
    NSUserDefaults*     userDefaults = [NSUserDefaults standardUserDefaults];
	BOOL                isFirstLaunch = [userDefaults boolForKey: CPFirstLaunchKey] == NO;

#ifdef DEBUG
    isFirstLaunch = YES;
#endif

	if(isFirstLaunch)
    {
        self.viewController.shouldShowWelcomeScreen = YES;
        [userDefaults setBool: YES forKey: CPFirstLaunchKey];

        // Setup standard defaults
        [userDefaults setBool: NO forKey: CPFullSizeImageOptionKey];
        [userDefaults setBool: NO forKey: CPKeepOriginalOptionKey];
        [userDefaults setBool: YES forKey: CPWantsBorderOptionKey];
        [userDefaults setBool: YES forKey: CPRedProcessingOptionKey];
        [userDefaults setBool: YES forKey: CPBlueProcessingOptionKey];
        [userDefaults setBool: YES forKey: CPGreenProcessingOptionKey];
        [userDefaults setBool: YES forKey: CPBasicProcessingOptionKey];
        [userDefaults setBool: NO forKey: CPExtremeProcessingOptionKey];
    }

    return isFirstLaunch;
}

@end
