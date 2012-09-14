//
//  MAppDelegate.h
//  martini
//
//  Created by zlata samarskaya on 02.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SigninViewController;

@interface MAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate>

@property (retain, nonatomic) IBOutlet UITabBarController *tabbarController;
@property (retain, nonatomic) IBOutlet UIWindow *window;
@property (retain, nonatomic) IBOutlet UINavigationController *navigationController;
@property (retain, nonatomic) SigninViewController *loginController;

- (void)popToNews;

@end
