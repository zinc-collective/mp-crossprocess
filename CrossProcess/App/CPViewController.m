//
//  CPViewController.m
//  CrossProcess
//
//  Copyright 2019 Zinc Collective LLC. All rights reserved.
//

#import "CrossProcess-Swift.h"

#import "CPViewController.h"
#import "CPAppConstants.h"
#import "CPAppDelegate.h"
#import "BCMiscellaneous.h"
#import "BCImageCaptureController.h"
#import "BCImage.h"
#import "BCImageView.h"
#import "BCTimer.h"
#import "CPImageProcessor.h"
#import "BCGrowlView.h"
#import "BCUtilities.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Twitter/Twitter.h>
#include <ImageIO/ImageIO.h>
#import <objc/runtime.h>
#import <Photos/PHPhotoLibrary.h>
#import "ImageMetadata.h"


#define PADDING     10

const NSInteger  CPWelcomeViewTag = 100;
const NSInteger  CPWelcomeLabelTitleTag = 201;
const NSInteger  CPWelcomeLabelMessageTag = 200;
const NSInteger  CPIntroVideoButtonTag = 202;
const NSInteger  CPRootViewTag = 200;
const NSInteger  CPScrollViewTag = 300;
const NSInteger  CPToolbarTag = 400;
const NSInteger  CPToolbarPositionOffsetY = 30;

typedef void (^CPWriteAssetCompletionBlock)(NSURL *assetURL, NSError *error);
typedef void (^CPLoadAssetImageCompletionBlock)(UIImage* image, NSString* imageUTI, BOOL didFail);
typedef void (^CPLoadAssetDataCompletionBlock)(NSData* imageData, NSString* imageUTI, BOOL didFail);

@interface CPViewController()

@property(nonatomic, strong) UIImage*           photoToProcess;
@property(nonatomic, strong) NSDictionary*      photoMetadata;
@property(nonatomic, strong) NSURL*             photoAssetLibraryURL;
@property(nonatomic, strong) NSString*          photoAssetLibraryAssetIdentifier;
@property(nonatomic, assign) BOOL               photoWasCaptured;

- (void) pLoadAsset: (NSURL*) assetURL usingImageCompletionBlock: (CPLoadAssetImageCompletionBlock) completionBlock;
- (void) pLoadAsset: (NSURL*) assetURL usingDataCompletionBlock: (CPLoadAssetDataCompletionBlock) completionBlock;

- (void) pHandleWelcomeTap: (UITapGestureRecognizer*) sender;
- (void) pHandleSingleTap: (UITapGestureRecognizer*) sender;

- (void) pSetupPhotoCaptureSound;
- (void) pPlayPhotoCaptureSound;
- (void) pBeginProcessingPhoto: (CGSize) imageSize;
- (void) pImageProcessorDone: (CPImageProcessor*) imageProcessor;
- (void) pWriteImageToPhotoLibrary: (BCImage*) image metadata: (NSDictionary*) metadata gpsData: (NSDictionary*) gpsData;
- (void) pGatherOriginalLocation: (NSURL*) assetURL andWriteToPhotoLibrary: (BCImage*) image;
- (void) pWriteCGImageToSavedPhotosAlbum: (CGImageRef) cgImage
                                metadata: (NSDictionary*) metadata
                                 gpsData: (NSDictionary*) gpsData
                         writingOriginal: (BOOL) writingOriginal
                         completionBlock: (CPWriteAssetCompletionBlock) writeCompletionBlock;
- (void) pValidateToolbarItems;
- (NSString*) pCurvesPathFromUserSetting;
- (BOOL) pWriteOriginalImage;
- (CPPlaceholderType) pPlaceholderTypeFromCurveName: (NSString*) curvePath;
- (NSMutableDictionary*) pCurrentLocation;
- (NSMutableDictionary*) pGPSDictionary: (CLLocation*) location;
- (NSURL*) pURLForVisibleImageView;
- (void) pAdjustScrollViewFrame;
- (CGRect) pFrameForScrollView;
- (CGSize) pContentSizeForScrollView;
- (CGRect) pFrameForViewAtIndex: (NSInteger) index;
- (BCImageView*) pDequeueRecycledView;
- (void) pTileViews;
- (void) pConfigureView: (BCImageView*) view forIndex: (NSInteger) index;
- (BOOL) pIsDisplayingViewForIndex: (NSUInteger) index visibleView: (BCImageView**) visibleView;
- (NSString*) pMimeTypeForUTI: (NSString*) uti;
- (NSString*) pFileExtensionForUTI: (NSString*) uti;
- (void) pCreateAndAnimatePlaceholderView: (CGSize) imageSize;

- (void) pHideToolbar: (BOOL) animate;
- (void) pShowToolbar: (BOOL) animate;

@end

@implementation CPViewController

@synthesize photoToProcess = _photoToProcess;
@synthesize photoMetadata = _photoMetadata;
@synthesize photoAssetLibraryURL = _photoAssetLibraryURL;
@synthesize photoAssetLibraryAssetIdentifier = _photoAssetLibraryAssetIdentifier;
@synthesize photoWasCaptured = _photoWasCaptured;

@synthesize debugVersionLabel;
@synthesize scrollView = _scrollView;
@synthesize toolbar = _toolbar;
@synthesize toolbarNoCamera = _toolbarNoCamera;
@synthesize toolbarWithCamera = _toolbarWithCamera;
@synthesize captureSound = _captureSound;
@synthesize imageCaptureController = _imageCaptureController;
@synthesize imageLibraryController = _imageLibraryController;
@synthesize imageProcessor = _imageProcessor;
@synthesize imageQueue = _imageQueue;
@synthesize processingImage = _processingImage;
@synthesize animatingImage = _animatingImage;
@synthesize writingAsset = _writingAsset;
@synthesize shouldShowWelcomeScreen = _shouldShowWelcomeScreen;
@synthesize applicationLaunching = _applicationLaunching;
@synthesize currentLocation = _currentLocation;

