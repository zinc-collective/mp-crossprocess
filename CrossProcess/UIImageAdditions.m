//
//  UIImageAdditions.m
//  CrossProcess
//
//  Copyright 2019 Zinc Collective LLC. All rights reserved.
//

#import "UIImageAdditions.h"
#import "BCAppDelegate.h"
#import "BCMiscellaneous.h"
#import "BCTimer.h"

#pragma mark - UIImage(BananaCameraAdditions)

@implementation UIImage(BananaCameraAdditions)

- (void) createScaledImage: (CGSize) size atURL: (NSURL*) destinationURL
{
    NSFileManager*  fm = [NSFileManager defaultManager];

    if([destinationURL isFileURL] && [fm fileExistsAtPath: [destinationURL path]] == NO)
    {
        UIGraphicsBeginImageContextWithOptions(size, NO, 1.0);

        CGContextRef context = UIGraphicsGetCurrentContext();

        CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
        [self drawInRect: CGRectMake(0.0f, 0.0f, size.width, size.height)];

        UIImage*  scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        if(scaledImage)
        {
            NSData*   scaledImageData = UIImagePNGRepresentation(scaledImage);
            if(scaledImageData)
            {
                NSError*    error = nil;
                if([scaledImageData writeToURL: destinationURL options: NSDataWritingFileProtectionNone error: &error] == NO)
                {
                    NSLog(@"###---> Unabled to write scaled image to %@", destinationURL);
                }
            }

            UIGraphicsEndImageContext();
        }
    }
}

@end

#pragma mark - CPScaledImageCreator

@implementation CPScaledImageCreator

@synthesize appSupportURL = _appSupportURL;
@synthesize imageAssets = _imageAssets;
@synthesize imageAssetsNames = _imageAssetsNames;

- (id) init
{
    if(self = [super init])
    {
        id<BCAppDelegate>   appDelegate = BCCastAsProtocol(BCAppDelegate, [[UIApplication sharedApplication] delegate]);
        NSURL*              appSupportURL = [appDelegate appSupportURL];

        if(appSupportURL)
        {
            _appSupportURL = appSupportURL;
            _imageAssets = [NSDictionary dictionaryWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"image_assets"
                                                                                                       ofType: @"plist"]];
            _imageAssetsNames = [appDelegate imageAssetsNames];
        }
    }

    return self;
}

- (void) main
{
    UIBackgroundTaskIdentifier          backgroundIdent = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];

    NSUInteger  assetsCount = self.imageAssetsNames.count;

    for(NSUInteger asset = 0; asset < assetsCount; ++asset)
    {
        NSString*   assetName = [self.imageAssetsNames objectAtIndex: asset];
        UIImage*    image = [UIImage imageNamed: assetName];

        if(image)
        {
            for(NSDictionary* level1Items in [self.imageAssets allValues])
            {
                for(NSDictionary* level2Items in [level1Items allValues])
                {
                    @autoreleasepool
                    {
                        CGSize      resultingSize = CGSizeFromString([level2Items objectForKey: @"image-size"]);
                        NSURL*      assetURL = [self.appSupportURL URLByAppendingPathComponent: [level2Items objectForKey: assetName]];

                        [image createScaledImage: resultingSize atURL: assetURL];
                    }
                }
            }
        }
    }

#if DEBUG
    NSLog(@"###---> Finished creating scaled images...");
#endif

    [[UIApplication sharedApplication] endBackgroundTask: backgroundIdent];
}

@end
