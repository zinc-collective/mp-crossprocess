//
//  BCImageLevels.h
//  CrossProcess
//
//  Copyright 2010-2013 Banana Camera Company. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCImageLevels : NSObject
{
    @private
    NSUInteger*      _imageLevels;
}

@property(nonatomic, readonly) NSUInteger shadowLevel;
@property(nonatomic, readonly) NSUInteger hilightLevel;
@property(nonatomic, readonly) NSUInteger* imageLevels;

- (id) initWithShadowLevel: (NSUInteger) shadowLevel hilightLevel: (NSUInteger) hilightLevel;
- (NSUInteger) interpolate: (NSUInteger) level;

@end
