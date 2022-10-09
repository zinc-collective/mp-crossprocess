//
//  BCImageLevels.m
//  CrossProcess
//
//  Copyright 2019 Zinc Collective LLC. All rights reserved.
//

#import "BCImageLevels.h"

@interface BCImageLevels()
- (void) pGenerateLevels;
@end

@implementation BCImageLevels

@synthesize shadowLevel = _shadowLevel;
@synthesize hilightLevel = _hilightLevel;
@synthesize imageLevels = _imageLevels;

- (id) initWithShadowLevel: (NSUInteger) shadowLevel hilightLevel: (NSUInteger) hilightLevel
{
    if(self = [super init])
    {
        if(hilightLevel > 255)
        {
            hilightLevel = 255;
        }

        _shadowLevel = shadowLevel;
        _hilightLevel = hilightLevel;
        _imageLevels = (uint32_t*)malloc(sizeof(uint32_t) * 256);
        [self pGenerateLevels];
    }

    return self;
}

- (void) dealloc
{
    free(_imageLevels);
}

- (NSUInteger) interpolate: (NSUInteger) level
{
    return _imageLevels[level];
}

- (void) pGenerateLevels
{
    if(_imageLevels)
    {
        NSUInteger   min_a = 0;
        NSUInteger   max_a = 255;
        NSUInteger   min_b = self.shadowLevel;
        NSUInteger   max_b = self.hilightLevel;
        NSUInteger   a_span = max_a - min_a;
        NSUInteger   b_span = max_b - min_b;

        double      scaleFactor = (double) b_span / (double) a_span;

        for(NSUInteger i = 0; i < 256; ++i)
        {
            _imageLevels[i] = min_b + (i - min_a) * scaleFactor;
        }
    }
}

@end