@synthesize firstVisibleImageIndexBeforeRotation = _firstVisibleImageIndexBeforeRotation;
@synthesize percentScrolledIntoFirstVisibleImage = _percentScrolledIntoFirstVisibleImage;

@synthesize recycledImageViews = _recycledImageViews;
@synthesize visibleImageViews = _visibleImageViews;

@synthesize processedImages = _processedImages;
@synthesize backgroundImage;

- (void) didReceiveMemoryWarning
{
#if DEBUG
    NSLog(@"###---> Recieved memory warning");
#endif

    if(self.captureSound != 0)
    {
        AudioServicesDisposeSystemSoundID(self.captureSound);
        self.captureSound = 0;
    }

    self.recycledImageViews = nil;

    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (id) initWithNibName: (NSString*) nibNameOrNil bundle: (NSBundle*) nibBundleOrNil
{
    if(self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil])
    {
        self.processedImages = [[NSMutableArray alloc] initWithCapacity: 10];
    }

    return self;
}

- (void) dealloc
{
    if(self.captureSound != 0)
    {
        AudioServicesDisposeSystemSoundID(self.captureSound);
        self.captureSound = 0;
    }
}

/*
- (void) viewDidLayoutSubviews
{
#if DEBUG
    NSLog(@"###---> -viewDidLayoutSubviews");
#endif

    [super viewDidLayoutSubviews];
}
*/

- (void) viewDidLoad
{
    [super viewDidLoad];

    self.debugVersionLabel.text = [(CPAppDelegate*)[[UIApplication sharedApplication] delegate] version];

    self.view.tag = CPRootViewTag;

    //self.scrollView.frame = [self pFrameForScrollView];
    [self pAdjustScrollViewFrame];
    self.scrollView.tag = CPScrollViewTag;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.opaque = NO;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = [self pContentSizeForScrollView];
    self.scrollView.directionalLockEnabled = YES;
    self.scrollView.delegate = self;

    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                                action: @selector(pHandleSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [self.scrollView addGestureRecognizer: singleTap];

    [self setBackgroundImage];
    [self pSetupPhotoCaptureSound];

//    if(self.imageCaptureController == nil)
//    {
//        self.imageCaptureController = [[BCImageCaptureController alloc] initWithNibName: @"BCImageCaptureController" bundle: nil];
//        self.imageCaptureController.delegate = self;
//    }

    // Set the appropriate toolbar

    if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] == YES)
	{
        self.toolbar = self.toolbarWithCamera;
        self.toolbarWithCamera = nil;
        self.toolbarNoCamera = nil;
	}
    else
    {
        self.toolbar = self.toolbarNoCamera;
        self.toolbarWithCamera = nil;
        self.toolbarNoCamera = nil;
    }

    // Toolbar should be off by default
    self.toolbar.alpha = 0.0f;

    CGSize viewSize = self.view.frame.size;
    CGSize toolbarSize = self.toolbar.frame.size;

    self.toolbar.frame = CGRectMake(0, viewSize.height - toolbarSize.height - CPToolbarPositionOffsetY, viewSize.width, toolbarSize.height);
    self.toolbar.tag = CPToolbarTag;
    [self.view insertSubview: self.toolbar aboveSubview: self.scrollView];

    self.recycledImageViews = [[NSMutableSet alloc] init];
    self.visibleImageViews = [[NSMutableSet alloc] init];

}

- (void) viewDidUnload
{
#if DEBUG
    NSLog(@"###---> View did unload");
#endif

    [super viewDidUnload];

    if(self.captureSound != 0)
    {
        AudioServicesDisposeSystemSoundID(self.captureSound);
        self.captureSound = 0;
    }

    self.toolbar = nil;
    self.recycledImageViews = nil;
    self.visibleImageViews = nil;
}

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];

    if(self.applicationLaunching)
    {
        self.applicationLaunching = NO;

        if(self.shouldShowWelcomeScreen)
        {
            [self showFirstLaunchScreen];
        }
        else
        {
            [self presentDefaultPhotoController];
        }
    }
}



- (void) showFirstLaunchScreen
{
    UIView*  rootView = [self.view superview];

    UINib*   welcomeNib = nil;
    welcomeNib = [UINib nibWithNibName: @"CPWelcome" bundle: nil];

    if(welcomeNib)
    {
        NSArray*    contents = [welcomeNib instantiateWithOwner: self options: nil];
        if(contents)
        {
            UIView*  welcomeView = BCCastAsClass(UIView, [contents objectAtIndex: 0]);
            welcomeView.frame = self.view.bounds;
            if(welcomeView)
            {
                [rootView insertSubview: welcomeView aboveSubview: self.view];

                welcomeView.tag = CPWelcomeViewTag;

                UILabel*    welcomeMessageTitleLabel = BCCastAsClass(UILabel, [welcomeView viewWithTag: CPWelcomeLabelTitleTag]);
                UILabel*    welcomeMessageMessageLabel = BCCastAsClass(UILabel, [welcomeView viewWithTag: CPWelcomeLabelMessageTag]);
                UIButton*   introVideoButton = BCCastAsClass(UIButton, [welcomeView viewWithTag: CPIntroVideoButtonTag]);

                NSString*   welcomeTitleString = NSLocalizedString(@"welcomeMessage", @"CP Welcome Title");
                NSString*   welcomeMessageString = NSLocalizedString(@"welcomeMessageTitle", @"CP Welcome Message");
                NSString*   introVideoButtonString = NSLocalizedString(@"introVideoText", @"CP Intro Video Button Text");

                welcomeMessageTitleLabel.text = welcomeTitleString;
                welcomeMessageMessageLabel.text = welcomeMessageString;

                [introVideoButton setTitle: introVideoButtonString forState: UIControlStateNormal];
                [introVideoButton setTitle: introVideoButtonString forState: UIControlStateHighlighted];

                [UIView transitionFromView: self.view
                                    toView: welcomeView
                                  duration: 1.0
                                   options: UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionCrossDissolve
                                completion: ^(BOOL finished)
                 {
                     UITapGestureRecognizer*  gr = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(pHandleWelcomeTap:)];
                     gr.delegate = self;
                     [welcomeView addGestureRecognizer: gr];
                 }];
            }
        }
    }
}

