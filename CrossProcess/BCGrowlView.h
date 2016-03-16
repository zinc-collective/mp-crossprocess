//
//  BCGrowlView.h
//  CrossProcess
//
//  Copyright 2010-2013 Banana Camera Company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCGrowlView : UIView

@property(nonatomic, assign) NSTimeInterval     notificationDuration;
@property(nonatomic, strong) UILabel*           textLabel;

- (void) beginNotificationInViewController: (UIViewController*) vc 
                          withNotification: (NSString*) notification;

@end
