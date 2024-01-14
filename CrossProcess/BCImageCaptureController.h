//
//  BCImageCaptureController.h
//  CrossProcess
//
//  Copyright 2019 Zinc Collective LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PhotosUI/PhotosUI.h>

extern NSString* const      BCCameraDeviceKey;
extern NSString* const      BCCameraFlashModeKey;

#pragma mark - BCImageCaptureController

@protocol BCImageCaptureControllerDelegate;

@interface BCImageCaptureController : UIViewController<UIImagePickerControllerDelegate, PHPickerViewControllerDelegate, UINavigationControllerDelegate>

@property (assign, nonatomic) id<BCImageCaptureControllerDelegate>    delegate;
@property (strong, nonatomic) UIImagePickerController* imagePickerController;
@property (strong, nonatomic) PHPickerViewController* imagePickerLibraryController;

- (void) setupForImageCapture: (UIImagePickerControllerSourceType) sourceType;
- (void) setupForPhotoLibraryCapture;

@end

#pragma mark - BCImageCaptureControllerDelegate

@protocol BCImageCaptureControllerDelegate

- (void) userPickedPhoto: (UIImage*) photo withPhotoLibraryAsset: (NSString*) identifier;
- (void) userCapturedPhoto: (UIImage*) photo withMetadata: (NSDictionary*) metadata;
- (void) userCancelled;

@end