- (void) presentDefaultPhotoController
{
    if(self.presentedViewController == nil)
    {
        if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        {
            [self presentPhotoCaptureController];
        }
        else
        {
            [self presentPhotoPickerController];
        }
    }
}

- (void) presentPhotoPickerController
{
    if(self.imageLibraryController != nil)
    {
        [self.imageLibraryController setupForPhotoLibraryCapture];
        [self presentViewController:self.imageLibraryController.imagePickerLibraryController animated: YES completion:^{}];
    }
}

- (void) presentPhotoCaptureController
{
    if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        [self.imageCaptureController setupForImageCapture: UIImagePickerControllerSourceTypeCamera];
        [self presentViewController: self.imageCaptureController.imagePickerController animated: YES completion:^{}];
    }
}

- (void) presentGrowlNotification: (NSString*) notification
{
	CGRect	notificationFrame = CGRectMake(0, 0, 280, 60);
	BCGrowlView*	view = [[BCGrowlView alloc] initWithFrame: notificationFrame];
	[view beginNotificationInViewController: self withNotification: notification];
}

#pragma mark - BCImageCaptureControllerDelegate

- (void) userPickedPhoto: (UIImage*) photo withPhotoLibraryAsset: (NSString*) identifier
 {
     [self pHideToolbar: NO];
     [self dismissViewControllerAnimated: YES completion:^{}];
     [self pValidateToolbarItems];

     // Begin an image processing operation
     [ImageMetadata fetchMetadataForAssetIdentifier:identifier found:^(NSDictionary * meta) {
         NSLog(@"###---> GOT METADATA %@", meta);

         self.photoToProcess = photo;
         self.photoMetadata = meta;
         self.photoAssetLibraryAssetIdentifier = identifier;
         self.photoWasCaptured = NO;

         // If the scrollview's contentOffset is already 0,0 then our delegate method for scrollViewDidEndScrollingAnimation
         // won't be called.

         CGPoint scrollOffset = self.scrollView.contentOffset;
         if(CGPointEqualToPoint(CGPointZero, scrollOffset))
         {
             [self pBeginProcessingPhoto: photo.size];
         }
         else
         {
             NSLog(@"###---> [CPV] userPickedPhoto - scroll");
             [self.scrollView setContentOffset: CGPointZero animated: YES];
         }
     }];

}

- (void) userCapturedPhoto: (UIImage*) photo withMetadata: (NSDictionary*) metadata
{
    [self pHideToolbar: NO];
    [self dismissViewControllerAnimated: YES completion:^{}];
    [self pValidateToolbarItems];

    // Begin an image processing operation

    self.photoToProcess = photo;
    self.photoMetadata = metadata;
    self.photoAssetLibraryURL = nil;
    self.photoWasCaptured = YES;

    CGPoint scrollOffset = self.scrollView.contentOffset;
    if(CGPointEqualToPoint(CGPointZero, scrollOffset))
    {
        [self pBeginProcessingPhoto: photo.size];
    }
    else
    {
        [self.scrollView setContentOffset: CGPointZero animated: YES];
    }
}

- (void) userCancelled
{
    if(self.processedImages.count > 0)
    {
        [self pHideToolbar: NO];
    }
    else
    {
        [self pShowToolbar: NO];
    }

    [self dismissViewControllerAnimated: YES completion:^{}];
    [self pValidateToolbarItems];
}

- (void) observeValueForKeyPath: (NSString*) keyPath ofObject: (id) object change: (NSDictionary*) change context: (void*) context
{
    if(context == &self->_imageProcessor)
    {
        CPImageProcessor*    ip = BCCastAsClass(CPImageProcessor, object);
//        NSLog(@"###---> [CPV] observeValueForKeyPath %i", (ip && [ip isFinished]));

        if(ip && [ip isFinished])
        {
            dispatch_async(dispatch_get_main_queue(),^ {
                [self pImageProcessorDone:ip];
            } );
        }
    }
    else
    {
        [super observeValueForKeyPath: keyPath ofObject: object change: change context: context];
    }
}

- (IBAction)handleAction:(id)sender {
//    NSLog(@"###---> Action");
    NSURL* url = [self pURLForVisibleImageView];
    if (url) {
        [self pLoadAsset:url usingImageCompletionBlock:^(UIImage *image, NSString *imageUTI, BOOL didFail) {
            if (!didFail) {
                [self shareImage: image];
            }
        }];
    }
}

- (void) shareImage:(UIImage*)image {

    NSString * shareText = @"Made with #CrossProcess";
    NSURL * shareURL = [NSURL URLWithString:@"https://itunes.apple.com/us/app/cross-process/id355754066?mt=8"];

    UIActivityViewController * share = [[UIActivityViewController alloc] initWithActivityItems:@[image, shareText, shareURL] applicationActivities:NULL];
    [self presentViewController:share animated:YES completion:NULL];
}

- (IBAction) handleCapturePhoto: (id) sender
{
    [self presentPhotoCaptureController];
}

- (IBAction) handlePickPhoto: (id) sender
{
    [self presentPhotoPickerController];
}

- (IBAction) handleOptions: (id) sender
{
    CPOptionsViewController* controller = [[CPOptionsViewController alloc] initWithNibName: @"CPOptionsViewController" bundle: nil];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController: controller animated: YES completion:^{}];
}

- (IBAction) showManual: (id) sender
{
    id<BCAppDelegate>   appDelegate = BCCastAsProtocol(BCAppDelegate, [[UIApplication sharedApplication] delegate]);
    NSURL*              manualURL = [appDelegate youTubeHelpURL];

    if(manualURL)
    {
        [[UIApplication sharedApplication] openURL: manualURL];
    }
}

