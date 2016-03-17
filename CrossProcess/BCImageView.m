//
//  BCImageView.m
//  CrossProcess
//
//  Copyright 2010-2013 Banana Camera Company. All rights reserved.
//

#import "BCImageView.h"
#import "BCImage.h"
#import "BCMiscellaneous.h"
#import "BCUtilities.h"
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>

const CGRect BCViewFrame = {{0.0, 0.0}, {320, 480}};

@interface BCImageView()
- (UIImage*) pLoadPlaceholderImage: (CPPlaceholderType) placeholderType;
- (UIImage*) pLoadPlaceholderBorderImage;
- (void) pUseImageURL: (NSURL*) imageURL;
- (void) pCrossFadeLayer;
@end

@implementation BCImageView

@synthesize portraitOrientation = _portraitOrientation;
@synthesize naturalSize = _naturalSize;

- (id) initWithFrame: (CGRect) frame
{
    if(self = [super initWithFrame: BCViewFrame])
    {
        self.layer.contentsGravity = kCAGravityResizeAspect;
    }
    
    return self;
}

/*
- (id) initWithImage: (BCImage*) image
{
    if(self = [super initWithFrame: BCViewFrame])
    {
        self.layer.contentsGravity = kCAGravityResizeAspect;
        self.layer.contents = (id)image.CGImageRef;
    }
    
    return self;
}

- (id) initWithPlaceholder: (CPPlaceholderType) placeholderType portraitOrientation: (BOOL) isPortrait;
{
    if(self = [super initWithFrame: BCViewFrame])
    {
        _portraitOrientation = isPortrait;
        
        UIImage*    placeholderImage = [self pLoadPlaceholderImage: placeholderType];

        if(self.portraitOrientation == NO)
        {
            CGSize      imageSize = placeholderImage.size;      // 320 wide x 428 high
            
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageSize.height, imageSize.width), YES, 0.0f);

            CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0f, imageSize.width);
            transform = CGAffineTransformRotate(transform, radians(-90));
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), transform);
            
            [placeholderImage drawAtPoint: CGPointZero];
            placeholderImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext(); 
        }

        self.layer.contentsGravity = kCAGravityResizeAspect;
        self.layer.contents = (id)placeholderImage.CGImage;
    }
    
    return self;
}
 
- (id) initWithImageURL: (NSURL*) imageURL
{
    if(self = [super initWithFrame: BCViewFrame])
    {
        self.layer.contentsGravity = kCAGravityResizeAspect;
        [self pUseImageURL: imageURL];
    }
    
    return self;
}

*/

- (void) drawRect: (CGRect) rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextStrokeRectWithWidth(context, rect, 4.0);
}

- (void) useAssetFrame: (NSString*) frame content: (NSString*) content
{
    UIImage*    frameAsset = [UIImage imageNamed: frame];
    UIImage*    contentAsset = [UIImage imageNamed: content];

    if(frameAsset && contentAsset)
    {
        CALayer*    frameLayer = [CALayer layer];
        frameLayer.contentsGravity = kCAGravityResizeAspect;
        frameLayer.bounds = self.layer.bounds;
        frameLayer.position = self.layer.position;
        frameLayer.contents = (__bridge id)frameAsset.CGImage;

        // We add a new layer to hold the content

        CALayer*    contentLayer = [CALayer layer];
        contentLayer.contentsGravity = kCAGravityResizeAspect;
        contentLayer.bounds = self.layer.bounds;
        contentLayer.position = self.layer.position;        
        contentLayer.contents = (__bridge id)contentAsset.CGImage;
        
        [self.layer addSublayer: contentLayer];
        [self.layer addSublayer: frameLayer];
    }
}

