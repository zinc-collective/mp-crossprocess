//
//  BCImageLevels.h
//  CrossProcess
//
//  Copyright 2019 Zinc Collective LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCImageLevels : NSObject
{
    @private
    uint32_t* _imageLevels;
}

@property(nonatomic, readonly) NSUInteger shadowLevel;
@property(nonatomic, readonly) NSUInteger hilightLevel;
@property(nonatomic, readonly) uint32_t* imageLevels;

- (id) initWithShadowLevel: (NSUInteger) shadowLevel hilightLevel: (NSUInteger) hilightLevel;
- (NSUInteger) interpolate: (NSUInteger) level;

@end
