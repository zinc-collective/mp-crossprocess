//
//  UIImageAdditions.h
//  CrossProcess
//
//  Copyright Banana Camera Company 2010 - 2012. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage(BananaCameraAdditions)

- (void) createScaledImage: (CGSize) size atURL: (NSURL*) destinationURL;

@end

@interface CPScaledImageCreator : NSOperation

@property(strong, nonatomic) NSURL*             appSupportURL;
@property(strong, nonatomic) NSDictionary*      imageAssets;
@property(strong, nonatomic) NSArray*           imageAssetsNames;

@end