//
//  BCImageScrollView.m
//  CrossProcess
//
//  Copyright 2010-2011 Banana Camera Company. All rights reserved.
//

#import "BCImageScrollView.h"
#import "BCImageView.h"
#import "BCImage.h"
#import "CPMiscellaneous.h"
#import <QuartzCore/QuartzCore.h>

@interface BCImageScrollView()
- (void) pLayoutImageViews;
@end

@implementation BCImageScrollView

@synthesize imageList = _imageList;
@dynamic currentImage;
@dynamic currentImageURL;

- (id) initWithCoder: (NSCoder*) decoder
{
    if(self = [super initWithCoder: decoder])
    {
        self.directionalLockEnabled = YES;
        self.pagingEnabled = YES;
        self.clipsToBounds = YES;
        self.scrollEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;   
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        //self.delegate = self;
        
        _imageList = [[NSMutableArray alloc] initWithCapacity: 10];
    }
    
    return self;
}

- (void) setImageURL: (NSURL*) imageURL forIndex: (NSUInteger) index
{
    assert(index < _imageList.count);
    [_imageList replaceObjectAtIndex: index withObject: imageURL];
}

- (void) setImage: (BCImage*) image forIndex: (NSUInteger) index
{
    assert(index < self.subviews.count);
    assert(image);
    
    BCImageView*    view = [self.subviews objectAtIndex: index];
    if(view)
    {
        [view setImage: image];
    }
}

- (NSUInteger) addImage: (CPPlaceholderType) type portraitOrientation: (BOOL) isPortrait;
{
    BCImageView*    view = [[BCImageView alloc] initWithPlaceholder: type portraitOrientation: isPortrait];
    view.frame = CGRectOffset(BCViewFrame, -BCViewFrame.size.width, 0);
    
    // Always insert at beginning of list
    [self insertSubview: view atIndex: 0];
    
    [UIView animateWithDuration: 2.0 
                     animations:^
     {
         [self pLayoutImageViews];
         self.contentOffset = CGPointMake(0, 0);
     }
                     completion:^(BOOL finished)
     {
     }];

    [_imageList insertObject: [NSNull null] atIndex: 0];
    return 0;
}

- (BCImageView*) imageAtIndex: (NSUInteger) imageIndex
{
    assert(imageIndex < self.subviews.count);
    return [self.subviews objectAtIndex: imageIndex];
}

- (NSURL*) imageURLAtIndex: (NSUInteger) imageIndex
{
    assert(imageIndex < _imageList.count);
    return [_imageList objectAtIndex: imageIndex];
}

- (BCImageView*) currentImage
{
    BCImageView*     view = nil;
    CGPoint          contentOffset = self.contentOffset;
    NSUInteger       index = contentOffset.x / BCViewFrame.size.width;
    
    if(index < self.subviews.count)
    {
        view = [self.subviews objectAtIndex: index];
    }
    
    return view;    
}

- (NSURL*) currentImageURL
{
    NSURL*           url = nil;
    CGPoint          contentOffset = self.contentOffset;
    NSUInteger       index = contentOffset.x / BCViewFrame.size.width;
    
    if(index < _imageList.count)
    {
        url = [_imageList objectAtIndex: index];
    }
    
    return url;    
}

- (void) scrollViewDidEndDragging: (UIScrollView*) scrollView willDecelerate: (BOOL) decelerate
{
    
}

- (void) scrollViewDidEndDecelerating: (UIScrollView*) scrollView
{
    
}

- (void) scrollViewDidScroll: (UIScrollView*) scrollView
{
    // Make sure offsets 
    
    CGPoint         contentOffset = self.contentOffset;
    BCImageView*    closestView = nil;
    CGFloat         lastDistance = 0.0f;
    
    for(BCImageView* subview in self.subviews)
    {
        CGRect      viewFrame = subview.frame;
        CGFloat     distance = fabs(contentOffset.x - viewFrame.origin.x);
        
        if(!closestView || distance < lastDistance)
        {
            closestView = subview;
            lastDistance = distance;
        }
    }
    
    if(closestView)
    {
        contentOffset.x = closestView.frame.origin.x;
        self.contentOffset = contentOffset;
    }
}

- (void) pLayoutImageViews
{
    CGFloat     curXPosition = 0.0f;
    CGFloat     gutterWidth = 8.0f;
    CGFloat     contentWidth = 0.0f;
    
    for(BCImageView* subview in self.subviews)
    {
        CGRect  viewFrame = subview.frame;
        viewFrame.origin = CGPointMake(curXPosition, 0.0f);
        subview.frame = viewFrame;
        
        contentWidth += viewFrame.size.width + gutterWidth;
        curXPosition += viewFrame.size.width + gutterWidth;
    }
    
    if(contentWidth == 0.0f)
    {
        contentWidth = BCViewFrame.size.width;
    }
    else
    {
        contentWidth -= gutterWidth;
    }
    
    self.contentSize = CGSizeMake(contentWidth, BCViewFrame.size.height);
}

@end
