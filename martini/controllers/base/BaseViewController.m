//
//  BaseViewController.m
//  Kinopoisk
//
//  Created by zlata samarskaya on 10.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "BaseViewController.h"
#import "SigninViewController.h"
#import "EditProfileViewController.h"

#import "MAppDelegate.h"
#import "MNetworkManager.h"
#import "MLocationManager.h"
#import "MUser.h"

#define kIndicatorViewTag 0x7000

@interface BaseViewController (PrivateMethods)
- (void)setNavbar;
@end


@implementation BaseViewController

@synthesize activityLabel;
@synthesize viewTitleLabel;

- (void)dealloc {
    [activityLabel release];
    [viewTitleLabel release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(signupFinished:) 
                                                 name:nSignupFinished 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signinFinished:) name:nSigninFinished object:nil];
    [self setNavbar];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nSigninFinished object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nSignupFinished object:nil];
   
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
 //   [self.navigationController setNavigationBarHidden:YES];
    //shown = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestFailed:) name:nRequestFailed object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nRequestFailed object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait) || 
        (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Notifications

- (void)loadData {
    
}

- (void)editProfile {
    MAppDelegate *delegate = appDelegate;
    UITabBarController *controller = delegate.tabbarController;
    UINavigationController *top = (UINavigationController*)controller.selectedViewController;
    if ([self.navigationController isEqual:top]) {
        EditProfileViewController *editProfileController = [[[EditProfileViewController alloc] init] autorelease];
        [self.navigationController pushViewController:editProfileController animated:YES];
    }
}

- (void)signupFinished:(NSNotification*)notification {
    if ([self handleError:notification]) {
        return;
    }
    [self performSelector:@selector(editProfile) withObject:nil afterDelay:0.7];
}

- (void)signinFinished:(NSNotification*)notification {
    if ([MCurrentUser sharedInstance].sid == nil) {
        return;
    }
    
    [self loadData];
}

- (void)requestFailed:(NSNotification*)notification {
    [self performSelector:@selector(hideActivityIndicator)];
    NSError *error = [[notification userInfo] valueForKey:@"error"];
    if (error != nil && !shown) {
        shown = YES;
        [self showAlertWithTitle:@"Не удалось загрузить данные"
                      andMessage:@"Проверьте интернет-соединение"];
    } 
}

- (BOOL)handleError:(NSNotification*)notification {
    [self performSelector:@selector(hideActivityIndicator)];
    NSError *error = [[notification userInfo] valueForKey:@"error"];
    if (error != nil) {
        [self showAlertWithTitle:@""
                      andMessage:[error localizedDescription]];
        return YES;
    } 
    return NO;
}

#pragma mark - Common Methods 

- (void)autorize {
        if ([[MCurrentUser sharedInstance] authorizedLocal]) {
            [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];
            [[MNetworkManager sharedInstance] signIn:[MCurrentUser sharedInstance].user.login 
                                            password:[MCurrentUser sharedInstance].password];
            return;
            
        }
        if ([[MCurrentUser sharedInstance] authorizedNetwork]) {
            [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            NSString *network = [def valueForKey:@"network"];
            NSString *userId = [def valueForKey:@"userId"];
            [[MNetworkManager sharedInstance] signInWithNetwork:[[MNetworkManager sharedInstance] idForNetwork:network] 
                                                         userId:userId];
            return;
        }
    
    MAppDelegate *delegate = appDelegate;
    SigninViewController *controller = [delegate loginController];
//    if (loginController == nil) {
//        SigninViewController *controller =  = [[SigninViewController alloc] init];
//    } else {
//        [loginController.navigationController popViewControllerAnimated:NO];
//    }
    [self viewWillDisappear:NO];
    [self.navigationController pushViewController:controller animated:NO];
}

- (void)openUrl:(NSString*)urlString {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", urlString]];
	[[UIApplication sharedApplication] openURL:url];
}

- (void)addTitle {
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(10, 74, 300, 31)] autorelease];
    label.font = [UIFont fontWithName:@"MartiniPro-Bold" size:23];
    label.minimumFontSize = 17;
    label.text = [self.title uppercaseString];
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label]; 
    
    self.viewTitleLabel = label;
}

- (void)setNavbar {
    [self.navigationController setNavigationBarHidden:YES];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    imageView.frame = CGRectMake(103, 4, 118, 58);
    [self.view addSubview:imageView];
    [imageView release];
    
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stripe.png"]];
    imageView.frame = CGRectMake(0, 67, 320, 6);
    [self.view addSubview:imageView];
    [imageView release];
    
    NSArray *controllers = [self.navigationController viewControllers];
    if ([controllers indexOfObject:self] > 0) {
        if (![self isKindOfClass:[SigninViewController class]]) {
            [self setBackButton];
        }
    }
    if (self.title != nil) {
        [self addTitle];
    }
}

- (void)setUserButton {
    UIImage *image = [UIImage imageNamed:@"profile_icon.png"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0, 0, image.size.width, image.size.height); 
	[button setBackgroundImage:image forState:UIControlStateNormal];
    
    image = [UIImage imageNamed:@"navbar_separator.png"];
	[button setImage:image forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
	[button addTarget:self 
               action:@selector(userButtonClicked)
	 forControlEvents:UIControlEventTouchUpInside];
    
	UIBarButtonItem *rightButton = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
	self.navigationItem.rightBarButtonItem = rightButton; 
}

- (void)setBackButton {
    UIImage *image=[UIImage imageNamed:@"back_button.png"];
    
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(5, 11, 44, 44); 
	[backButton setImage:image forState:UIControlStateNormal];
	[backButton addTarget:self.navigationController 
               action:@selector(popViewControllerAnimated:)
	 forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}

- (void)showActivityIndicator {
	if([self.view viewWithTag:kIndicatorViewTag] != nil)
		return;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudback.png"]];
    UIView *container = [[UIView alloc] initWithFrame:imageView.frame];
    container.tag = kIndicatorViewTag;
    [container addSubview:imageView];
    [imageView release];
    
	UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	indicator.tag = kIndicatorViewTag;
	indicator.center = CGPointMake(container.frame.size.width / 2, container.frame.size.height / 2 - 10);
	indicator.layer.shadowColor = [UIColor grayColor].CGColor;
	indicator.layer.shadowRadius = 1;
	indicator.layer.shadowOpacity = 0.5;
	indicator.layer.shadowOffset = CGSizeMake(0, 1);
	[indicator startAnimating];
	[container addSubview:indicator];
    [indicator release];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, container.frame.size.height / 2 + 7, container.frame.size.width, 38)];
    label.textColor = [UIColor grayColor];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0, -1);
    label.font = [UIFont boldSystemFontOfSize:14];
    label.minimumFontSize = 10; 
    label.textAlignment = UITextAlignmentCenter;
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.numberOfLines = 2;
    label.text = LS(@"Подождите...");
    label.backgroundColor = [UIColor clearColor];
    
    [container addSubview:label];
    self.activityLabel = label;
    [label release];
    
    container.center = CGPointMake(self.view.center.x, self.view.frame.size.height / 2);
    
	[self.view addSubview:container];
    [container release];
}

- (void)hideActivityIndicator {
	[[self.view viewWithTag:kIndicatorViewTag] removeFromSuperview];
}

#pragma mark - Common Actions 

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)msg { 
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
														message:msg 
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles:nil, nil];
	
	[alertView show];
	[alertView release];
} 

@end
