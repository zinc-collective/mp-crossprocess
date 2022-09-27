//
//  BCGrowlView.h
//  CrossProcess
//
//  Copyright 2019 Zinc Collective LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCGrowlView : UIView

@property(nonatomic, assign) NSTimeInterval     notificationDuration;
@property(nonatomic, strong) UILabel*           textLabel;

- (void) beginNotificationInViewController: (UIViewController*) vc
                          withNotification: (NSString*) notification;

@end
