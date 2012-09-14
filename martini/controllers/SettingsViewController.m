//
//  SettingsViewController.m
//  martini
//
//  Created by zlata samarskaya on 03.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"

#import "MUser.h"
#import "MNetworkManager.h"

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        self.title = @"настройки";
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadViewData {
    [userHideSwitch setOn:[MCurrentUser sharedInstance].user.isPrivate animated:YES];
    [locationHideSwitch setOn:[[MCurrentUser sharedInstance] hideLocation] animated:YES];
}

- (void)loadData {
 }

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(getDataFinished:) 
                                                 name:nUserDetailsLoaded 
                                               object:nil];
    [logoutButton.titleLabel setFont:[UIFont fontWithName:@"MartiniPro-Bold" size:15]];
    UIImage *img = stretchImage([UIImage imageNamed:@"button.png"]);
    [logoutButton setBackgroundImage:img forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFinished:) 
                                                 name:nUpdateUserFinished object:nil];
    if ([MCurrentUser sharedInstance].sid != nil) {
        [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];
        [[MNetworkManager sharedInstance] userDetails:[MCurrentUser sharedInstance].user];    
    } else {
        [self autorize];
    }
}

- (void)viewDidUnload {
    [userHideSwitch release];
    userHideSwitch = nil;
    [locationHideSwitch release];
    locationHideSwitch = nil;
    [autologinSwitch release];
    autologinSwitch = nil;
    [logoutButton release];
    logoutButton = nil;
    [super viewDidUnload];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:nUserDetailsLoaded object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nUpdateUserFinished object:nil];
}

#pragma mark Notifications

- (void)updateFinished:(NSNotification*)notification {
    if ([self handleError:notification]) {
        return;
    }
    MUser *user = [MCurrentUser sharedInstance].user;
    user.isPrivate = userHideSwitch.on;
}

- (void)getDataFinished:(NSNotification*)notification {
    if ([self handleError:notification]) {
        return;
    }
    MUser *user = (MUser*)[notification object];
    if ([MCurrentUser sharedInstance].user.databaseId != user.databaseId) {
        return;
    }
    
    if ([self handleError:notification]) {
        return;
    }
    
    [self loadViewData];
}

- (IBAction)hideUser:(id)sender {
    if ([MCurrentUser sharedInstance].user.isPrivate == userHideSwitch.on) {
        return;
    }
    [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:userHideSwitch.on ? @"1" : @"0" forKey:@"private"];
   [[MNetworkManager sharedInstance] updateUser:dictionary];
}

- (IBAction)hideLocation:(id)sender {
    BOOL hidden = [[MCurrentUser sharedInstance] hidden];
    if (hidden != locationHideSwitch.on) {
        [[MCurrentUser sharedInstance] hideLocation:locationHideSwitch.on]; 
    }
}

- (IBAction)autologin:(id)sender {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:autologinSwitch.on] forKey:@"autologin"];        
    if (autologinSwitch.on) {
        return;
    }
    [[MCurrentUser sharedInstance] logout];
}

- (IBAction)logout:(id)sender {
    [[MCurrentUser sharedInstance] logout];
}

- (void)dealloc {
    [userHideSwitch release];
    [locationHideSwitch release];
    
    [autologinSwitch release];
    [logoutButton release];
    [super dealloc];
}
@end
