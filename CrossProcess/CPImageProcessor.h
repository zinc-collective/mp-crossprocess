//
//  CPImageProcessor.h
//  CrossProcess
//
//  Copyright 2010-2013 Banana Camera Company. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BCImage;

@interface CPImageProcessor : NSOperation

@property(strong, nonatomic, readonly) UIImage* imageToProcess;
@property(strong, nonatomic, readonly) NSDictionary* imageMetadata;
@property(strong, nonatomic, readonly) NSURL* assetURL;
@property(strong, nonatomic, readonly) BCImage* processedImage;
@property(readonly, nonatomic) CGFloat scale;
@property(readonly, nonatomic) CGRect cropRect;
@property(readonly, nonatomic) BOOL wasCaptured;
@property(readonly, nonatomic) BOOL useBorder;
@property(readonly, nonatomic) BOOL portraitOrientation;
@property(strong, nonatomic) NSString* curvesPath;
@property(strong, nonatomic) NSURL* appSupportURL;

- (id) initWithImage: (UIImage*) image
            metadata: (NSDictionary*) imageMetadata
     assetLibraryURL: (NSURL*) assetURL
               scale: (CGFloat) scale 
            cropRect: (CGRect) cropRect
         wasCaptured: (BOOL) wasCaptured;

@end
