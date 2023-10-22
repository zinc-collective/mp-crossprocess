    //
//  CPImageProcessor.m
//  CrossProcess
//
//  Copyright 2019 Zinc Collective LLC. All rights reserved.
//

#import "CPImageProcessor.h"
#import "CPAppConstants.h"
#import "CPAppDelegate.h"
#import "BCUtilities.h"
#import "BCMiscellaneous.h"
#import "BCImage.h"
#import "BCImageCurve.h"
#import "BCTimer.h"
#import "UIImageAdditions.h"

@interface CPImageProcessor()
@property(strong, nonatomic) UIImage* imageToProcess;
@property(strong, nonatomic) NSDictionary* imageMetadata;
@property(strong, nonatomic) NSURL* assetURL;
@property(strong, nonatomic) BCImage* processedImage;
@property(assign, nonatomic) CGFloat scale;
@property(assign, nonatomic) CGRect cropRect;
@property(assign, nonatomic) BOOL wasCaptured;
@property(assign, nonatomic) BOOL useBorder;
@property(strong, nonatomic) NSDictionary* imageAssets;
@property(assign, nonatomic) BOOL portraitOrientation;

- (CGSize) pFindAppropriateImageSize;

- (void) pDrawImageAtPath: (NSString*) path
                blendMode: (CGBlendMode) blendMode
                    alpha: (CGFloat) alpha
                  inImage: (BCImage*) image
           finalImageSize: (CGSize) finalSize;

- (NSDictionary*) pImageAssetsForImageSize: (CGSize) imageSize scale: (CGFloat) scale;
- (NSData*) pLoadAsset: (NSURL*) assetURL;
- (NSData*) pLoadAndCacheAsset: (NSURL*) assetURL;
- (CGSize) pAssetSizeForName: (NSString*) assetName assetClass: (NSString*) assetClass;

@end

@implementation CPImageProcessor

@synthesize imageToProcess = _imageToProcess;
@synthesize processedImage = _processedImage;
@synthesize scale = _scale;
@synthesize cropRect = _cropRect;
@synthesize wasCaptured = _wasCaptured;
@synthesize curvesPath = _curvesPath;
@synthesize imageAssets = _imageAssets;
@synthesize useBorder = _useBorder;
@synthesize imageMetadata = _imageMetadata;
@synthesize assetURL = _assetURL;
@synthesize portraitOrientation = _portraitOrientation;
@synthesize appSupportURL = _appSupportURL;

- (id) initWithImage: (UIImage*) image
            metadata: (NSDictionary*) imageMetadata
     assetLibraryURL: (NSURL*) assetURL
               scale: (CGFloat) scale
            cropRect: (CGRect) cropRect
         wasCaptured: (BOOL) wasCaptured
{
    if(self = [super init])
    {
        self.imageToProcess = image;
        self.imageMetadata = imageMetadata;
        self.assetURL = assetURL;
        self.scale = scale;
        self.cropRect = cropRect;
        self.wasCaptured = wasCaptured;

        CGSize imageSize = image.size;
        self.portraitOrientation = imageSize.height >= imageSize.width;
        self.useBorder = [[NSUserDefaults standardUserDefaults] boolForKey: CPWantsBorderOptionKey];
        self.imageAssets = [NSDictionary dictionaryWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"image_assets"
                                                                                                       ofType: @"plist"]];

        CPAppDelegate*  appDelegate = BCCastAsClass(CPAppDelegate, [[UIApplication sharedApplication] delegate]);
        _appSupportURL = [appDelegate appSupportURL];
    }

    return self;
}

