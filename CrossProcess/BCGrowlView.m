//
//  BCGrowlView.m
//  CrossProcess
//
//  Copyright 2010-2013 Banana Camera Company. All rights reserved.
//

#import "BCGrowlView.h"
#import "BCUtilities.h"
#import <QuartzCore/QuartzCore.h>

@implementation BCGrowlView

static const NSTimeInterval	kRevealAnimationDuration = 1.0;
static const NSTimeInterval	kDismissAnimationDuration = 1.5;

@synthesize notificationDuration = _notificationDuration;
@synthesize textLabel = _textLabel;

- (id) initWithFrame: (CGRect) frame 
{
    if(self = [super initWithFrame:frame])
	{
		self.notificationDuration = 2.5;
		
		// set up a rounded border
		CALayer*	layer = [self layer];
		
		// clear the view's background color so that our background
		// fits within the rounded border
		self.backgroundColor = [UIColor clearColor];
		layer.backgroundColor = [UIColor grayColor].CGColor;
		
		layer.borderWidth = 0.0f;
		layer.cornerRadius = 12.0f;
		
		self.textLabel = [[UILabel alloc] initWithFrame: self.layer.frame];
		self.textLabel.backgroundColor = [UIColor clearColor];
		self.textLabel.textColor = [UIColor whiteColor];
		self.textLabel.font = [UIFont systemFontOfSize: 18.0];
		self.textLabel.textAlignment = NSTextAlignmentCenter;
		
		[self addSubview: self.textLabel];
	}
	
	return self;
}

- (void) beginNotificationInViewController: (UIViewController*) vc 
                          withNotification: (NSString*) notification
{
	self.textLabel.text = notification;
	[self.textLabel sizeToFit];
	self.textLabel.frame = CenterRectOverRect(self.textLabel.frame, self.frame);
	[self.textLabel setNeedsDisplay];
	
	self.alpha = 0.0;
	self.frame = CenterRectOverRect(self.frame, vc.view.frame);
	[vc.view addSubview: self];
	
    [UIView animateWithDuration:kRevealAnimationDuration 
                     animations:^()
     {
         self.alpha = 0.8;
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration: kDismissAnimationDuration 
                               delay: self.notificationDuration 
                             options: 0 
                          animations:^()
          {
              self.alpha = 0.0;
          }
                          completion:^(BOOL finished)
          {
              [self removeFromSuperview];
          }];
     }];
}

@end