#pragma mark - CPOptionsViewControllerDelegate

- (void) optionsViewControllerDidFinish: (CPOptionsViewController*) controller
{
    [self dismissViewControllerAnimated: YES completion:^{}];
}


#pragma mark - Location Management

- (void) locationManager: (CLLocationManager*) manager
     didUpdateToLocation: (CLLocation*) newLocation
            fromLocation: (CLLocation*) oldLocation
{
    self.currentLocation = newLocation;
}

#pragma mark - Rotation

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
    return YES;
}

- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation duration: (NSTimeInterval) duration
{
    CGFloat offset = self.scrollView.contentOffset.x;
    CGFloat scrollViewWidth = self.scrollView.bounds.size.width;

    if(offset >= 0)
    {
        self.firstVisibleImageIndexBeforeRotation = floorf(offset / scrollViewWidth);
        self.percentScrolledIntoFirstVisibleImage = (offset - (self.firstVisibleImageIndexBeforeRotation * scrollViewWidth)) / scrollViewWidth;
    }
    else
    {
        self.firstVisibleImageIndexBeforeRotation = 0;
        self.percentScrolledIntoFirstVisibleImage = offset / scrollViewWidth;
    }
}

- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation duration: (NSTimeInterval) duration
{
    // recalculate contentSize based on current orientation
    self.scrollView.contentSize = [self pContentSizeForScrollView];

    // adjust frames and configuration of each visible page

    for(UIView* subview in self.scrollView.subviews)
    {
        subview.frame = [self pFrameForViewAtIndex: subview.index];
    }

    // adjust contentOffset to preserve page location based on values collected prior to location
    CGFloat scrollViewWidth = self.scrollView.bounds.size.width;
    CGFloat newOffset = (self.firstVisibleImageIndexBeforeRotation * scrollViewWidth) + (self.percentScrolledIntoFirstVisibleImage * scrollViewWidth);
    self.scrollView.contentOffset = CGPointMake(newOffset, 0);
}

#pragma mark - UIScrollViewDelegate

- (void) scrollViewDidScroll: (UIScrollView*) scrollView
{
    //NSLog(@"###---> -scrollViewDidScroll. Current offset = %@", NSStringFromCGPoint(scrollView.contentOffset));
    [self pTileViews];
}

- (void) scrollViewDidEndScrollingAnimation: (UIScrollView*) scrollView
{
    if(self.photoToProcess != nil)
    {
        [self pBeginProcessingPhoto: self.photoToProcess.size];
    }
}

- (void) pCreateAndAnimatePlaceholderView: (CGSize) imageSize
{
    if(self.processedImages.count > 0)
    {
        NSNumber*  placeholderAsset = BCCastAsClass(NSNumber, [self.processedImages objectAtIndex: 0]);

        if(placeholderAsset)
        {
            // Ensure that the # of assets we have are reflected in the scrollview size.

            self.scrollView.contentSize = [self pContentSizeForScrollView];

            // Increment the visible image indices.

            for(BCImageView* view in self.visibleImageViews)
            {
                [view setIndex: view.index + 1];
            }

            // Start the capture sound.

            [self pPlayPhotoCaptureSound];

            // Create the new placeholder view, add it to the scrollview and animate it in.

            BCImageView*    imageView = [[BCImageView alloc] initWithFrame:BCViewFrame photoProvider:[[PhotoSource alloc] init]];

            // Only set the natural size if the photo wasn't captured.

            if(self.imageProcessor.wasCaptured == NO)
            {
                imageView.naturalSize = imageSize;
            }

            [self pConfigureView: imageView forIndex: 0];

            [imageView useAsset: placeholderAsset];

            CGRect initialFrame = imageView.frame;
            imageView.frame = CGRectOffset(initialFrame, -(initialFrame.size.width + PADDING + PADDING), 0);

            [self.scrollView addSubview: imageView];
            [self.visibleImageViews addObject: imageView];

            // Since we add a placeholder to the beginning of the array we need
            // to update the array indices appropriately and offset the visible image views

            [UIView animateWithDuration: 2.0
                                  delay: 0.0
                                options: UIViewAnimationOptionCurveEaseInOut
                             animations: ^
             {
                 for(BCImageView* view in self.visibleImageViews)
                 {
                     view.frame = [self pFrameForViewAtIndex: view.index];
                 }
             }
                             completion:^(BOOL finished)
             {
                 [self pTileViews];
             }];
        }
    }
}

#pragma mark - Miscellaneous

- (void) pHideToolbar: (BOOL) animate
{
    if(self.toolbar.alpha > 0.0)
    {
        if(animate == NO)
        {
            self.toolbar.alpha = 0.0f;
        }
        else
        {
            [UIView animateWithDuration: 0.4
                                  delay: 0.1
                                options: UIViewAnimationOptionCurveEaseOut
                             animations:^
             {
                 self.toolbar.alpha = 0.0f;
             }
                             completion:^(BOOL finished)
             {
             }];
        }
    }
}

- (void) pShowToolbar: (BOOL) animate
{
    if(self.toolbar.alpha == 0.0)
    {
        if(animate == NO)
        {
            self.toolbar.alpha = 1.0f;
        }
        else
        {
            [UIView animateWithDuration: 0.4
                                  delay: 0.1
                                options: UIViewAnimationOptionCurveEaseIn
                             animations:^
             {
                 self.toolbar.alpha = 1.0f;
             }
                             completion:^(BOOL finished)
             {
             }];
        }
    }
}

- (void) toggleToolbarVisibility
{
    if(self.toolbar.alpha > 0.0)
    {
        [self pHideToolbar: YES];
    }
    else
    {
        [self pShowToolbar: YES];
    }
}

#pragma mark - Private

