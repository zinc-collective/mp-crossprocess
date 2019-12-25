//
//  CPOptionsViewController.m
//  CrossProcess
//
//  Copyright 2019 Zinc Collective LLC. All rights reserved.
//

#import "CPOptionsViewController.h"
#import "BCMiscellaneous.h"
#import "BCAppDelegate.h"
#import "CPAppConstants.h"

static NSInteger    CPSwitchViewTag = 100;
static NSInteger    CPLabelViewTag = 101;

@interface CPOptionsViewController()
- (void) pUpdateControls;
- (void) pAdjustLabelStrings;
@end

@implementation CPOptionsViewController

@synthesize delegate = _delegate;
@synthesize tableView = _tableView;

@synthesize redCell = _redCell;
@synthesize blueCell = _blueCell;
@synthesize greenCell = _greenCell;
@synthesize extremeCell = _extremeCell;
@synthesize basicCell = _basicCell;
@synthesize borderCell = _borderCell;
@synthesize saveOriginalCell = _saveOriginalCell;
@synthesize infoCell = _infoCell;
@synthesize communityCell = _communityCell;
@synthesize fullsizeImageCell = _fullsizeImageCell;
@synthesize moreInfoWebView = _moreInfoWebView;
@synthesize socialWebView = _socialWebView;
@synthesize navigationBar = _navigationBar;
@synthesize footerView = _footerView;

- (id) initWithNibName: (NSString*) nibNameOrNil bundle: (NSBundle*) nibBundleOrNil
{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
    }
    return self;
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self pUpdateControls];
    [self pAdjustLabelStrings];
}

- (void) viewDidUnload
{
    self.moreInfoWebView = nil;
    self.socialWebView = nil;
    self.tableView = nil;
    self.redCell = nil;
    self.blueCell = nil;
    self.greenCell = nil;
    self.extremeCell = nil;
    self.basicCell = nil;
    self.borderCell = nil;
    self.saveOriginalCell = nil;
    self.infoCell = nil;
    self.communityCell = nil;

    [super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (IBAction) done: (id) sender
{
    [self.delegate optionsViewControllerDidFinish: self];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat) tableView: (UITableView*) tableView heightForHeaderInSection: (NSInteger) section
{
	CGFloat	height = 26.0;

	if(section == 0)
	{
		height = 30.0;
	}

	return height;
}

- (UIView*) tableView: (UITableView*) tableView viewForHeaderInSection: (NSInteger) section
{
  	UIView* customView = [[UIView alloc] initWithFrame: CGRectMake(0, 0.0, 300.0, 26.0)];
	UILabel* headerLabel = [[UILabel alloc] initWithFrame: CGRectZero];

	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor darkGrayColor];
	headerLabel.shadowColor = [UIColor whiteColor];
	headerLabel.shadowOffset = CGSizeMake(0, 1);
	headerLabel.font = [UIFont boldSystemFontOfSize: 16];
	headerLabel.textAlignment = NSTextAlignmentLeft;

	if(section == 0)
	{
        NSString*   processHeaderText = NSLocalizedString(@"processHeaderText", @"Options - Process Header label");
		headerLabel.text = processHeaderText;
		headerLabel.frame = CGRectMake(20, 0, 300, 26.0);
	}
	else if(section == 1)
	{
        NSString*   extrasHeaderText = NSLocalizedString(@"extrasHeaderText", @"Options - Extra Header label");
		headerLabel.text = extrasHeaderText;
		headerLabel.frame = CGRectMake(20, -4, 300, 26.0);
	}

  	[customView addSubview:headerLabel];
	return customView;
}

- (CGFloat) tableView: (UITableView*) tableView heightForFooterInSection: (NSInteger) section
{
	return section == 0 ? 0.0 : self.footerView.frame.size.height;
}

- (UIView*) tableView: (UITableView*) tableView viewForFooterInSection: (NSInteger) section
{
	return section == 0 ? nil : self.footerView;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 2;
}

- (NSInteger) tableView: (UITableView*) table numberOfRowsInSection: (NSInteger) section
{
    NSInteger   numRows = 0;

    if(section == 0)
    {
        numRows = 5;
    }
    else if(section == 1)
    {
        numRows = 5;
    }

	return numRows;
}

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
    if(indexPath.section == 1 && indexPath.row == 3)
	{
		[[tableView cellForRowAtIndexPath: indexPath] setSelected: NO animated: NO];
		[self moreInfo: nil];
	}
    else if(indexPath.section == 1 && indexPath.row == 4)
	{
		[[tableView cellForRowAtIndexPath: indexPath] setSelected: NO animated: NO];
		[self community: nil];
	}
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
	UITableViewCell*	cell = nil;

    switch(indexPath.section)
    {
        case 0:
        {
            if(indexPath.row == 0)
            {
                cell = self.redCell;
            }
            else if(indexPath.row == 1)
            {
                cell = self.greenCell;
            }
            else if(indexPath.row == 2)
            {
                cell = self.blueCell;
            }
            else if(indexPath.row == 3)
            {
                cell = self.basicCell;
            }
            else if(indexPath.row == 4)
            {
                cell = self.extremeCell;
            }
            break;
        }
        case 1:
        {
            if(indexPath.row == 0)
            {
                cell = self.borderCell;
            }
            else if(indexPath.row == 1)
            {
                cell = self.saveOriginalCell;
            }
            else if(indexPath.row == 2)
            {
                cell = self.fullsizeImageCell;
            }
            else if(indexPath.row == 3)
            {
                cell = self.infoCell;
            }
			else if(indexPath.row == 4)
			{
                cell = self.communityCell;
			}

            break;
        }
        default:
        {
            break;
        }
    }

	return cell;
}

