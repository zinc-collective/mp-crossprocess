//
//  BCTimer.h
//  CrossProcess
//
//  Copyright Banana Camera Company 2010 - 2012. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCTimer : NSObject 

@property(nonatomic, strong, readonly) NSDate* start;
@property(nonatomic, strong, readonly) NSDate* end;

+ (BCTimer*) timer;

- (void) startTimer;
- (void) stopTimer;
- (CGFloat) timeElapsedInSeconds;
- (CGFloat) timeElapsedInMilliseconds;
- (CGFloat) timeElapsedInMinutes;

- (void) logElapsedInSeconds: (NSString*) prefix;
- (void) logElapsedInMilliseconds: (NSString*) prefix;
- (void) logElapsedInMinutes: (NSString*) prefix;

@end