- (void) pValidateToolbarItems
{
    BOOL    actionEnabled = YES;
    BOOL    optionsEnabled = YES;
    BOOL    pickPhotoEnabled = YES;
    BOOL    capturePhotoEnabled = YES;

    if(self.animatingImage || self.processingImage)
    {
        actionEnabled = NO;
        optionsEnabled = NO;
        pickPhotoEnabled = NO;
        capturePhotoEnabled = NO;
    }

    if(self.writingAsset || self.processedImages.count == 0)
    {
        actionEnabled = NO;
    }

    for(UIBarButtonItem* item in self.toolbar.items)
    {
        if(item.tag == CPActionBarButtonItemTag)
        {
            item.enabled = actionEnabled;
        }
        else if(item.tag == CPOptionsBarButtonItemTag)
        {
            item.enabled = optionsEnabled;
        }
        else if(item.tag == CPCapturePhotoBarButtonItemTag)
        {
            item.enabled = capturePhotoEnabled;
        }
        else if(item.tag == CPPickPhotoBarButtonItemTag)
        {
            item.enabled = pickPhotoEnabled;
        }
    }
}

- (NSMutableDictionary*) pGPSDictionary: (CLLocation*) location
{
    NSMutableDictionary*    gpsDict = [[NSMutableDictionary alloc] init];

    if(location != nil)
    {
		CLLocationDegrees exifLatitude = location.coordinate.latitude;
		CLLocationDegrees exifLongitude = location.coordinate.longitude;

		[gpsDict setObject: location.timestamp forKey: (NSString*)kCGImagePropertyGPSTimeStamp];

		if(exifLatitude < 0.0)
        {
			exifLatitude = exifLatitude*(-1);
			[gpsDict setObject: @"S" forKey: (NSString*)kCGImagePropertyGPSLatitudeRef];
		}
        else
        {
			[gpsDict setObject: @"N" forKey: (NSString*)kCGImagePropertyGPSLatitudeRef];
		}

        [gpsDict setObject: [NSNumber numberWithFloat: exifLatitude] forKey: (NSString*)kCGImagePropertyGPSLatitude];

		if(exifLongitude < 0.0)
        {
			exifLongitude = exifLongitude*(-1);
			[gpsDict setObject: @"W" forKey: (NSString*)kCGImagePropertyGPSLongitudeRef];
		}
        else
        {
			[gpsDict setObject: @"E" forKey: (NSString*)kCGImagePropertyGPSLongitudeRef];
		}

        [gpsDict setObject: [NSNumber numberWithFloat: exifLongitude] forKey: (NSString*)kCGImagePropertyGPSLongitude];
    }

    return  gpsDict;
}

- (NSMutableDictionary*) pCurrentLocation
{
    return [self pGPSDictionary: self.currentLocation];
}

- (void) pWriteCGImageToSavedPhotosAlbum: (CGImageRef) cgImage
                                metadata: (NSDictionary*) metadata
                                 gpsData: (NSDictionary*) gpsData
                         writingOriginal: (BOOL) writingOriginal
                         completionBlock: (CPWriteAssetCompletionBlock) writeCompletionBlock
{
    NSLog(@"###---> pWriteCGImageToSavedPhotosAlbum");
#if DEBUG
    BCTimer*                            timer = [BCTimer timer];
    [timer startTimer];
#endif

    ALAssetsLibrary*                    library = [[ALAssetsLibrary alloc] init]; //AppDelegate().assetLibrary;
    BOOL                                canWriteToAssetLibrary = NO;

    // We can get into a situation where the user is asked if our app can write to the photo library (ios6)
    // If they choose no, then we weill get a not-authorized status and have to bail.
    // We probably need UI here to tell the user they disable write access.

    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if(status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusNotDetermined)
    {
        canWriteToAssetLibrary = YES;
    }

    if(canWriteToAssetLibrary)
    {
        NSMutableDictionary*                imageMetadata = [metadata mutableCopy];
        UIBackgroundTaskIdentifier          backgroundIdent = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];

        if(!writingOriginal)
        {
            // We always generate the processed asset as having an orientation of zero.

            NSString*   orientationProperty = (__bridge NSString*)kCGImagePropertyOrientation;
            [imageMetadata setObject: [NSNumber numberWithInt: 0] forKey: orientationProperty];
        }


        // if it doesn't have GPS (captured photos), insert the current location
        if (![imageMetadata objectForKey:(NSString*)kCGImagePropertyGPSDictionary]) {
            NSDictionary*                       gpsDict = gpsData ? gpsData : [self pCurrentLocation];

            if(gpsDict.count > 0)
            {
                [imageMetadata setObject: gpsDict forKey: (NSString*)kCGImagePropertyGPSDictionary];
            }
        }


        [library writeImageToSavedPhotosAlbum: cgImage
                                     metadata: imageMetadata
                              completionBlock:^(NSURL* asset, NSError* error)
         {
#if DEBUG
             [timer stopTimer];
             [timer logElapsedInMilliseconds: @"Time to write asset to saved photos album:"];
#endif
             if(writeCompletionBlock)
             {
                 writeCompletionBlock(asset, error);
             }

             [[UIApplication sharedApplication] endBackgroundTask: backgroundIdent];
         }];
    }
}

- (void) pGatherOriginalLocation: (NSURL*) assetURL andWriteToPhotoLibrary: (BCImage*) image
{
    NSLog(@"###---> pGatherOriginalLocation");
    ALAssetsLibrary*                    library = [[ALAssetsLibrary alloc] init];
    __block NSMutableDictionary*        gpsDict = nil;

    // Gather the EXIF data if we can...

    [library assetForURL: assetURL
             resultBlock:^(ALAsset *asset)
     {
//         NSLog(@"###--->  - got result");
         ALAssetRepresentation*     rep = [asset defaultRepresentation];
         NSDictionary*              imageMetadata = nil;
         if(rep)
         {
             imageMetadata = [rep metadata];
         }

         gpsDict = [self pGPSDictionary: BCCastAsClass(CLLocation, [asset valueForProperty: ALAssetPropertyLocation])];
         [self pWriteImageToPhotoLibrary: image metadata: imageMetadata gpsData: gpsDict];
     }
            failureBlock:^(NSError *error)

     {
         NSLog(@"###--->  - Error getting asset %@ -attempting to write anyway", error);
         // Error getting asset, but attempt to write anyways.
         [self pWriteImageToPhotoLibrary: image metadata: nil gpsData: nil];
     }];
}

