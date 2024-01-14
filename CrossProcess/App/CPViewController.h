//
//  CPViewController.h
//  CrossProcess
//
//  Copyright 2019 Zinc Collective LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import "BCImageCaptureController.h"
#import "CPOptionsViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <CoreLocation/CoreLocation.h>

@class BCImageCaptureController;
@class CPImageProcessor;
@class BCImageScrollView;
@class CLLocation;

extern const NSInteger  CPRootViewTag;
extern const NSInteger  CPImageViewTag;
extern const NSInteger  CPWelcomeViewTag;
extern const NSInteger  CPToolbarTag;


@interface CPViewController : UIViewController< BCImageCaptureControllerDelegate,
                                                CPOptionsViewControllerDelegate,
                                                UIActionSheetDelegate,
                                                MFMailComposeViewControllerDelegate,
                                                CLLocationManagerDelegate,
                                                UIScrollViewDelegate,
                                                UIGestureRecognizerDelegate>

@property (weak, nonatomic)   IBOutlet UILabel *debugVersionLabel;
@property (strong, nonatomic) IBOutlet UIScrollView*        scrollView;
@property (strong, nonatomic) IBOutlet UIToolbar*           toolbarWithCamera;
@property (strong, nonatomic) IBOutlet UIToolbar*           toolbarNoCamera;

@property (strong, nonatomic) BCImageCaptureController*     imageCaptureController;
@property (strong, nonatomic) BCImageCaptureController*     imageLibraryController;
@property (assign, nonatomic) SystemSoundID                 captureSound;
@property (strong, nonatomic) CPImageProcessor*             imageProcessor;
@property (strong, nonatomic) NSOperationQueue*             imageQueue;
@property (strong, nonatomic) UIToolbar*                    toolbar;

@property (assign, nonatomic) BOOL                          processingImage;
@property (assign, nonatomic) BOOL                          animatingImage;
@property (assign, nonatomic) BOOL                          writingAsset;

@property (assign, nonatomic) BOOL                          shouldShowWelcomeScreen;
@property (assign, nonatomic) BOOL                          applicationLaunching;

@property (strong, nonatomic) CLLocation*                   currentLocation;

// Required for dealing with rotation of the scrollview and it's images as well as efficient use of view content in the scroll view.

@property(assign, nonatomic) NSInteger                      firstVisibleImageIndexBeforeRotation;
@property(assign, nonatomic) CGFloat                        percentScrolledIntoFirstVisibleImage;

@property(strong, nonatomic) NSMutableSet*                  recycledImageViews;
@property(strong, nonatomic) NSMutableSet*                  visibleImageViews;

// Holds onto the content we've captured.

@property(strong, nonatomic) NSMutableArray*                processedImages;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

- (void) setBackgroundImage;
- (void) clearBackgroundImage;
- (void) showFirstLaunchScreen;

- (void) presentPhotoPickerController;
- (void) presentPhotoCaptureController;
- (void) presentDefaultPhotoController;
- (void) toggleToolbarVisibility;

- (IBAction) handleAction: (id)sender;
- (IBAction) handleCapturePhoto: (id)sender;
- (IBAction) handlePickPhoto: (id)sender;
- (IBAction) handleOptions: (id)sender;
- (IBAction) showManual:(id)sender;

- (void) presentGrowlNotification: (NSString*) notification;

@end