#pragma mark - Actions

- (IBAction) moreInfo: (id) sender
{
	if(self.moreInfoWebView == nil)
	{
		self.moreInfoWebView = [[UIWebView alloc] initWithFrame: CGRectZero];
		self.moreInfoWebView.scalesPageToFit = YES;
		self.moreInfoWebView.delegate = self;

		// Webview frame is the full size of the screen - the height of the navigation bar.

		CGRect			webViewFrame = self.tableView.frame;
		webViewFrame.origin.x += webViewFrame.size.width;
		self.moreInfoWebView.frame = webViewFrame;
        self.moreInfoWebView.backgroundColor = [UIColor clearColor];
	}

	// Insert the webview as a sibling of the options view (below it - to ensure that it's also below the navigation bar)

	[self.view.superview insertSubview: self.moreInfoWebView aboveSubview: self.view];

	// Calculate the final (animatable) frames

	CGRect			newWebViewFrame = self.moreInfoWebView.frame;
	newWebViewFrame.origin.x -= CGRectGetWidth(newWebViewFrame);

    [UIView animateWithDuration: 0.4 animations:^
     {
         self.moreInfoWebView.frame = newWebViewFrame;
     }];

	[self.moreInfoWebView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: CPBananaCameraMoreAppsURL]]];

    NSString*           moreAppsTitle = NSLocalizedString(@"moreAppsTitle", @"More Apps options title");
	UINavigationItem*	navItem = [[UINavigationItem alloc] initWithTitle: moreAppsTitle];
	[self.navigationBar pushNavigationItem: navItem animated: YES];
}

- (IBAction) showManual: (id) sender
{
    id<BCAppDelegate>   appDelegate = BCCastAsProtocol(BCAppDelegate, [[UIApplication sharedApplication] delegate]);
    NSURL*              manualURL = [appDelegate youTubeHelpURL];

    if(manualURL)
    {
        [[UIApplication sharedApplication] openURL: manualURL];
    }
}