- (void) main
{
    NSLog(@"###---> [CPIP] main");
    BCTimer*    timer = [[BCTimer alloc] init];
    [timer startTimer];

    // This method is called by a thread that's set up for us by the NSOperationQueue.
    assert(![NSThread isMainThread]);

    if(!self.imageToProcess)
    {
        NSLog(@"###---> No image to process!");
    }
    else
    {
        UIBackgroundTaskIdentifier          backgroundIdent = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];

        CGFloat         scale = self.scale;
        CGSize          imageSize = [self pFindAppropriateImageSize];
        NSDictionary*   imageAssets = [self pImageAssetsForImageSize: imageSize scale: scale];

        NSLog(@"###--->  - imageSize = %@", NSStringFromCGSize(imageSize));
        NSLog(@"###--->  - Assets = %@", imageAssets);

        if(!imageAssets) {
            NSAssert(false, @"MISSING IMAGE ASSETS %@", NSStringFromCGSize(imageSize));
        }

        else
        {
            // We don't scale FFC images or iPod Touch image sizes

            if(self.portraitOrientation)
            {
                if(CGSizeEqualToSize(imageSize, CPFFCNativeImageSize) ||
                   CGSizeEqualToSize(imageSize, CPTouchNativeImageSize) ||
                   CGSizeEqualToSize(imageSize, CPFFCNativeImageSize5))
                {
                    scale = 1.0;
                }
            }
            else
            {
                CGSize  orientedSize = CGSizeMake(imageSize.height, imageSize.width);
                if(CGSizeEqualToSize(orientedSize, CPFFCNativeImageSize) ||
                   CGSizeEqualToSize(orientedSize, CPTouchNativeImageSize) ||
                   CGSizeEqualToSize(orientedSize, CPFFCNativeImageSize5))
                {
                    scale = 1.0;
                }
            }

//            NSLog(@"###---> Scale is: %f", scale);

            BCImage*    processedImage = [[BCImage alloc] initWithSize: self.imageToProcess.size
                                                                 scale: scale
                                                           orientation: self.imageToProcess.imageOrientation];

//            NSLog(@"###---> Processed Image %@", processedImage);
            if(processedImage)
            {
                /* Steps in the image processing for CrossProcess
                 1. Render the image scaled, cropped, and interpolated
                 2. If the curve isn't a negative curve, apply the vignette overlay
                 3. Apply the chosen curve to the image
                 4. Apply a gray blend with an alpha that is based on the chosen curve
                 5. Apply the screen image
                 6. If the settings requested a border, apply the final border
                 */

//                NSLog(@"###--->  - doing the stuff");

                CGSize      sourceImageSize = self.imageToProcess.size;

                [processedImage pushContext];

                CGAffineTransform   scaleXForm = CGAffineTransformMakeScale(scale, scale);
                CGContextSetInterpolationQuality(processedImage.context, kCGInterpolationHigh);
                CGContextConcatCTM(processedImage.context, scaleXForm);
                CGContextConcatCTM(processedImage.context, AdjustedTransform(self.imageToProcess.imageOrientation,
                                                                             sourceImageSize.width,
                                                                             sourceImageSize.height));

//                NSLog(@"###--->  - drawing");

                /*
                 CGRect  imageRect = CGRectZero;
                 imageRect.size = FitSizeWithSize(sourceImageSize, imageSize);
                 imageRect = Copyright 2019 Zinc Collective LLCOverRect(imageRect, CGRectMake(0, 0, imageSize.width, imageSize.height));
                 */

                CGContextDrawImage(processedImage.context,
                                   CGRectMake(0.0, 0.0, sourceImageSize.width, sourceImageSize.height),
                                   self.imageToProcess.CGImage);

                //CGContextSetBlendMode(resultImage.context, kCGBlendModeOverlay);
                //CGContextDrawImage(resultImage.context, CGRectMake(0.0, 0.0, sourceSize.width, sourceSize.height), image.CGImage);

                [processedImage popContext];

//                NSLog(@"###--->  - curves?");

                NSString*   curvesName = [self.curvesPath lastPathComponent];

                CGSize      processedImageSize = processedImage.size;
                CGRect      processedImageRect = CGRectMake(0.0, 0.0, processedImageSize.width, processedImageSize.height);


                if([curvesName isEqualToString: @"negative.acv"] == NO)
                {
//                    NSLog(@"###--->  - drawing vignette");
                    [self pDrawImageAtPath: [imageAssets objectForKey: @"vignette"]
                                 blendMode: kCGBlendModeOverlay
                                     alpha: 1.0
                                   inImage: processedImage
                            finalImageSize: processedImage.size];
                }

                if(self.curvesPath)
                {
//                    NSLog(@"###--->  - applying curves");
                    NSArray* imageCurves = [BCImageCurve imageCurvesFromACV: self.curvesPath];
                    [processedImage applyCurves: imageCurves];
                }

                CGContextSaveGState(processedImage.context);

                CGColorRef  greyColor = CreateDeviceGrayColor(0.8f, 1.0f);
                CGFloat		alpha = 1.0;

                if([curvesName isEqualToString: @"basic.acv"])
                {
                    alpha = 0.10f;
                }
                else if([curvesName isEqualToString: @"red.acv"])
                {
                    alpha = 0.27f;
                }
                else if([curvesName isEqualToString: @"green.acv"])
                {
                    alpha = 0.30f;
                }
                else if([curvesName isEqualToString: @"blue.acv"])
                {
                    alpha = 0.24f;
                }
                else if([curvesName isEqualToString: @"extreme.acv"])
                {
                    alpha = 0.20f;
                }
                else if([curvesName isEqualToString: @"negative.acv"])
                {
                    alpha = 0.20f;
                }


//                NSLog(@"###--->  - applying alpha and blend");
                CGContextSetFillColorWithColor(processedImage.context, greyColor);
                CGContextSetBlendMode(processedImage.context, kCGBlendModeColor);
                CGContextSetAlpha(processedImage.context, alpha);
                CGContextFillRect(processedImage.context, processedImageRect);

                CGContextRestoreGState(processedImage.context);
                CGColorRelease(greyColor);


//                NSLog(@"###--->  - drawing screen");

                [self pDrawImageAtPath: [imageAssets objectForKey: @"screen"]
                             blendMode: kCGBlendModeScreen
                                 alpha: 1.0
                               inImage: processedImage
                        finalImageSize: processedImage.size];

                if(self.useBorder)
                {
//                    NSLog(@"###--->  - drawing border");
                    [self pDrawImageAtPath: [imageAssets objectForKey: @"border"]
                                 blendMode: kCGBlendModeNormal
                                     alpha: 1.0
                                   inImage: processedImage
                            finalImageSize: processedImage.size];
                }


//                NSLog(@"###--->  - done!");
                self.processedImage = processedImage;
            }


//            NSLog(@"###--->  - stopping timer");
            [timer stopTimer];
            [timer logElapsedInMilliseconds: @"Time to process image"];

            [[UIApplication sharedApplication] endBackgroundTask: backgroundIdent];
        }
    }
}

