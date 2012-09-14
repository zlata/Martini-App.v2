//
//  BaseSharingViewController.m
//  martini
//
//  Created by zlata samarskaya on 14.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BaseSharingViewController.h"
#import "MSharingView.h"

#import "MNetworkManager.h"
#import "MSocialManager.h"

@implementation BaseSharingViewController

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    

    [MSocialManager sharedInstance].delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [MSocialManager sharedInstance].delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    sharingView = [[MSharingView viewFromNib] retain];
    CGRect rect = sharingView.frame;
    rect.origin.y = self.view.frame.size.height - 42;
    sharingView.frame = rect;
    
    [sharingView.facebookButton addTarget:self 
                                   action:@selector(facebook) 
                         forControlEvents:UIControlEventTouchUpInside];
    [sharingView.twitterButton addTarget:self 
                                   action:@selector(twitter) 
                         forControlEvents:UIControlEventTouchUpInside];
    [sharingView.vkButton addTarget:self 
                                   action:@selector(vk) 
                         forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:sharingView];
}

- (void)viewDidUnload {

    [super viewDidUnload];
}

- (void)dealloc {
    [sharingView release];
    
    [super dealloc];
}

#pragma mark - Facebook

- (void)facebook {
    [[MSocialManager sharedInstance] loginFb];    
}

- (void)fbDidLogin {
	NSLog(@"fb logged in");
    [self postFacebook];
}

- (void)postFacebook {
    [self showAlertWithTitle:@"" andMessage:@"Overload this"];    
}

#pragma mark - twitter

- (void)twDidLogin {
    [self postTwitter];
}

- (void)twitterDidNotLogin:(BOOL)cancelled {
}

- (void)postTwitter {
    [self showAlertWithTitle:@"" andMessage:@"Overload this"];    
}

- (void)twitter {
    [self postTwitter];
}

- (void)twDidPost {
    [self showAlertWithTitle:@"" andMessage:@"Опубликовано в Twitter"];    
}

#pragma mark - vkontakte

- (void)vk {
    [[MSocialManager sharedInstance] loginVk];    
}

- (void)postVK {
    [self showAlertWithTitle:@"" andMessage:@"Overload this"];  
}

- (void)vkDidLogin {
    [self postVK];
}

- (void)vkDidPost {
    [self performSelector:@selector(hideActivityIndicator)];
    [self showAlertWithTitle:@"" andMessage:@"Опубликовано в Контакте"];    
}

- (void)vkDidNotPost:(NSString*)errorMsg {
    [self performSelector:@selector(hideActivityIndicator)];
    if (errorMsg != nil) {
        [self showAlertWithTitle:@"" andMessage:errorMsg];    
    }
}
@end