- (void) pWriteImageToPhotoLibrary: (BCImage*) image metadata: (NSDictionary*) metadata gpsData: (NSDictionary*) gpsData
{
    NSLog(@"###---> pWriteImageToPhotoLibrary");
    self.writingAsset = YES;
    [self pValidateToolbarItems];

    __block CGImageRef  imageRefToWrite = image.CGImageRef;

    [self pWriteCGImageToSavedPhotosAlbum: imageRefToWrite
                                 metadata: metadata
                                  gpsData: gpsData
                          writingOriginal: NO
                          completionBlock:^(NSURL* asset, NSError* error)
     {
         self.writingAsset = NO;

         if(error)
         {
#if DEBUG
             NSLog(@"###---> %@", error.description);
#endif
         }
         else if (!asset) {
             NSLog(@"###---> Missing asset! %@ %@", image, metadata);
         }
         else
         {
             // We are always tacking onto the beginning of the image list. We stash a placeholder object at that index until we
             // are finished writing to the photo library and obtaining the asset URL.

             if(self.processedImages.count > 0)
             {
                 [self.processedImages replaceObjectAtIndex: 0 withObject: asset];
             }
         }

         [self pValidateToolbarItems];

         CGImageRelease(imageRefToWrite);
     }];
}

- (void) pImageProcessorDone: (CPImageProcessor*) imageProcessor
{
    NSLog(@"###---> [CPV] pImageProcessorDone %i %i", (imageProcessor == self.imageProcessor), self.processingImage);

#if DEBUG
    assert([NSThread isMainThread]);
#endif

    [imageProcessor removeObserver: self forKeyPath: @"isFinished"];

    if(imageProcessor == self.imageProcessor && self.processingImage)
    {
        BCImage*        image = imageProcessor.processedImage;
        NSLog(@"###--->  - processedImage %@ %@", image, NSStringFromCGSize(image.size));
        BCImageView*    imageView = nil;

        if([self pIsDisplayingViewForIndex: 0 visibleView: &imageView])
        {
            [imageView useAsset: image];
        }

        BOOL              writeOriginal = [self pWriteOriginalImage];

        if(imageProcessor.wasCaptured)
        {
            NSLog(@"###--->  - wasCaptured");
            [self pWriteImageToPhotoLibrary: image metadata: imageProcessor.imageMetadata gpsData: nil];
        }
        else
        {
            NSLog(@"###--->  - gathering original location");
            [self pGatherOriginalLocation: imageProcessor.assetURL andWriteToPhotoLibrary: image];
        }

        if(writeOriginal)
        {
            NSLog(@"###--->  - writeOriginal");
            [self pWriteCGImageToSavedPhotosAlbum: imageProcessor.imageToProcess.CGImage
                                         metadata: imageProcessor.imageMetadata
                                          gpsData: nil
                                  writingOriginal: YES
                                  completionBlock: NULL];
        }

        self.imageProcessor = nil;
        self.processingImage = NO;
    }
    else {
        NSLog(@"###---> [CPV] pImageProcessorDone - skip");
    }
}

- (void) pBeginProcessingPhoto: (CGSize) imageSize
{
    NSLog(@"###---> [CPV] pBeginProcessingPhoto %@", NSStringFromCGSize(imageSize));
    if(self.processingImage == NO && self.photoToProcess)
    {

        [self clearBackgroundImage];
        CGFloat     scale = 0.5;

        if([[NSUserDefaults standardUserDefaults] boolForKey: CPFullSizeImageOptionKey])
        {
            scale = 1.0;
        }

        self.imageProcessor = [[CPImageProcessor alloc] initWithImage: self.photoToProcess
                                                             metadata: self.photoMetadata
                                                      assetLibraryURL: self.photoAssetLibraryURL
                                                                scale: scale
                                                             cropRect: CGRectZero
                                                          wasCaptured: self.photoWasCaptured];

        self.imageProcessor.queuePriority = NSOperationQueuePriorityVeryHigh;
        self.imageProcessor.curvesPath = [self pCurvesPathFromUserSetting];

        // These are temporary instance variables

        self.photoToProcess = nil;
        self.photoMetadata = nil;
        self.photoAssetLibraryURL = nil;
        self.photoWasCaptured = NO;

        if(!self.imageQueue)
        {
            self.imageQueue = [[NSOperationQueue alloc] init];
        }

        [self.imageProcessor addObserver: self forKeyPath: @"isFinished"  options: 0 context: &self->_imageProcessor];
        self.processingImage = YES;
        [self.imageQueue addOperation: self.imageProcessor];

        // Start by adding an empty slot for the 0-th image and then update the scroll view content/metrics

        NSInteger       placeholderAsset = [self pPlaceholderTypeFromCurveName: self.imageProcessor.curvesPath];
        if(self.imageProcessor.portraitOrientation == NO)
        {
            placeholderAsset *= -1;
        }

        [self.processedImages insertObject: [NSNumber numberWithInteger: placeholderAsset] atIndex: 0];
        [self pCreateAndAnimatePlaceholderView: imageSize];
    }
    else {
        NSLog(@"###---> [CPV] pBeginProcessingPhoto - skip. Already processing");
    }
}

