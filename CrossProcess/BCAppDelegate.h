//
//  BCAppDelegate.h
//  CrossProcess
//
//  Copyright 2019 Zinc Collective LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSURL;

@protocol BCAppDelegate <NSObject>
@property (strong, nonatomic) NSURL*   appSupportURL;
@property (strong, nonatomic) NSURL*   youTubeHelpURL;

- (NSArray*) imageAssetsNames;
@end
