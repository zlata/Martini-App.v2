//
//  UserProfileViewController.m
//  martini
//
//  Created by zlata samarskaya on 26.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UserProfileViewController.h"
#import "LocationViewController.h"
#import "CoctailsViewController.h"
#import "MessagesViewController.h"

#import "AddPhotoView.h"

#import "MUser.h"
#import "MModel.h"
#import "MNetworkManager.h"

@implementation UserProfileViewController

@synthesize event = event_;

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

- (void)initTextfields {
    self.textFields = [NSArray arrayWithObjects:messageView.theme, messageView.message, nil];
}

- (void)setBackButton {
    UIImage *image=[UIImage imageNamed:@"back_button.png"];
    
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(5, 11, 44, 44); 
	[backButton setImage:image forState:UIControlStateNormal];
	[backButton addTarget:self.navigationController 
                   action:@selector(popViewControllerAnimated:)
         forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:backButton];
}

- (void)setNavbar {
    [self.navigationController setNavigationBarHidden:YES];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    imageView.frame = CGRectMake(103, 4, 118, 58);
    [scroll addSubview:imageView];
    [imageView release];
    
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stripe.png"]];
    imageView.frame = CGRectMake(0, 67, 320, 6);
    [scroll addSubview:imageView];
    [imageView release];
    
    [self setBackButton];
    [self addTitle];
}

- (void)viewDidLoad {

    messageView = [[SendMessageView viewFromNib] retain];
    
    CGRect rect = messageView.frame;
    rect.origin.y = 352;
    messageView.frame = rect;
    [messageView.sendButton addTarget:self 
                                action:@selector(sendMessage) 
                      forControlEvents:UIControlEventTouchUpInside];
    
    messageView.theme.delegate = self;
    messageView.message.delegate = self;
    [super viewDidLoad];

    [scroll addSubview:messageView];
    rect = formView.frame;
    rect.origin.y = 73;
    formView.frame = rect;
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(followFinished:) 
                                                 name:nFollowUserFinished 
                                               object:nil];
    [self.view bringSubviewToFront:scroll];
//    [self.view bringSubviewToFront:backButton];
    
    [messagesButton.titleLabel setFont:[UIFont fontWithName:@"MartiniPro-Bold" size:15]];
    UIImage *img = stretchImage([UIImage imageNamed:@"button.png"]);
    [messagesButton setBackgroundImage:img forState:UIControlStateNormal];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.event == nil) {
        inviteButton.enabled = NO;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(messageSent:) 
                                                 name:nSendMessageFinished 
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:nSendMessageFinished object:nil];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nFollowUserFinished object:nil];
 
    [locationButton release];
    locationButton = nil;
    [keyButton release];
    keyButton = nil;
    [userProfileButton release];
    userProfileButton = nil;
    [followButton release];
    followButton = nil;
    [inviteButton release];
    inviteButton = nil;
    [messagesButton release];
    messagesButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)loadData {
    [self performSelector:@selector(showActivityIndicator) 
               withObject:nil 
               afterDelay:0];
    [[MNetworkManager sharedInstance] userDetails:self.user];    
}

- (void)loadViewData {
    [super loadViewData];
 //   statusimage.hidden = YES;
    locationButton.enabled = self.user.mutual && self.user.lon != 0 && self.user.lat != 0;
    keyButton.enabled = NO;
    userProfileButton.enabled = NO;
    followButton.enabled = !self.user.following;
}

#pragma mark - Actions

- (void)sendMessage {
    NSString *str = messageView.message.text;
    if ([str length] == 0) {
        [self showAlertWithTitle:@"" andMessage:@"Введите сообщение"];
        return;
    }
    [currentField resignFirstResponder];
    
    MMessage *msg = [[[MMessage alloc] init] autorelease];
    msg.message = str;
    msg.title = messageView.theme.text;
    
    [self performSelector:@selector(showActivityIndicator) 
               withObject:nil 
               afterDelay:0];
    [[MNetworkManager sharedInstance] sendMessage:msg recipient:self.user event:self.event];
}

- (IBAction)location:(id)sender {
    LocationViewController *controller = [[[LocationViewController alloc] init] autorelease];
    controller.user = self.user;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)key:(id)sender {

}

- (IBAction)userProfile:(id)sender {

}

- (IBAction)follow:(id)sender {
    [self performSelector:@selector(showActivityIndicator) 
               withObject:nil 
               afterDelay:0];
    [[MNetworkManager sharedInstance] followUser:self.user];
}

- (IBAction)bar:(id)sender {
    CoctailsViewController *controller = [[[CoctailsViewController alloc] init] autorelease];
    controller.user = self.user;
    controller.event = self.event;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)messages:(id)sender {
    MessagesViewController *controller = [[[MessagesViewController alloc] init] autorelease];
    controller.user = self.user;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Notifications

- (void)followFinished:(NSNotification*)notification {
    MUser *user = (MUser*)[notification object];
    if (self.user.databaseId != user.databaseId) {
        return;
    }
    
    if ([self handleError:notification]) {
        return;
    }

    [self showAlertWithTitle:@"" andMessage:@"Пользователь добавлен в друзья"];
}

- (void)messageSent:(NSNotification*)notification {    
    if ([self handleError:notification]) {
        return;
    }
    [self showAlertWithTitle:@"" andMessage:@"Сообщение отправлено"];
    [messageView close:nil];
}

- (void)dealloc {
    [locationButton release];
    [keyButton release];
    [userProfileButton release];
    [followButton release];
    [event_ release];
    [messageView release];
    
    [inviteButton release];
    [messagesButton release];
    [super dealloc];
}

@end
