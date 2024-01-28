//
//  BCImageView.h
//  CrossProcess
//
//  Copyright 2019 Zinc Collective LLC. All rights reserved.
//

#import "CrossProcess-Swift.h"
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

extern const CGRect BCViewFrame;

typedef enum
{
    CPPlaceholderBasic = 1 << 0,
    CPPlaceholderRed = 1 << 1,
    CPPlaceholderGreen = 1 << 2,
    CPPlaceholderBlue = 1 << 3,
    CPPlaceholderExtreme = 1 << 4,
    CPPlaceholderNegative = 1 << 5,

    CPPlaceholderBorder = 1 << 10
} CPPlaceholderType;

@class BCImage;

@interface BCImageView : UIView

/*
- (id) initWithImage: (BCImage*) image;
- (id) initWithImageURL: (NSURL*) imageURL;
- (id) initWithPlaceholder: (CPPlaceholderType) placeholderType portraitOrientation: (BOOL) isPortrait;
*/
- (id) initWithFrame: (CGRect) frame
       photoProvider: (id<PhotoProvider>) photoProvider;


- (void) clearContent;
- (void) useAsset: (id) asset;
- (void) useAssetFrame: (NSString*) frame content: (NSString*) content;

@property(nonatomic, readonly) BOOL portraitOrientation;
@property(nonatomic, assign) CGSize naturalSize;
@property(strong, nonatomic) id<PhotoProvider>     photoSource;

@end
