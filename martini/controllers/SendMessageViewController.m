//
//  SendMessageViewController.m
//  martini
//
//  Created by zlata samarskaya on 11.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SendMessageViewController.h"

#import "AddPhotoView.h"
#import "MNetworkManager.h"
#import "MUser.h"

@implementation SendMessageViewController

@synthesize user = user_;
@synthesize event = event_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:@"SendMessageViewController" bundle:nibBundleOrNil];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(messageSent:) 
                                                 name:nSendMessageFinished 
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nSendMessageFinished object:nil];
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
    
 }

- (void)viewDidLoad {

    messageView = [[SendMessageView viewFromNib] retain];
    formView = messageView;

    CGRect rect = messageView.frame;
    rect.origin.y = 397;
    messageView.frame = rect;
    [messageView.sendButton addTarget:self 
                               action:@selector(sendMessage) 
                     forControlEvents:UIControlEventTouchUpInside];
    [messageView.closeButton addTarget:self 
                               action:@selector(close) 
                     forControlEvents:UIControlEventTouchUpInside];

    messageView.theme.delegate = self;
    messageView.message.delegate = self;
   
    [super viewDidLoad];
    [messageView open];
    
}

- (void)viewDidUnload {
     [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [user_ release];
    [messageView release];
    [event_ release];
    
    [super dealloc];
}

- (void)close {
    formView = nil;
    [self dismissModalViewControllerAnimated:YES];    
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

#pragma mark - Notifications

- (void)messageSent:(NSNotification*)notification {    
    if ([self handleError:notification]) {
        return;
    }
    [self showAlertWithTitle:@"" andMessage:@"Сообщение отправлено"];
    formView = nil;
    [self dismissModalViewControllerAnimated:YES];
}

@end
