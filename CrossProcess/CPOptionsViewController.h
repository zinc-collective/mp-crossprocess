//
//  CPOptionsViewController.h
//  CrossProcess
//
//  Copyright 2010-2013 Banana Camera Company. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPOptionsViewControllerDelegate;

@interface CPOptionsViewController : UIViewController< UITableViewDelegate, 
                                                       UITableViewDataSource,
                                                       UINavigationBarDelegate,
                                                       UIWebViewDelegate>

@property (assign, nonatomic) id<CPOptionsViewControllerDelegate>   delegate;
@property (strong, nonatomic) IBOutlet UITableView*                 tableView;
@property (strong, nonatomic) IBOutlet UINavigationBar*             navigationBar;

@property (strong, nonatomic) IBOutlet UITableViewCell*             redCell;
@property (strong, nonatomic) IBOutlet UITableViewCell*             blueCell;
@property (strong, nonatomic) IBOutlet UITableViewCell*             greenCell;
@property (strong, nonatomic) IBOutlet UITableViewCell*             extremeCell;
@property (strong, nonatomic) IBOutlet UITableViewCell*             basicCell;

@property (strong, nonatomic) IBOutlet UITableViewCell*             borderCell;
@property (strong, nonatomic) IBOutlet UITableViewCell*             saveOriginalCell;
@property (strong, nonatomic) IBOutlet UITableViewCell*             infoCell;
@property (strong, nonatomic) IBOutlet UITableViewCell*             communityCell;

@property (strong, nonatomic) IBOutlet UITableViewCell*             fullsizeImageCell;

@property (strong, nonatomic) IBOutlet UIView*                      footerView;

@property (strong, nonatomic) UIWebView*                            moreInfoWebView;
@property (strong, nonatomic) UIWebView*                            socialWebView;

- (IBAction) done: (id) sender;
- (IBAction) moreInfo : (id) sender;
- (IBAction) community : (id) sender;
- (IBAction) showManual:(id)sender;
- (IBAction) keepOriginal: (id) sender;
- (IBAction) useBorder: (id) sender;
- (IBAction) useRedCurve: (id) sender;
- (IBAction) useBlueCurve: (id) sender;
- (IBAction) useGreenCurve: (id) sender;
- (IBAction) useBasicCurve: (id) sender;
- (IBAction) useExtremeCurve: (id) sender;
- (IBAction) useFullSizeImage: (id) sender;
@end

@protocol CPOptionsViewControllerDelegate
- (void) optionsViewControllerDidFinish: (CPOptionsViewController*) controller;
@end
