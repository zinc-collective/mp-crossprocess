//
//  BCImage.mm
//  Baboon
//
//  Copyright 2010-2013 Banana Camera Company. All rights reserved.
//

#import "BCImage.h"
#import "BCImageCurve.h"
#import "BCImageLevels.h"
#import "BCUtilities.h"

@interface BCImage()
- (NSUInteger) pCurveApplyMask: (NSArray*) curves;

@end

@implementation BCImage

@synthesize context = _contextRef;
@synthesize bytes = _rawBytes;
@synthesize size = _size;
@synthesize bufferSize = _bufferSize;
@synthesize orientation = _orientation;

+ (CGColorSpaceRef) deviceRGBColorSpace
{
    static CGColorSpaceRef  sColorspace = nil;
    
    if(!sColorspace)
    {
        sColorspace = CGColorSpaceCreateDeviceRGB();
    }
    
    return sColorspace;
}

+ (CGColorRef) genericGrayColor80
{
    static CGColorRef   sGenericGrayColor80;
    
    if(!sGenericGrayColor80)
    {
        sGenericGrayColor80 = CreateDeviceGrayColor(0.8, 0.2);
    }
    
    return sGenericGrayColor80;
}

/*
+ (BCImage*) imageWithUIImage: (UIImage*) image scale: (CGFloat) scale crop: (CGRect) crop
{
    CGSize      sourceSize = image.size;
	CGSize      destinationSize = CGSizeZero;
    
	destinationSize.width = roundf(sourceSize.width * scale);
	destinationSize.height = roundf(sourceSize.height * scale);
    
    crop.size.width = roundf(crop.size.width * scale);
    crop.size.height = roundf(crop.size.height * scale);

    
    BCImage*    resultImage = [[BCImage alloc] initWithSize: destinationSize orientation: image.imageOrientation];
    
    if(resultImage)
    {
        CGAffineTransform   tf = CGAffineTransformMakeScale(scale, scale);
     
        [resultImage pushContext];
		
        CGContextSetInterpolationQuality(resultImage.context, kCGInterpolationHigh);
        CGContextConcatCTM(resultImage.context, tf);
        CGContextConcatCTM(resultImage.context, AdjustedTransform(image.imageOrientation, sourceSize.width, sourceSize.height));

        CGContextDrawImage(resultImage.context, CGRectMake(0.0, 0.0, sourceSize.width, sourceSize.height), image.CGImage);
        CGContextSetBlendMode(resultImage.context, kCGBlendModeOverlay);
        CGContextDrawImage(resultImage.context, CGRectMake(0.0, 0.0, sourceSize.width, sourceSize.height), image.CGImage);

        [resultImage popContext];
    }
    
    return resultImage;
}
*/

- (id) initWithSize: (CGSize) imageSize scale: (CGFloat) scale orientation: (UIImageOrientation) orientation
{
    if(self = [super init])
    {
        _size.width = roundf(imageSize.width * scale);
        _size.height = roundf(imageSize.height * scale);
        
        CGColorSpaceRef     colorSpace = [[self class] deviceRGBColorSpace];
        
        _rowBytes = _size.width * 4;
        _rowBytes = (_rowBytes + 15) & ~15;
        
        CGBitmapInfo    bitmapInfo = kCGImageAlphaPremultipliedLast;
        
        _bufferSize = _rowBytes * _size.height;
        _rawBytes = (uint32_t*)calloc(sizeof(unsigned char), _bufferSize);
        _contextRef = CGBitmapContextCreate(_rawBytes, _size.width, _size.height, 8, _rowBytes, colorSpace, bitmapInfo);
		_orientation = orientation;
    }
    
    return  self;
}

- (void) dealloc
{
    CGContextRelease(_contextRef);
    _contextRef = NULL;
    
	if(_rawBytes)
	{
		free(_rawBytes);
		_rawBytes = NULL;
	}
}

- (CGContextRef) pushContext
{
    if(_contextRef)
    {
        UIGraphicsPushContext(_contextRef);
        CGContextSaveGState(_contextRef);
    }
    
    return _contextRef;
}

- (void) popContext
{
    if(_contextRef)
    {
        CGContextRestoreGState(_contextRef);
        UIGraphicsPopContext();
    }
}

- (CGImageRef) CGImageRef
{
    CGImageRef  result = NULL;

    if(_contextRef)
    {
        result = CGBitmapContextCreateImage(_contextRef);
    }
    
    return result;
}