- (IBAction) community: (id) sender
{
	if(!self.socialWebView)
	{
		self.socialWebView = [[UIWebView alloc] initWithFrame: CGRectZero];
		self.socialWebView.scalesPageToFit = YES;
		self.socialWebView.delegate = self;

		// Webview frame is the full size of the screen - the height of the navigation bar.

		CGRect			webViewFrame = self.tableView.frame;
		webViewFrame.origin.x += webViewFrame.size.width;
		self.socialWebView.frame = webViewFrame;
        self.socialWebView.backgroundColor = [UIColor clearColor];
	}

	// Insert the webview as a sibling of the options view (below it - to ensure that it's also below the navigation bar)

	[self.view.superview insertSubview: self.socialWebView aboveSubview: self.view];

	// Calculate the final (animatable) frames

	CGRect			newWebViewFrame = self.socialWebView.frame;
	newWebViewFrame.origin.x -= CGRectGetWidth(newWebViewFrame);

	// Animate them into place.

    [UIView animateWithDuration: 0.4 animations: ^
     {
         self.socialWebView.frame = newWebViewFrame;
     }];

	[_socialWebView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: CPBananaCameraSocialURL]]];

    NSString*           communityTitle = NSLocalizedString(@"communityTitle", @"Community options title");
	UINavigationItem*	navItem = [[UINavigationItem alloc] initWithTitle: communityTitle];
	[self.navigationBar pushNavigationItem: navItem animated: YES];
}

- (IBAction) keepOriginal: (id) sender
{
    UISwitch* uiSwitch = BCCastAsClass(UISwitch, sender);

    if(uiSwitch)
    {
        [[NSUserDefaults standardUserDefaults] setBool: uiSwitch.isOn forKey: CPKeepOriginalOptionKey];
    }
}

- (IBAction) useBorder: (id) sender
{
    UISwitch* uiSwitch = BCCastAsClass(UISwitch, sender);

    if(uiSwitch)
    {
        [[NSUserDefaults standardUserDefaults] setBool: uiSwitch.isOn forKey: CPWantsBorderOptionKey];
    }
}

- (IBAction) useRedCurve:(id)sender
{
    UISwitch* uiSwitch = BCCastAsClass(UISwitch, sender);

    if(uiSwitch)
    {
        [[NSUserDefaults standardUserDefaults] setBool: uiSwitch.isOn forKey: CPRedProcessingOptionKey];
    }
}

- (IBAction) useBlueCurve:(id)sender
{
    UISwitch* uiSwitch = BCCastAsClass(UISwitch, sender);

    if(uiSwitch)
    {
        [[NSUserDefaults standardUserDefaults] setBool: uiSwitch.isOn forKey: CPBlueProcessingOptionKey];
    }
}

- (IBAction) useGreenCurve:(id)sender
{
    UISwitch* uiSwitch = BCCastAsClass(UISwitch, sender);

    if(uiSwitch)
    {
        [[NSUserDefaults standardUserDefaults] setBool: uiSwitch.isOn forKey: CPGreenProcessingOptionKey];
    }
}

- (IBAction) useBasicCurve:(id)sender
{
    UISwitch* uiSwitch = BCCastAsClass(UISwitch, sender);

    if(uiSwitch)
    {
        [[NSUserDefaults standardUserDefaults] setBool: uiSwitch.isOn forKey: CPBasicProcessingOptionKey];
    }
}

- (IBAction) useExtremeCurve:(id)sender
{
    UISwitch* uiSwitch = BCCastAsClass(UISwitch, sender);

    if(uiSwitch)
    {
        [[NSUserDefaults standardUserDefaults] setBool: uiSwitch.isOn forKey: CPExtremeProcessingOptionKey];
    }
}

- (IBAction) useFullSizeImage: (id) sender
{
    UISwitch* uiSwitch = BCCastAsClass(UISwitch, sender);

    if(uiSwitch)
    {
        [[NSUserDefaults standardUserDefaults] setBool: uiSwitch.isOn forKey: CPFullSizeImageOptionKey];
    }
}