- (void) pHandleSingleTap: (UITapGestureRecognizer*) sender
{
#if DEBUG
    CGRect      visibleBounds = self.scrollView.bounds;
    NSInteger   firstNeededViewIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    NSInteger   lastNeededViewIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    firstNeededViewIndex = MAX(firstNeededViewIndex, 0);
    lastNeededViewIndex  = MIN(lastNeededViewIndex, self.processedImages.count - 1);

//    NSLog(@"###---> firstNeededViewIndex = %d, lastNeededViewIndex = %d, processedImageAsset = %@", firstNeededViewIndex, lastNeededViewIndex, self.processedImages.count > 0 ? [self.processedImages objectAtIndex: firstNeededViewIndex] : nil);
#endif

    [self toggleToolbarVisibility];
}

- (BOOL) gestureRecognizer: (UIGestureRecognizer*) gestureRecognizer shouldReceiveTouch: (UITouch*) touch
{
    BOOL    shouldReceive = YES;

    if([touch.view isKindOfClass:[UIControl class]])
    {
        return NO;
    }

    return shouldReceive;
}

- (void) pHandleWelcomeTap: (UITapGestureRecognizer*) sender
{
    UIView*  rootView = [sender.view superview];
    UIView*  welcomeView = [rootView viewWithTag: CPWelcomeViewTag];

    [UIView transitionFromView: welcomeView
                        toView: self.view
                      duration: 1.0
                       options: UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionCrossDissolve
                    completion: ^(BOOL finished)
     {
         [welcomeView removeFromSuperview];
         [self presentDefaultPhotoController];
     }];
}

- (void) pSetupPhotoCaptureSound
{
    if(self.captureSound == 0)
    {
        OSStatus            status = kAudioServicesNoError;
        SystemSoundID       soundID = 0;

        status = AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource:@"CameraNoise" ofType:@"aif"]], &soundID);
        if(status == kAudioServicesNoError)
        {
            self.captureSound = soundID;
        }
    }
}

- (void) pPlayPhotoCaptureSound
{
    [self pSetupPhotoCaptureSound];
    if(self.captureSound)
    {
        AudioServicesPlaySystemSound(self.captureSound);
    }
}

- (CPPlaceholderType) pPlaceholderTypeFromCurveName: (NSString*) curvePath
{
    NSString*           curveName = [[curvePath lastPathComponent] stringByDeletingPathExtension];
    CPPlaceholderType   type = CPPlaceholderBasic;

    if([curveName isEqualToString: @"red"])
    {
        type = CPPlaceholderRed;
    }
    else if([curveName isEqualToString: @"green"])
    {
        type = CPPlaceholderGreen;
    }
    else if([curveName isEqualToString: @"blue"])
    {
        type = CPPlaceholderBlue;
    }
    else if([curveName isEqualToString: @"basic"])
    {
        type = CPPlaceholderBasic;
    }
    else if([curveName isEqualToString: @"extreme"])
    {
        type = CPPlaceholderExtreme;
    }
    else if([curveName isEqualToString: @"negative"])
    {
        type = CPPlaceholderNegative;
    }

    if([[NSUserDefaults standardUserDefaults] boolForKey: CPWantsBorderOptionKey])
    {
        type |= CPPlaceholderBorder;
    }

    return type;
}

- (NSString*) pCurvesPathFromUserSetting
{
    NSString*           path = nil;
    NSMutableArray*     choices = [NSMutableArray arrayWithCapacity: 5];
    NSUserDefaults*     defaults = [NSUserDefaults standardUserDefaults];

    if([defaults boolForKey: CPRedProcessingOptionKey])
    {
        [choices addObject: @"red"];
    }

    if([defaults boolForKey: CPBlueProcessingOptionKey])
    {
        [choices addObject: @"blue"];
    }

    if([defaults boolForKey: CPGreenProcessingOptionKey])
    {
        [choices addObject: @"green"];
    }

    if([defaults boolForKey: CPBasicProcessingOptionKey])
    {
        [choices addObject: @"basic"];
    }

    if([defaults boolForKey: CPExtremeProcessingOptionKey])
    {
        [choices addObject: @"extreme"];
    }

    if(choices.count == 0)
    {
        [choices addObject: @"negative"];
    }

    NSInteger  choiceIndex = lrand48() % choices.count;
    path = [[NSBundle mainBundle] pathForResource: [choices objectAtIndex: choiceIndex] ofType: @"acv"];
    return path;
}

- (BOOL) pWriteOriginalImage
{
    BOOL    shouldWrite = NO;

    if(self.imageProcessor.wasCaptured && [[NSUserDefaults standardUserDefaults] boolForKey: CPKeepOriginalOptionKey])
    {
        shouldWrite = YES;
    }

    return shouldWrite;
}


- (NSString*) pFileExtensionForUTI: (NSString*) uti
{
	NSString*	extension = @"";

	if([uti isEqualToString: @"public.jpeg"])
	{
		extension = @"jpeg";
	}
	else if([uti isEqualToString: @"public.png"])
	{
		extension = @"png";
	}

	return extension;
}

- (NSString*) pMimeTypeForUTI: (NSString*) uti
{
	NSString*	mimeType = @"";

	if([uti isEqualToString: @"public.jpeg"])
	{
		mimeType = @"image/jpeg";
	}
	else if([uti isEqualToString: @"public.png"])
	{
		mimeType = @"image/png";
	}

	return mimeType;
}



- (void) pLoadAsset: (NSURL*) assetURL usingDataCompletionBlock: (CPLoadAssetDataCompletionBlock) completionBlock
{
    if(completionBlock)
    {
        ALAssetsLibrary*	library = [[ALAssetsLibrary alloc] init]; //AppDelegate().assetLibrary;

        [library assetForURL: assetURL
                 resultBlock:^(ALAsset *asset)
         {
             assert([NSThread isMainThread]);

             ALAssetRepresentation*     rep = [asset defaultRepresentation];
             BOOL                       didFail = YES;

             if(rep)
             {
                 unsigned long              size = (unsigned long)[rep size];
                 uint8_t*				buffer = (uint8_t*)malloc(size);

                 if(buffer)
                 {
                     NSError*           error = nil;
                     NSUInteger         numBytes = 0;
                     numBytes = [rep getBytes: buffer fromOffset: 0 length: size error: &error];

                     if(numBytes > 0 && !error)
                     {
                         NSData*    photoData = [[NSData alloc] initWithBytes: buffer length: size];

                         didFail = NO;
                         completionBlock(photoData, [rep UTI], didFail);
                     }
                     else if(error)
                     {
                         NSLog(@"###---> ALAssetRepresentation -getBytes::: failed - %@", [error description]);
                     }

                     free(buffer);
                 }
             }

             if(didFail)
             {
                 completionBlock(nil, nil, YES);
             }

         }
                failureBlock:^(NSError *error)
         {
             NSLog(@"###---> %@", [error description]);
             completionBlock(nil, nil, YES);
         }];
    }
}

