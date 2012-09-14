//
//  ProfileViewController.m
//  martini
//
//  Created by zlata samarskaya on 14.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "ProfileViewController.h"
#import "EditProfileViewController.h"
#import "FriendsViewController.h"
#import "HistoryViewController.h"

#import "MUser.h"
#import "MUtils.h"

#import "MNetworkManager.h"

@interface ProfileViewController (PrivateMethods)
- (void)loadViewData;
//- (void)loadUserData;
@end


@implementation ProfileViewController

@synthesize user = user_;

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

- (void)initTextfields {
    self.textFields = [NSArray array];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
 
   // avatar.layer.borderWidth = 1;
   // avatar.layer.borderColor = [UIColor colorWithWhite:.66 alpha:1].CGColor;
    if (self.user.name) {
        surnameLabel.text = self.user.name;
    }
//    UIImage *baloon = [UIImage imageNamed:@"baloon.png"];
//    statusimage.image = [baloon stretchableImageWithLeftCapWidth:baloon.size.width / 2 topCapHeight:baloon.size.height / 2];
     [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(getDataFinished:) 
                                                 name:nUserDetailsLoaded 
                                               object:nil];
    
    if (self.user == nil) {
        self.user = [MCurrentUser sharedInstance].user;
    }  
    [self.user addObserver:self forKeyPath:@"imagePath" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([MCurrentUser sharedInstance].sid == nil) {
        if([[MCurrentUser sharedInstance].user isEqual:self.user]) {
            surnameLabel.text = [self.user.name uppercaseString];
            statusimage.hidden = YES;
            fbButton.enabled = NO;
            twButton.enabled = NO;
            vkButton.enabled = NO;
            
            avatar.image = nil;
        }
        [self autorize];
    } else {
        [self loadData];
    }
}

- (void)viewDidUnload {
    [avatar release];
    avatar = nil;
    [nameLabel release];
    nameLabel = nil;
    [surnameLabel release];
    surnameLabel = nil;
    [status release];
    status = nil;
    [statusimage release];
    statusimage = nil;
    [fbButton release];
    fbButton = nil;
    [twButton release];
    twButton = nil;
    [vkButton release];
    vkButton = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nUserDetailsLoaded object:nil];
    
    [self.user removeObserver:self forKeyPath:@"imagePath"];
    [user_ release];
    user_ = nil;
   
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [avatar release];
    [nameLabel release];
    [surnameLabel release];
    [status release];
    [statusimage release];
    [fbButton release];
    [twButton release];
    [vkButton release];
    
    [super dealloc];
}

- (void)loadData {
    [self performSelector:@selector(showActivityIndicator) 
               withObject:nil 
               afterDelay:0];
    [[MNetworkManager sharedInstance] userDetails:self.user];    
}

- (void)loadViewData {
    surnameLabel.text = [self.user.name uppercaseString];
//    if ([self.user.status length] > 0) {
//        statusimage.hidden = NO;
//        CGSize s = [MUtils sizeForLabel:status text:self.user.status];
//        CGRect rect = status.frame;
//        rect.size.height = s.height;
//        status.frame = rect;
//        status.text = self.user.status;
//        
//        rect = statusimage.frame;
//        rect.size.height = s.height + 20;
//        statusimage.frame = rect;
//    }
    BOOL fb = [self.user.fbId length] > 1;
    fbButton.enabled = fb;
    twButton.enabled = [self.user.twId length] > 1;
    vkButton.enabled = [self.user.vkId length] > 1;
    
    if (self.user.imagePath != nil) {
        avatar.image = [UIImage imageWithContentsOfFile:self.user.imagePath];
        [MCurrentUser sharedInstance].image = avatar.image;
    }
}

#pragma mark - Actions

- (IBAction)friends:(id)sender {
    FriendsViewController *controller = [[[FriendsViewController alloc] init] autorelease];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)history:(id)sender {
    HistoryViewController *controller = [[[HistoryViewController alloc] init] autorelease];
    [self.navigationController pushViewController:controller animated:YES];   
}

- (IBAction)profile:(id)sender {
    EditProfileViewController *controller = [[[EditProfileViewController alloc] init] autorelease];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)showFb:(id)sender {
    NSString *str = [NSString stringWithFormat:@"facebook.com/profile.php?id=%@", self.user.fbId];
    [self openUrl:str];
}

- (IBAction)showTw:(id)sender {
    [self openUrl:[NSString stringWithFormat:@"twitter.com/%@", self.user.twId]];
}

- (IBAction)showVk:(id)sender {
    [self openUrl:[NSString stringWithFormat:@"vkontakte.ru/id%@", self.user.vkId]];
}

#pragma mark - Notifications

- (void)getDataFinished:(NSNotification*)notification {
    MUser *user = (MUser*)[notification object];
    if (self.user.databaseId != user.databaseId) {
        return;
    }
    
    if ([self handleError:notification]) {
        return;
    }
    
    self.user = user;
    [self loadViewData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"imagePath"]) {
        UIImage *img = [UIImage imageWithContentsOfFile:self.user.imagePath];
        if (img != nil) {
            avatar.image = img;
            [MCurrentUser sharedInstance].image = img;
        } else {
            if([self.user isEqual:[MCurrentUser sharedInstance].user] &&
               [MCurrentUser sharedInstance].sid == nil) {
                avatar.image = nil;
            }
        }        
    }
}

- (void)signinFinished:(NSNotification*)notification {
    [super signinFinished:notification];
    
}

@end