- (CGSize) pFindAppropriateImageSize
{
    CGSize      computedSize;
    CGSize      imageSize = self.imageToProcess.size;

    if(self.wasCaptured)
    {
        computedSize = imageSize;
    }
    else
    {
        CGSize  imageSizes[5] = { CPFFCNativeImageSize,
            CPTouchNativeImageSize,
            CP3GSNativeImageSize,
            CP4NativeImageSize,
            CP4SNativeImageSize };

        if(self.portraitOrientation)
        {
            if((imageSize.width == CP3GSNativeImageSize.width && imageSize.height == CP3GSNativeImageSize.height) ||
               (imageSize.width == CP4NativeImageSize.width && imageSize.height == CP4NativeImageSize.height) ||
               (imageSize.width == CP4SNativeImageSize.width && imageSize.height == CP4SNativeImageSize.height) ||
               (imageSize.width == CPFFCNativeImageSize.width && imageSize.height == CPFFCNativeImageSize.height) ||
               (imageSize.width == CPTouchNativeImageSize.width && imageSize.height == CPTouchNativeImageSize.height) ||
               (imageSize.width == CPFFCNativeImageSize5.width && imageSize.height == CPFFCNativeImageSize5.height))
            {
                computedSize = imageSize;
            }
            else
            {
                computedSize = imageSizes[0];

                for(NSInteger i = 0; i < 5; ++i)
                {
                    if((imageSize.width <= imageSizes[i].width) && (imageSize.height <= imageSizes[i].height))
                    {
                        break;
                    }
                    computedSize = imageSizes[i];
                }
            }
        }
        else
        {
            if((imageSize.height == CP3GSNativeImageSize.width && imageSize.width == CP3GSNativeImageSize.height) ||
               (imageSize.height == CP4NativeImageSize.width && imageSize.width == CP4NativeImageSize.height) ||
               (imageSize.height == CP4SNativeImageSize.width && imageSize.width == CP4SNativeImageSize.height) ||
               (imageSize.height == CPFFCNativeImageSize.width && imageSize.width == CPFFCNativeImageSize.height) ||
               (imageSize.height == CPTouchNativeImageSize.width && imageSize.width == CPTouchNativeImageSize.height) ||
               (imageSize.height == CPFFCNativeImageSize5.width && imageSize.width == CPFFCNativeImageSize5.height))
            {
                computedSize = imageSize;
            }
            else
            {
                computedSize.width = imageSizes[0].height;
                computedSize.height = imageSizes[0].width;

                for(NSInteger i = 0; i < 5; ++i)
                {
                    if((imageSize.width <= imageSizes[i].height) && (imageSize.height <= imageSizes[i].width))
                    {
                        break;
                    }
                    computedSize.width = imageSizes[i].height;
                    computedSize.height = imageSizes[i].width;
                }
            }
        }
    }

    return computedSize;
}

