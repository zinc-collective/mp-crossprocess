//
//  BCImageCaptureController.m
//  CrossProcess
//
//  Copyright 2010-2013 Banana Camera Company. All rights reserved.
//

#import "BCImageCaptureController.h"
#import "CPAppConstants.h"

NSString* const      BCCameraDeviceKey = @"BCCameraDevice";
NSString* const      BCCameraFlashModeKey = @"BCCameraFlashMode";

@implementation BCImageCaptureController

@synthesize delegate = _delegate;
@synthesize imagePickerController = _imagePickerController;

- (id) initWithNibName: (NSString*) nibNameOrNil bundle: (NSBundle*) nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.imagePickerController = [[UIImagePickerController alloc] init];
        self.imagePickerController.delegate = self;
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.userInteractionEnabled = NO;
}

- (void) viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) setupForImageCapture: (UIImagePickerControllerSourceType) sourceType
{
    self.imagePickerController.sourceType = sourceType;
    
    if(sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        // user wants to use the camera interface

        self.imagePickerController.showsCameraControls = YES;
        self.imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;

        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;

        NSUserDefaults*     defaults = [NSUserDefaults standardUserDefaults];
        
        if([defaults objectForKey: BCCameraDeviceKey])
        {
            NSLog(@"TEST %i", UIImagePickerControllerCameraDeviceRear);
            self.imagePickerController.cameraDevice = [defaults integerForKey: BCCameraDeviceKey];
        }
        
        if([defaults objectForKey: BCCameraFlashModeKey])
        {
            NSLog(@"TEST %i %i", UIImagePickerControllerCameraFlashModeAuto, [defaults integerForKey:BCCameraFlashModeKey]);
            self.imagePickerController.cameraFlashMode = [defaults integerForKey: BCCameraFlashModeKey];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void) imagePickerController: (UIImagePickerController*) picker didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    UIImage*    image = [info valueForKey: UIImagePickerControllerOriginalImage];
    
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        NSUserDefaults*     defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger: picker.cameraDevice forKey: BCCameraDeviceKey];
        [defaults setInteger: picker.cameraFlashMode forKey: BCCameraFlashModeKey];
        
        NSDictionary*   imageMetadata = [info objectForKey: UIImagePickerControllerMediaMetadata];
        [self.delegate userCapturedPhoto: image withMetadata: imageMetadata];
    }
    else if(picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary)
    {
        NSURL*   assetURL = [info objectForKey: UIImagePickerControllerReferenceURL];
        [self.delegate userPickedPhoto: image withAssetLibraryURL: assetURL];
    }
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController*) picker
{
    [self.delegate userCancelled];
}


@end