- (void) pLoadAsset: (NSURL*) assetURL usingImageCompletionBlock: (CPLoadAssetImageCompletionBlock) completionBlock
{
    if(completionBlock)
    {
        ALAssetsLibrary*	library = [[ALAssetsLibrary alloc] init]; // AppDelegate().assetLibrary;

        [library assetForURL: assetURL
                 resultBlock:^(ALAsset *asset)
         {
             assert([NSThread isMainThread]);

             ALAssetRepresentation*     rep = [asset defaultRepresentation];
             BOOL                       didFail = YES;

             if(rep)
             {
                 UIImage* image = [UIImage imageWithCGImage: [rep fullResolutionImage]];
                 if(image)
                 {
                     didFail = NO;
                     completionBlock(image, [rep UTI], didFail);
                 }
             }

             if(didFail)
             {
                 completionBlock(nil, nil, YES);
             }

         }
                failureBlock:^(NSError *error)
         {
             NSLog(@"###---> %@", [error description]);
             completionBlock(nil, nil, YES);
         }];
    }
}


#pragma mark - Frame calculations

- (void) pAdjustScrollViewFrame
{
    CGRect frame = self.scrollView.frame;
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);

    self.scrollView.frame = frame;
}

- (CGRect) pFrameForScrollView
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return frame;
}

- (CGSize) pContentSizeForScrollView
{
    CGRect bounds = self.scrollView.bounds;
    return CGSizeMake(bounds.size.width * self.processedImages.count, bounds.size.height);
}

- (CGRect) pFrameForViewAtIndex: (NSInteger) index
{
    CGRect bounds = self.scrollView.bounds;
    CGRect viewFrame = bounds;
    viewFrame.size.width -= (2 * PADDING);
    viewFrame.origin.x = (bounds.size.width * index) + PADDING;

    return viewFrame;
}

- (void) pConfigureView: (UIView*) view forIndex: (NSInteger) index
{
    CGRect  viewFrame = [self pFrameForViewAtIndex: index];
    view.frame = viewFrame;
    view.index = index;
}

- (BOOL) pIsDisplayingViewForIndex: (NSUInteger) index visibleView: (BCImageView**) visibleView
{
    BOOL foundView = NO;

    for(BCImageView* view in self.visibleImageViews)
    {
        if(view.index == index)
        {
            foundView = YES;

            if(visibleView)
            {
                *visibleView = view;
            }
            break;
        }
    }

    return foundView;
}

- (BCImageView*) pDequeueRecycledView
{
    BCImageView* view = [self.recycledImageViews anyObject];
    if(view)
    {
        [self.recycledImageViews removeObject: view];
    }
    return view;
}

- (void) pTileViews
{
    /*
    CGSize  contentSize = [self pContentSizeForScrollView];

    if(!CGSizeEqualToSize(contentSize, self.scrollView.contentSize))
    {
        self.scrollView.contentSize = contentSize;
    }
    */

    CGRect      visibleBounds = self.scrollView.bounds;
    NSInteger   firstNeededViewIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds)) - 1;
    NSInteger   lastNeededViewIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds)) + 1;
    firstNeededViewIndex = MAX(firstNeededViewIndex, 0);
    lastNeededViewIndex  = MIN(lastNeededViewIndex, self.processedImages.count - 1);

    // Recycle no-longer-visible pages

    for(BCImageView* view in self.visibleImageViews)
    {
        if(view.index < firstNeededViewIndex || view.index > lastNeededViewIndex)
        {
            [self.recycledImageViews addObject: view];
            [view clearContent];
            [view removeFromSuperview];
        }
    }

    [self.visibleImageViews minusSet: self.recycledImageViews];

    // add missing pages

    for(NSInteger index = firstNeededViewIndex; index <= lastNeededViewIndex; index++)
    {
        if(![self pIsDisplayingViewForIndex: index visibleView: NULL])
        {
            id              asset = [self.processedImages objectAtIndex: index];

            // We want an empty slot if the processed images slot if a placeholder
            if(BCCastAsClass(NSNumber, asset) == nil)
            {
                BCImageView*    imageView = [self pDequeueRecycledView];

                if(imageView == nil)
                {
                    imageView = [[BCImageView alloc] initWithFrame: BCViewFrame photoProvider:[[PhotoSource alloc] init]];
                }

                [self pConfigureView: imageView forIndex: index];

                [imageView useAsset: asset];

                [self.scrollView addSubview: imageView];
                [self.visibleImageViews addObject: imageView];
            }
        }
    }
}

- (NSURL*) pURLForVisibleImageView
{
    NSURL*      url = nil;

    CGRect      visibleBounds = self.scrollView.bounds;
    NSInteger   firstNeededViewIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    firstNeededViewIndex = MAX(firstNeededViewIndex, 0);

    if(firstNeededViewIndex >= 0 && firstNeededViewIndex < self.processedImages.count)
    {
        url = BCCastAsClass(NSURL, [self.processedImages objectAtIndex: firstNeededViewIndex]);
    }

    return url;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)setBackgroundImage {
    self.backgroundImage.hidden = NO;
}

-(void)clearBackgroundImage {
    self.backgroundImage.hidden = YES;
}

@end
