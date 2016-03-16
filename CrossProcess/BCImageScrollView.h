//
//  BCImageScrollView.h
//  CrossProcess
//
//  Copyright 2010-2011 Banana Camera Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCImageView.h"

@class BCImageView;
@class BCImage;

@interface BCImageScrollView : UIScrollView<UIScrollViewDelegate>

@property(strong, nonatomic, readwrite) NSMutableArray* imageList;
@property(strong, nonatomic, readonly) BCImageView* currentImage;
@property(strong, nonatomic, readonly) NSURL* currentImageURL;

- (NSUInteger) addImage: (CPPlaceholderType) type portraitOrientation: (BOOL) isPortrait;
- (BCImageView*) imageAtIndex: (NSUInteger) imageIndex;
- (NSURL*) imageURLAtIndex: (NSUInteger) imageIndex;

- (void) setImage: (BCImage*) image forIndex: (NSUInteger) index;
- (void) setImageURL: (NSURL*) image forIndex: (NSUInteger) index;

@end