- (void) pDrawImageAtPath: (NSString*) path
                blendMode: (CGBlendMode) blendMode
                    alpha: (CGFloat) alpha
                  inImage: (BCImage*) image
		   finalImageSize: (CGSize) finalSize
{
    NSLog(@"###---> [CPIP] pDrawImageAtPath");
    if(path && self.appSupportURL)
    {
        NSURL*      assetURL = [self.appSupportURL URLByAppendingPathComponent: path];
        NSData*     imageData = [self pLoadAsset: assetURL];
        if(imageData)
        {
            CGDataProviderRef	dataProvider = CGDataProviderCreateWithCFData((__bridge CFDataRef)imageData);
            if(dataProvider)
            {
                CGImageRef		imageRef = CGImageCreateWithPNGDataProvider(dataProvider, NULL, false, kCGRenderingIntentDefault);
//                NSLog(@"###--->  - imageRef %@ %@", imageRef, image.context);
                if(imageRef)
                {
                    CGContextSaveGState(image.context);

                    CGContextSetAlpha(image.context, alpha);
                    CGContextSetBlendMode(image.context, blendMode);

                    CGRect		imageRect = CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));

//                    NSLog(@"###--->  - finished first context stuff");

                    // Rotate the portrait asset to landscape if necessary as we only store assets in portrait orientation

                    if(!self.portraitOrientation)
                    {
//                        NSLog(@"###--->  - landscape");
                        CGFloat		hScale = finalSize.width / imageRect.size.height;
                        CGFloat		vScale = finalSize.height / imageRect.size.width;
                        CGContextScaleCTM(image.context, hScale, vScale);

                        CGAffineTransform   transform = CGAffineTransformMakeTranslation(0.0, imageRect.size.width);
                        transform = CGAffineTransformRotate(transform, radians(-90));
                        CGContextConcatCTM(image.context, transform);
                    }
                    else
                    {
//                        NSLog(@"###--->  - portrait");
                        CGFloat		hScale = finalSize.width / imageRect.size.width;
                        CGFloat		vScale = finalSize.height / imageRect.size.height;

                        CGContextScaleCTM(image.context, hScale, vScale);
                    }

                    // TODO: Apply scale if image isn't the correct size.

//                    NSLog(@"###--->  - draw");
                    CGContextDrawImage(image.context, imageRect, imageRef);

                    CGImageRelease(imageRef);
                    CGContextRestoreGState(image.context);
//                    NSLog(@"###--->  - done");
                }

                CGDataProviderRelease(dataProvider);
            }
        }
        else
        {
            NSLog(@"###---> Unabled to read asset: %@", assetURL);
        }
    }
}

- (NSDictionary*) pImageAssetsForImageSize: (CGSize) imageSize scale: (CGFloat) scale
{
    NSDictionary*   result = nil;

    if(imageSize.width == 480 || imageSize.height == 480)
    {
        result = [self.imageAssets objectForKey: @"480x640"];
    }
    else if(imageSize.width == 720 || imageSize.height == 720)
    {
        result = [self.imageAssets objectForKey: @"720x960"];
    }
    else if(imageSize.width == 1536 || imageSize.height == 1536)
    {
        result = [self.imageAssets objectForKey: @"1536x2048"];
    }
    else if(imageSize.width == 1936 || imageSize.height == 1936)
    {
        result = [self.imageAssets objectForKey: @"1936x2592"];
    }
    else if(imageSize.width == 2448 || imageSize.height == 2448)
    {
        result = [self.imageAssets objectForKey: @"2448x3264"];
    }
    else if(imageSize.width == 960 || imageSize.height == 1280)
    {
        result = [self.imageAssets objectForKey: @"960x1280"];
    }
    else {
        // default: use largest size we have
        // replace with larger if desired
        result = [self.imageAssets objectForKey: @"2448x3264"];
    }

    if(scale == 0.5)
    {
        result = [result objectForKey: @"50%"];
    }
    else // if(scale == 1.0)
    {
        result = [result objectForKey: @"100%"];
    }

    return result;
}

