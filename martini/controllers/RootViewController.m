//
//  RootViewController.m
//  martini
//
//  Created by zlata samarskaya on 02.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "SigninViewController.h"
#import "NewsListViewController.h"
#import "ProfileViewController.h"

#import "MUser.h"
#import "MUtils.h"
@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
       // self.title = @"welcome";
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
                                             selector:@selector(signinFinished:) 
                                                 name:nSigninFinished 
                                               object:nil];
//    
//    NSDate *ov = [MUtils stringToDate:@"12.11.2011" format:@"dd.MM.yyyy"];
//    NSDate *pdr = [ov dateByAddingTimeInterval:(3600 * 24 * 266)];
//    NSLog(@" PDR %@", pdr);
}

- (void)viewDidUnload {
    [super viewDidUnload];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:nSigninFinished object:nil];
}

- (void)dealloc {

    [super dealloc];
}

#pragma mark Notifications

- (void)signinFinished:(NSNotification*)notification {
    if ([self handleError:notification]) {
        return;
    }
    [self performSelector:@selector(signin) withObject:nil afterDelay:0.7];
}

#pragma mark Actions

- (IBAction)news:(id)sender {
    NewsListViewController *controller = [[[NewsListViewController alloc] init] autorelease];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)signin:(id)sender {
    if ([MCurrentUser sharedInstance].sid == nil) {
        SigninViewController *controller = [[[SigninViewController alloc] init] autorelease];
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
    ProfileViewController *controller = [[[ProfileViewController alloc] init] autorelease];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)signin {
    NSMutableArray *array = [self.navigationController.viewControllers mutableCopy];
    SigninViewController *signin = nil;
    for (UIViewController *c in array) {
        if ([c isKindOfClass:[SigninViewController class]]) {
            signin = (SigninViewController*)c;
            break;
        }
    }
    if (signin != nil) {
        [array removeObject:signin];
        self.navigationController.viewControllers = array;
    }
}



@end