- (void) useAsset: (id) asset
{
    // Asset can be an a url, a uiimage, or a placeholder
    
    NSURL*      assetURL = BCCastAsClass(NSURL, asset);
    UIImage*    assetUIImage = BCCastAsClass(UIImage, asset);
    BCImage*    assetImage = BCCastAsClass(BCImage, asset);
    NSNumber*   assetPlaceholder = BCCastAsClass(NSNumber, asset);

    self.layer.contentsGravity = kCAGravityResizeAspect;
    if(self.layer.contents != nil)
    {
        CATransition*   crossfade = [CATransition animation];
        crossfade.type = kCATransitionFade;
        crossfade.duration = 2.0;
        
        [self.layer addAnimation: crossfade forKey: kCATransition];
    }
    
    if(assetURL)
    {
        [self pUseImageURL: assetURL];
    }
    else if(assetUIImage)
    {
        self.layer.contents = (__bridge id)assetUIImage.CGImage;
    }
    else if(assetImage)
    {
        CGImageRef  imageRef = assetImage.CGImageRef;
        self.layer.contents = (__bridge_transfer id)imageRef;
    }
    else if(assetPlaceholder)
    {
        NSInteger       placeholderType = [assetPlaceholder integerValue];
        
        _portraitOrientation = placeholderType >= 0;
        
        CPPlaceholderType       type = (CPPlaceholderType)abs(placeholderType);
        UIImage*                placeholderImage = [self pLoadPlaceholderImage: type];
        UIImage*                borderImage = nil;
        
        if((type & CPPlaceholderBorder) != 0)
        {
            borderImage = [self pLoadPlaceholderBorderImage];
        }
        
        if(CGSizeEqualToSize(self.naturalSize, CGSizeZero))
        {
            CGSize      imageSize = placeholderImage.size;      // 320 wide x 428 high
            
            if(self.portraitOrientation == NO)
            {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageSize.height, imageSize.width), YES, 0.0f);

                CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0f, imageSize.width);
                transform = CGAffineTransformRotate(transform, radians(-90));
                CGContextConcatCTM(UIGraphicsGetCurrentContext(), transform);
            }
            else 
            {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageSize.width, imageSize.height), YES, 0.0f);
            }
            
            [placeholderImage drawAtPoint: CGPointZero];
            [borderImage drawAtPoint: CGPointZero];
            
            placeholderImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext(); 
        }
        else
        {
            CGSize      placeholderSize = FitSizeWithSize(self.naturalSize, self.frame.size);

            UIGraphicsBeginImageContextWithOptions(CGSizeMake(placeholderSize.width, placeholderSize.height), YES, 0.0f);
            [placeholderImage drawInRect: CGRectMake(0.0, 0.0, placeholderSize.width, placeholderSize.height)];
            [borderImage drawInRect: CGRectMake(0.0, 0.0, placeholderSize.width, placeholderSize.height)];
            
            placeholderImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext(); 
        }

        self.layer.contents = (__bridge id)placeholderImage.CGImage;        
    }
    else
    {
        //assert(NULL);
    }
}

- (void) pUseImageURL: (NSURL*) imageURL
{
    if([imageURL isFileURL])
    {
        NSError*    error = nil;
        UIImage*    image = [UIImage imageWithData: [NSData dataWithContentsOfURL: imageURL
                                                                                    options: NSDataReadingMappedIfSafe 
                                                                                      error: &error]];
        
        if(image)
        {
            [self pCrossFadeLayer];
            self.layer.contentsGravity = kCAGravityResizeAspect;
            self.layer.contents = (id)image.CGImage;
        }
        else if(error)
        {
            NSLog(@"%@", [error description]);
        }
    }
    else
    {
        ALAssetsLibrary*	library = [[ALAssetsLibrary alloc] init]; // AppDelegate().assetLibrary;
        
        [library assetForURL: imageURL 
                 resultBlock:^(ALAsset *asset) 
         {
             assert([NSThread isMainThread]);
             
             ALAssetRepresentation*	rep = [asset defaultRepresentation];
             CGImageRef fullscreenImageRef = [rep fullScreenImage];
             
             if(fullscreenImageRef)
             {
                 [self pCrossFadeLayer];
                 self.layer.contentsGravity = kCAGravityResizeAspect;
                 self.layer.contents = (__bridge id)fullscreenImageRef;
             }
             else
             {
                 NSLog(@"Failed to load asset");
             }
         }   
                failureBlock:^(NSError *error)
         {
             NSLog(@"%@", [error description]);
         }];
    }
}

- (void) pCrossFadeLayer
{
    if(self.layer.contents != nil)
    {
        CATransition*   crossfade = [CATransition animation];
        crossfade.type = kCATransitionFade;
        crossfade.duration = 2.0;
        
        [self.layer addAnimation: crossfade forKey: kCATransition];
    }
}

- (void) clearContent
{
    // animate here?
    self.layer.contents = nil;
}

- (UIImage*) pLoadPlaceholderBorderImage
{
    UIImage*    image = [UIImage imageNamed: @"preview_border"];
    
    if(!image)
    {
#if DEBUG
        NSLog(@"[pLoadPlaceholderBorderImage] Using -imageNamed old school");
#endif
        image = [UIImage imageNamed: [@"preview_border" stringByAppendingPathExtension: @"png"]];
    }
    assert(image);
    
    return image;
}

- (UIImage*) pLoadPlaceholderImage: (CPPlaceholderType) placeholderType
{
    NSString*   placeholderName = nil;
    
    NSUInteger   type = placeholderType & ~CPPlaceholderBorder;
    
    switch(type)
    {
        case CPPlaceholderBasic:
        {
            placeholderName = @"basic";
            break;
        }
        case CPPlaceholderRed:
        {
            placeholderName = @"red";
            break;
        }
        case CPPlaceholderGreen:
        {
            placeholderName = @"green";
            break;
        }
        case CPPlaceholderBlue:
        {
            placeholderName = @"blue";
            break;
        }
        case CPPlaceholderExtreme:
        {
            placeholderName = @"extreme";
            break;
        }
        case CPPlaceholderNegative:
        {
            placeholderName = @"negative";
            break;
        }
        default:
        {
            break;
        }
    }
    
    UIImage*    image = nil;
    
    if(placeholderName)
    {
        image = [UIImage imageNamed: placeholderName];
        if(!image)
        {
#if DEBUG
            NSLog(@"[pLoadPlaceholderImage] Using -imageNamed old school");
#endif
            image = [UIImage imageNamed: [placeholderName stringByAppendingPathExtension: @"jpg"]];
        }
    }

    return image;
}

@end
