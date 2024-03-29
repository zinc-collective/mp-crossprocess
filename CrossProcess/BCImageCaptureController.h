//
//  BCImageCaptureController.h
//  CrossProcess
//
//  Copyright 2019 Zinc Collective LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const      BCCameraDeviceKey;
extern NSString* const      BCCameraFlashModeKey;

#pragma mark - BCImageCaptureController

@protocol BCImageCaptureControllerDelegate;

@interface BCImageCaptureController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (assign, nonatomic) id<BCImageCaptureControllerDelegate>    delegate;
@property (strong, nonatomic) UIImagePickerController* imagePickerController;

- (void) setupForImageCapture: (UIImagePickerControllerSourceType) sourceType;

@end

#pragma mark - BCImageCaptureControllerDelegate

@protocol BCImageCaptureControllerDelegate

- (void) userPickedPhoto: (UIImage*) photo withAssetLibraryURL: (NSURL*) url;
- (void) userCapturedPhoto: (UIImage*) photo withMetadata: (NSDictionary*) metadata;
- (void) userCancelled;

@end
