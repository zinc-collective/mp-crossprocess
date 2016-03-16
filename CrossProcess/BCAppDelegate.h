//
//  BCAppDelegate.h
//  CrossProcess
//
//  Copyright 2012 Banana Camera Company. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSURL;

@protocol BCAppDelegate <NSObject>
@property (strong, nonatomic) NSURL*   appSupportURL;
@property (strong, nonatomic) NSURL*   youTubeHelpURL;

- (NSArray*) imageAssetsNames;
@end
