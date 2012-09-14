//
//  InstructionViewController.m
//  martini
//
//  Created by zlata samarskaya on 03.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InstructionViewController.h"

#import "MNetworkManager.h"

@implementation InstructionViewController
@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(dataDidLoad:) 
                                                 name:nManualLoaded 
                                               object:nil];
    [self showActivityIndicator];
    [[MNetworkManager sharedInstance] manual];
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nManualLoaded object:nil];
}


- (void)dealloc {
    [webView release];
    [super dealloc];
}

#pragma mark - Notifications

- (void)dataDidLoad:(NSNotification*)notification {
    if ([self handleError:notification]) {
        return;
    }
   // [webView loadHTMLString:notification.object baseURL:nil];
    NSString *urlStr = [kServerUrl stringByAppendingString:notification.object];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [webView loadRequest:request];
}


@end
