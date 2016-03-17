//
//  BCImage.h
//  Baboon
//
//  Copyright 2010-2013 Banana Camera Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CGContext.h>
#import <CoreGraphics/CGImage.h>

@class BCImageCurve;
@class BCImageLevels;

@interface BCImage : NSObject
{
    @private
    CGContextRef        _contextRef;        // CGContext for the image
    uint32_t*           _rawBytes;          // Raw pixel buffer
    uint32_t            _bufferSize;        // Pixel buffer size in bytes
    uint32_t            _rowBytes;          // Number of bytes per row (16-byte aligned)
    
    CGSize              _size;              // Geometric size
	UIImageOrientation	_orientation;		// Orientation
    
    unsigned char       _reds[256];
    unsigned char       _greens[256];
    unsigned char       _blues[256];

}

@property(nonatomic, readonly) CGContextRef			context;
@property(nonatomic, readonly) uint32_t*            bytes;
@property(nonatomic, readonly) uint32_t             bufferSize;
@property(nonatomic, readonly) CGSize				size;
@property(nonatomic, readonly) CGImageRef			CGImageRef;
@property(nonatomic, readonly) UIImageOrientation   orientation;

+ (CGColorSpaceRef) deviceRGBColorSpace;
+ (CGColorRef) genericGrayColor80;

//+ (BCImage*) imageWithUIImage: (UIImage*) image scale: (CGFloat) scale crop: (CGRect) crop;
- (id) initWithSize: (CGSize) imageSize scale: (CGFloat) scale orientation: (UIImageOrientation) orientation;

- (CGContextRef) pushContext;
- (void) popContext;

- (void) applyCurves: (NSArray*) curves;
- (void) applyLevels: (BCImageLevels*) levels;

@end

// RGBA - use this if CGImageAlphaInfo == kCGImageAlphaPremultipliedLast

#define ALPHA_COMPONENT_RGBA(pixel)      (unsigned char)(*pixel >> 24)
#define BLUE_COMPONENT_RGBA(pixel)       (unsigned char)(*pixel >> 16)
#define GREEN_COMPONENT_RGBA(pixel)      (unsigned char)(*pixel >> 8)
#define RED_COMPONENT_RGBA(pixel)        (unsigned char)(*pixel >> 0)

#define SET_ALPHA_COMPONENT_RGBA(pixel, value)      *pixel = (*pixel & 0x00FFFFFF) | (value << 24)
#define SET_BLUE_COMPONENT_RGBA(pixel, value)       *pixel = (*pixel & 0xFF00FFFF) | (value << 16)
#define SET_GREEN_COMPONENT_RGBA(pixel, value)      *pixel = (*pixel & 0xFFFF00FF) | (value << 8)
#define SET_RED_COMPONENT_RGBA(pixel, value)        *pixel = (*pixel & 0xFFFFFF00) | (value << 0)

// ARGB use this if CGImageAlphaInfo == kCGImageAlphaPremultipliedFirst
 
#define BLUE_COMPONENT_ARGB(pixel)		(unsigned char)(*pixel >> 24)
#define GREEN_COMPONENT_ARGB(pixel)      (unsigned char)(*pixel >> 16)
#define RED_COMPONENT_ARGB(pixel)		(unsigned char)(*pixel >> 8)
#define ALPHA_COMPONENT_ARGB(pixel)      (unsigned char)(*pixel >> 0)

#define SET_BLUE_COMPONENT_ARGB(pixel, value)       *pixel = (*pixel & 0x00FFFFFF) | (value << 24)
#define SET_GREEN_COMPONENT_ARGB(pixel, value)      *pixel = (*pixel & 0xFF00FFFF) | (value << 16)
#define SET_RED_COMPONENT_ARGB(pixel, value)        *pixel = (*pixel & 0xFFFF00FF) | (value << 8)
#define SET_ALPHA_COMPONENT_ARGB(pixel, value)      *pixel = (*pixel & 0xFFFFFF00) | (value << 0)