- (NSData*) pLoadAsset: (NSURL*) assetURL
{
    NSData*     data = nil;
    NSString*   asset = [[[assetURL path] lastPathComponent] stringByDeletingPathExtension];
    NSBundle*   mainBundle = [NSBundle mainBundle];
    NSError*    error = nil;

    data = [NSData dataWithContentsOfFile: [mainBundle pathForResource: asset ofType: @"png"]
                                  options: NSDataReadingMappedIfSafe
                                    error: &error];
    if(!data || error)
    {
        NSLog(@"###---> Failed to load asset: %@. Error: %@", asset, error);
    }

    return data;
}

/*
- (NSData*) pLoadAsset: (NSURL*) assetURL
{
    NSData*     data = nil;

    if(assetURL)
    {
        NSError*    error = nil;
        NSData*     data = [NSData dataWithContentsOfURL: assetURL options: NSDataReadingMappedIfSafe error: &error];

        if(!data || error)
        {
            NSString*   path = [assetURL path];
            NSBundle*   mainBundle = [NSBundle mainBundle];
            NSString*   imageName = nil;

            if([path rangeOfString: @"border"].length > 0)
            {
                imageName = @"border";
            }
            else if([path rangeOfString: @"vignette"].length > 0)
            {
                imageName = @"vignette";
            }
            else if([path rangeOfString: @"screen"].length > 0)
            {
                imageName = @"screen";
            }

            if(imageName)
            {
                data = [NSData dataWithContentsOfFile: [mainBundle pathForResource: imageName ofType: @"png"]
                                              options: NSDataReadingMappedIfSafe
                                                error: &error];
            }
        }
    }
    else
    {
        NSLog(@"###---> Unable to load asset at url: %@", assetURL);
    }

    return data;
}
*/

- (CGSize) pAssetSizeForName: (NSString*) assetName assetClass: (NSString*) assetClass
{
    CGSize  result = CGSizeZero;

    for(NSDictionary* level1Items in [self.imageAssets allValues])
    {
        for(NSDictionary* level2Items in [level1Items allValues])
        {
            if([[level2Items objectForKey: assetClass] isEqualToString: assetName])
            {
                result = CGSizeFromString([level2Items objectForKey: @"image-size"]);
                break;
            }
        }

        if(!CGSizeEqualToSize(result, CGSizeZero))
        {
            break;
        }
    }

    return result;
}

- (NSData*) pLoadAndCacheAsset: (NSURL*) assetURL
{
    // vignette_50%_480x640.png
    // vignette_50%_2448x3264.png

    static BOOL     sLocked = NO;
    NSData*         data = nil;

    if(assetURL)
    {
        NSError*    error = nil;
        data = [NSData dataWithContentsOfURL: assetURL options: NSDataReadingMappedIfSafe error: &error];

        // data doesn't exist so lets generate and cache the asset.

        if((!data || error) && !sLocked)
        {
            NSString*   path = [assetURL path];
            NSString*   assetClass = nil;
            UIImage*    image = nil;

            if([path rangeOfString: @"border"].length > 0)
            {
                image = [UIImage imageNamed: @"border"];
                assetClass = @"border";
            }
            else if([path rangeOfString: @"vignette"].length > 0)
            {
                image = [UIImage imageNamed: @"vignette"];
                assetClass = @"vignette";
            }
            else if([path rangeOfString: @"screen"].length > 0)
            {
                image = [UIImage imageNamed: @"screen"];
                assetClass = @"screen";
            }

            if(image)
            {
                NSString* assetName = [[assetURL path] lastPathComponent];
                CGSize  assetSize = [self pAssetSizeForName: (NSString*) assetName assetClass: assetClass];
                [image createScaledImage: assetSize atURL: assetURL];

                sLocked = YES;
                data = [self pLoadAndCacheAsset: assetURL];
                sLocked = NO;
            }
        }
    }

    return data;
}

@end
