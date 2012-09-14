//
//  MAppDelegate.m
//  martini
//
//  Created by zlata samarskaya on 02.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MAppDelegate.h"
#import "SigninViewController.h"
#import "MUtils.h"
#import "MNetworkManager.h"
#import "MLocationManager.h"
#import "MUser.h"

@implementation MAppDelegate

@synthesize tabbarController = _tabbarController;
@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize loginController;

- (void)dealloc {
    [_window release];
    [_navigationController release];
    [loginController release];
    [_tabbarController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application 
didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    self.window.backgroundColor = [UIColor whiteColor];
    
    if ([self.tabbarController.tabBar respondsToSelector:@selector(setSelectedImageTintColor)]) {
        self.tabbarController.tabBar.selectedImageTintColor = [UIColor redColor];
    }
    self.tabbarController.delegate = self;
    
    [self.window addSubview:self.tabbarController.view];

    [self.window makeKeyAndVisible];

    [MUtils clearCache:@"temp"];
    [MLocationManager sharedInstance];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    
	NSString* newToken = [deviceToken description];
	//NSLog(@"My token is: %@", newToken);//efcac38f396921fb78b183375e6107204ca2334d707ebffd4c621b8426effb7a
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];

    [MSettings setPushTocken:newToken];
    [[MNetworkManager sharedInstance] registerPush];
	//NSLog(@"My token is: %@", newToken);//efcac38f396921fb78b183375e6107204ca2334d707ebffd4c621b8426effb7a
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo {
	NSLog(@"Received notification: %@", userInfo);
	 //[self addMessageFromRemoteNotification:userInfo updateUI:YES];
}

- (void)application:(UIApplication*)application 
didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (UIViewController*)loginController {
    if (loginController == nil) {
        loginController = [[SigninViewController alloc] init];
    } else {
        [loginController.navigationController popViewControllerAnimated:NO];
    }
    return loginController;
}

- (void)popToNews {
    self.loginController = nil;
    for (UINavigationController *nav in self.tabbarController.viewControllers) {
        if ([nav isKindOfClass:[UINavigationController class]]) {
            [nav popToRootViewControllerAnimated:NO];
        }
    }
    [self.tabbarController setSelectedIndex:0];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    BOOL hidden = [settings boolForKey:@"hideLocation"];  
    if (hidden && ![MCurrentUser sharedInstance].hidden) {
        [[MNetworkManager sharedInstance] hideLocation];
    }
    [MCurrentUser sharedInstance].hidden = hidden;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    if ([MCurrentUser sharedInstance].event != nil) {
        [[MNetworkManager sharedInstance] checkout:[MCurrentUser sharedInstance].event];
    }
}

- (BOOL)tabBarController:(UITabBarController *)tbc shouldSelectViewController:(UIViewController *)vc {
    UINavigationController *selected = (UINavigationController*)[tbc selectedViewController];
    if ([selected isEqual:vc]) {
        UIViewController *viewController = [selected topViewController];
        if ([viewController isKindOfClass:[SigninViewController class]]) {
            return NO;
        }
    }
        
    return YES;
}

@end
