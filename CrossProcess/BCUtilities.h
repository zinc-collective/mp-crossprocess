//
//  BCUtilities.h
//  Baboon
//
//  Copyright 2019 Zinc Collective LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

// Geometry functions

CGRect CenterRectOverRect(CGRect a, CGRect b);
CGSize FitSizeWithSize(CGSize rectToFit, CGSize rectToFitInto);
CGFloat RoundEven(CGFloat a);

// Color functions

CGColorRef CreateDeviceGrayColor(CGFloat w, CGFloat a);
CGColorRef CreateDeviceRGBColor(CGFloat r, CGFloat g, CGFloat b, CGFloat a);

CGAffineTransform AdjustedTransform(UIImageOrientation orientation, CGFloat width, CGFloat height);

// Pulled from http://mobile.tutsplus.com/tutorials/iphone/working-with-the-iphone-5-display/

#define IS_IPHONE ( [[[UIDevice currentDevice] model] isEqualToString:@"iPhone"] )
#define IS_IPOD   ( [[[UIDevice currentDevice ] model] isEqualToString:@"iPod touch"] )
#define IS_HEIGHT_GTE_568 [[UIScreen mainScreen ] bounds].size.height >= 568.0f
#define IS_IPHONE_5 ( IS_IPHONE && IS_HEIGHT_GTE_568 )