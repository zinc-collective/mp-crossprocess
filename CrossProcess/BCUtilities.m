//
//  BCUtilities.mm
//  Baboon
//
//  Copyright Banana Camera Company 2010 - 2012. All rights reserved.
//

#import "BCUtilities.h"

CGRect CenterRectOverRect(CGRect a, CGRect b)
{
	CGPoint	centerB;
	CGPoint centerA;
	
	centerB = CGPointMake(CGRectGetMidX(b), CGRectGetMidY(b));
	centerA = CGPointMake(CGRectGetMidX(a), CGRectGetMidY(a));
	
	return CGRectOffset(a, centerB.x - centerA.x, centerB.y - centerA.y);
}

CGSize FitSizeWithSize(CGSize src, CGSize dst)
{
    CGFloat scale = fminf(dst.width / src.width, dst.height / src.height);
    CGSize	result = CGSizeMake(RoundEven(src.width * scale), RoundEven(src.height * scale));
    return result;
}

/*
CGSize FitSizeWithSize(CGSize sizeToFit, CGSize sizeToFitInto)
{
	CGFloat	srcAspect = sizeToFit.width / sizeToFit.height;
	CGFloat	dstAspect = sizeToFitInto.width / sizeToFitInto.height;
	
	CGSize	result;
	
	if(fabs(srcAspect - dstAspect) < 0.01)
	{
		// Aspects are close enough
		result = sizeToFitInto;
	}
	else 
	{
		CGFloat scale = (sizeToFitInto.width / sizeToFit.width);
		if(sizeToFit.height * scale > sizeToFitInto.height)
		{
			scale = sizeToFitInto.height / sizeToFit.height;
		}

		result = CGSizeMake(RoundEven(sizeToFit.width * scale), RoundEven(sizeToFit.height * scale));
		
		while(result.width < sizeToFitInto.width || result.height < sizeToFitInto.height)
		{
			scale += 0.01;
			result = CGSizeMake(RoundEven(sizeToFit.width * scale), RoundEven(sizeToFit.height * scale));
		}
	}

	return result;
}
*/

/*
CGSize FitSizeWithSize(CGSize sizeToFit, CGSize sizeToFitInto)
{
	CGSize	result = sizeToFit;
	
	if(sizeToFit.width < sizeToFit.height)
	{
		CGFloat		scale = sizeToFitInto.width / sizeToFit.width;
		result.width = sizeToFit.width * scale;
		result.height = sizeToFit.height * scale;
		
		while(result.height < sizeToFitInto.height)
		{
			scale += 0.1;
			result.width = sizeToFit.width * scale;
			result.height = sizeToFit.height * scale;
		}
	}
	else
	{
		CGFloat		scale = sizeToFitInto.height / sizeToFit.height;
		result.width = sizeToFit.width * scale;
		result.height = sizeToFit.height * scale;
		
		while(result.width < sizeToFitInto.width)
		{
			scale += 0.1;
			result.width = sizeToFit.width * scale;
			result.height = sizeToFit.height * scale;
		}
	}
	
	result.width = RoundEven(result.width);
	result.height = RoundEven(result.height);
	
	return result;
}
*/

CGFloat RoundEven(CGFloat a)
{
	long int	result = lrintf(a);
	
	if(result % 2 )
		result += 1;
	
	return((CGFloat)result);
}

CGColorRef CreateDeviceGrayColor(CGFloat w, CGFloat a)
{
    CGColorSpaceRef gray = CGColorSpaceCreateDeviceGray();
    CGFloat comps[] = {w, a};
    CGColorRef color = CGColorCreate(gray, comps);
    CGColorSpaceRelease(gray);
    return color;
}

CGColorRef CreateDeviceRGBColor(CGFloat r, CGFloat g, CGFloat b, CGFloat a)
{
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGFloat comps[] = {r, g, b, a};
    CGColorRef color = CGColorCreate(rgb, comps);
    CGColorSpaceRelease(rgb);
    return color;
}

CGAffineTransform AdjustedTransform(UIImageOrientation orientation, CGFloat width, CGFloat height)
{
    CGAffineTransform   result = CGAffineTransformIdentity;
    
    if(orientation != UIImageOrientationUp && width > 0.0 && height > 0.0)
    {
        switch(orientation)
        {
            case UIImageOrientationDown:         
            {
                result = CGAffineTransformMake(-1, 0, 0, -1, width, height); 
                break;
            }
            case UIImageOrientationLeft:
            {
                result = CGAffineTransformMake(0, height/width, -width/height, 0, width, 0);
                break;
            }
            case UIImageOrientationRight:        
            {
                result = CGAffineTransformMake(0, -height/width, width/height, 0, 0, height); 
                break;
            }
            case UIImageOrientationUpMirrored:
            {
                result = CGAffineTransformMake(-1, 0, 0, 1, width, 0); 
                break;
            }
            case UIImageOrientationDownMirrored:
            {
                result = CGAffineTransformMake( 1, 0, 0, -1, 0, height); 
                break;
            }
            case UIImageOrientationLeftMirrored:  
            {
                result = CGAffineTransformMake( 0, -height/width, -width/height, 0, width, height); 
                break;
            }
            case UIImageOrientationRightMirrored: 
            {
                result = CGAffineTransformMake( 0, height/width, width/height, 0, 0, 0); 
                break;
            }
            default:                              
            {
                result = CGAffineTransformIdentity;                        
                break;
            }
        }
    }
    
    return result;
}

