//
//  BCImageCaptureController.m
//  CrossProcess
//
//  Copyright 2019 Zinc Collective LLC. All rights reserved.
//

#import "CrossProcess-Swift.h"
#import "BCImageCaptureController.h"
#import "CPAppConstants.h"

NSString* const      BCCameraDeviceKey = @"BCCameraDevice";
NSString* const      BCCameraFlashModeKey = @"BCCameraFlashMode";

@implementation BCImageCaptureController

@synthesize delegate = _delegate;
@synthesize imagePickerController = _imagePickerController;
@synthesize imagePickerLibraryController = _imagePickerLibraryController;

- (id) initWithNibName: (NSString*) nibNameOrNil bundle: (NSBundle*) nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        PHPhotoLibrary* photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
        //https://ikyle.me/blog/2020/phpickerviewcontroller
        PHPickerConfiguration *config = [[PHPickerConfiguration alloc] initWithPhotoLibrary:photoLibrary];
        config.selectionLimit = 1;
        config.filter = [PHPickerFilter imagesFilter];

        self.imagePickerController = [[UIImagePickerController alloc] init];
        self.imagePickerController.delegate = self;
        self.imagePickerLibraryController = [[PHPickerViewController alloc] initWithConfiguration:config];
        self.imagePickerLibraryController.delegate = self;
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
            self.imagePickerController.cameraDevice = [defaults integerForKey: BCCameraDeviceKey];
        }

        if([defaults objectForKey: BCCameraFlashModeKey])
        {
            self.imagePickerController.cameraFlashMode = [defaults integerForKey: BCCameraFlashModeKey];
        }
    }
}

- (void) setupForPhotoLibraryCapture
{
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
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
    else {
        NSAssert(false, @"ERROR: Unsupported UIImagePickerControllerSourceType");
    }
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController*) picker
{
    [self.delegate userCancelled];
}


#pragma  mark - PHPickerViewControllerDelegate
//https://ikyle.me/blog/2020/phpickerviewcontroller
- (void) picker:(PHPickerViewController*) picker didFinishPicking:(NSArray<PHPickerResult *> *) results {
    if (results.count > 0) {
        for (PHPickerResult *result in results)
        {
            // Get UIImage
            NSItemProvider *provider = result.itemProvider;
            NSString* identifier = result.assetIdentifier;

            [provider loadImageWithCompletion:^(UIImage * _Nullable object, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"####-----> ERROR: %@", error.description);
                    NSAssert(false, @"ERROR");
                } else {
                    NSAssert(object != nil, @"UIImage should not be nil");
                    if ([object isKindOfClass:[UIImage class]])
                    {
//                        __weak UIImage *weakImage = object;
//                        __weak PHAsset *weakAsset = arrPhassets.firstObject;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate userPickedPhoto: object withPhotoLibraryAsset: identifier];
                        });
                        
                    }
                }
            }];
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
