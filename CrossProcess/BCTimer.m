//
//  BCTimer.m
//  CrossProcess
//
//  Copyright 2019 Zinc Collective LLC. All rights reserved.
//

#import "BCTimer.h"
#import <mach/mach_time.h>

@interface BCTimer()
@property(nonatomic, strong, readwrite) NSDate* start;
@property(nonatomic, strong, readwrite) NSDate* end;
@end

@implementation BCTimer

@synthesize start = _start;
@synthesize end = _end;

+ (BCTimer*) timer
{
    BCTimer*    result = [[BCTimer alloc] init];
    [result startTimer];
    return result;
}

- (void) startTimer
{
    self.start = [NSDate date];
}

- (void) stopTimer
{
    self.end = [NSDate date];
}

- (CGFloat) timeElapsedInSeconds
{
    return [self.end timeIntervalSinceDate: self.start];
}

- (CGFloat) timeElapsedInMilliseconds
{
    return [self timeElapsedInSeconds] * 1000.0f;
}

- (CGFloat) timeElapsedInMinutes
{
    return [self timeElapsedInSeconds] / 60.0f;
}

- (void) logElapsedInSeconds: (NSString*) prefix
{
    NSLog(@"###---> %@: %lf seconds", prefix ? prefix : @"Total time was", [self timeElapsedInSeconds]);
}

- (void) logElapsedInMilliseconds: (NSString*) prefix
{
    NSLog(@"###---> %@: %lf milliseconds", prefix ? prefix : @"Total time was", [self timeElapsedInMilliseconds]);
}

- (void) logElapsedInMinutes: (NSString*) prefix
{
    NSLog(@"###---> %@: %lf minutes", prefix ? prefix : @"Total time was", [self timeElapsedInMinutes]);
}

@end