- (NSUInteger) pCurveApplyMask: (NSArray*) curves
{
    BCImageCurve*   rgbCurve = [curves objectAtIndex: 0];
    BCImageCurve*   redCurve = [curves objectAtIndex: 1];
    BCImageCurve*   greenCurve = [curves objectAtIndex: 2];
    BCImageCurve*   blueCurve = [curves objectAtIndex: 3];
    
    return ((rgbCurve.identity ? 0 : CURVE_COLORS) |
            (redCurve.identity ? 0 : CURVE_RED) |
            (greenCurve.identity ? 0 : CURVE_GREEN) |
            (blueCurve.identity ? 0 : CURVE_BLUE));
}

- (void) applyCurves: (NSArray*) curves
{
	NSUInteger            curvesMask = [self pCurveApplyMask: curves];
    
    if(curvesMask != CURVE_NONE)
    {
        BCImageCurve*   rgbCurve = [curves objectAtIndex: 0];
        BCImageCurve*   redCurve = [curves objectAtIndex: 1];
        BCImageCurve*   greenCurve = [curves objectAtIndex: 2];
        BCImageCurve*   blueCurve = [curves objectAtIndex: 3];
        
        for(unsigned int i = 0; i <= 255; ++i)
        {
            switch(curvesMask)
            {
                case CURVE_COLORS:
                {
                    _reds[i] = [rgbCurve mapPixelValue: i];
                    _greens[i] = [rgbCurve mapPixelValue: i];
                    _blues[i] = [rgbCurve mapPixelValue: i];
                    break;
                }
                case CURVE_RED:
                {
                    _reds[i] = [redCurve mapPixelValue: i];
                    _greens[i] = i;
                    _blues[i] = i;
                    break;
                }
                case CURVE_GREEN:
                {
                    _reds[i] = i;
                    _greens[i] = [greenCurve mapPixelValue: i];
                    _blues[i] = i;
                    break;
                }
                case CURVE_BLUE:
                {
                    _reds[i] = i;
                    _greens[i] = i;
                    _blues[i] = [blueCurve mapPixelValue: i];
                    break;
                }
                case (CURVE_RED | CURVE_GREEN | CURVE_BLUE):
                {
                    _reds[i] = [redCurve mapPixelValue: i];
                    _greens[i] = [greenCurve mapPixelValue: i];
                    _blues[i] = [blueCurve mapPixelValue: i];
                    break;
                }
                default:
                {
                    _reds[i] = [rgbCurve mapPixelValue: [redCurve mapPixelValue: i]];
                    _greens[i] = [rgbCurve mapPixelValue: [greenCurve mapPixelValue: i]];
                    _blues[i] = [rgbCurve mapPixelValue: [blueCurve mapPixelValue: i]];
                    break;
                }
            }
        }
        
        uint32_t*  currentPixel = _rawBytes;
        uint32_t*  lastPixel = (uint32_t*)((unsigned char*)_rawBytes + _bufferSize);
        
        while(currentPixel < lastPixel)
        {
            SET_RED_COMPONENT_RGBA(currentPixel, _reds[RED_COMPONENT_RGBA(currentPixel)]);
            SET_GREEN_COMPONENT_RGBA(currentPixel, _greens[GREEN_COMPONENT_RGBA(currentPixel)]);
            SET_BLUE_COMPONENT_RGBA(currentPixel, _blues[BLUE_COMPONENT_RGBA(currentPixel)]);
            ++currentPixel;
        }
    }
}

- (void) applyLevels: (BCImageLevels*) levels
{
    uint32_t*  currentPixel = _rawBytes;
    uint32_t*  lastPixel = (uint32_t*)((unsigned char*)_rawBytes + _bufferSize);
    uint32_t* imageLevels = levels.imageLevels;
    
    while(currentPixel < lastPixel)
    {
        SET_RED_COMPONENT_RGBA(currentPixel, imageLevels[RED_COMPONENT_RGBA(currentPixel)]);
        SET_GREEN_COMPONENT_RGBA(currentPixel, imageLevels[GREEN_COMPONENT_RGBA(currentPixel)]);
        SET_BLUE_COMPONENT_RGBA(currentPixel, imageLevels[BLUE_COMPONENT_RGBA(currentPixel)]);
        ++currentPixel;
    }
}


@end