- (void) pUpdateControls
{
    NSUserDefaults*     defaults = [NSUserDefaults standardUserDefaults];

    BCCastAsClass(UISwitch, [self.fullsizeImageCell viewWithTag: CPSwitchViewTag]).on = [defaults boolForKey: CPFullSizeImageOptionKey];
    BCCastAsClass(UISwitch, [self.saveOriginalCell viewWithTag: CPSwitchViewTag]).on = [defaults boolForKey: CPKeepOriginalOptionKey];
    BCCastAsClass(UISwitch, [self.borderCell viewWithTag: CPSwitchViewTag]).on = [defaults boolForKey: CPWantsBorderOptionKey];

    BCCastAsClass(UISwitch, [self.redCell viewWithTag: CPSwitchViewTag]).on = [defaults boolForKey: CPRedProcessingOptionKey];
    BCCastAsClass(UISwitch, [self.blueCell viewWithTag: CPSwitchViewTag]).on = [defaults boolForKey: CPBlueProcessingOptionKey];
    BCCastAsClass(UISwitch, [self.greenCell viewWithTag: CPSwitchViewTag]).on = [defaults boolForKey: CPGreenProcessingOptionKey];
    BCCastAsClass(UISwitch, [self.basicCell viewWithTag: CPSwitchViewTag]).on = [defaults boolForKey: CPBasicProcessingOptionKey];
    BCCastAsClass(UISwitch, [self.extremeCell viewWithTag: CPSwitchViewTag]).on = [defaults boolForKey: CPExtremeProcessingOptionKey];
}

- (void) pAdjustLabelStrings
{
    BCCastAsClass(UILabel, [self.saveOriginalCell viewWithTag: CPLabelViewTag]).text = NSLocalizedString(@"saveOriginalLabel", @"Save Original Label");
    BCCastAsClass(UILabel, [self.borderCell viewWithTag: CPLabelViewTag]).text = NSLocalizedString(@"borderLabel", "Border Label");
    BCCastAsClass(UILabel, [self.fullsizeImageCell viewWithTag: CPLabelViewTag]).text = NSLocalizedString(@"fullSizeImagesLabel", "Full Size Images Label");

    BCCastAsClass(UILabel, [self.communityCell viewWithTag: CPLabelViewTag]).text = NSLocalizedString(@"communityLabel", "Community Label");
    BCCastAsClass(UILabel, [self.infoCell viewWithTag: CPLabelViewTag]).text = NSLocalizedString(@"moreAppsLabel", "More Apps Label");

    BCCastAsClass(UILabel, [self.redCell viewWithTag: CPLabelViewTag]).text = NSLocalizedString(@"redLabel", "Red Label");
    BCCastAsClass(UILabel, [self.greenCell viewWithTag: CPLabelViewTag]).text = NSLocalizedString(@"greenLabel", "Green Label");
    BCCastAsClass(UILabel, [self.blueCell viewWithTag: CPLabelViewTag]).text = NSLocalizedString(@"blueLabel", "Blue Label");
    BCCastAsClass(UILabel, [self.basicCell viewWithTag: CPLabelViewTag]).text = NSLocalizedString(@"basicLabel", "Basic Label");
    BCCastAsClass(UILabel, [self.extremeCell viewWithTag: CPLabelViewTag]).text = NSLocalizedString(@"extremeLabel", "Extreme Label");
}

#pragma mark -
#pragma mark UINavigationBarDelegate

- (BOOL) navigationBar: (UINavigationBar*) navigationBar shouldPopItem: (UINavigationItem*) item
{
    NSString*           communityTitle = NSLocalizedString(@"communityTitle", @"Community options title");
    NSString*           moreAppsTitle = NSLocalizedString(@"moreAppsTitle", @"More Apps options title");

	if([item.title isEqualToString: moreAppsTitle])
	{
		// Calculate the final (animatable) frames

		CGRect			newWebViewFrame = self.moreInfoWebView.frame;
		newWebViewFrame.origin.x += CGRectGetWidth(newWebViewFrame);

		// Animate them into place.

        [UIView animateWithDuration: 0.4 animations:^
         {
             self.moreInfoWebView.frame = newWebViewFrame;
         }
                         completion:^(BOOL finished)
         {
             [self.moreInfoWebView removeFromSuperview];
         }];
	}
	else if([item.title isEqualToString: communityTitle])
	{
		// Calculate the final (animatable) frames

		CGRect			newWebViewFrame = self.socialWebView.frame;
		newWebViewFrame.origin.x += CGRectGetWidth(newWebViewFrame);

		// Animate them into place.

        [UIView animateWithDuration: 0.4 animations:^
         {
             self.socialWebView.frame = newWebViewFrame;
         }
                         completion:^(BOOL finished)
         {
             [self.socialWebView removeFromSuperview];
         }];
	}

	return YES;
}

-(BOOL)prefersStatusBarHidden{
    return NO;
}

@end
