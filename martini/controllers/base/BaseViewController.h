//
//  BaseViewController.h
//  Kinopoisk
//
//  Created by zlata samarskaya on 10.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController {
    UILabel *activityLabel;
    UILabel *viewTitleLabel;
    UIButton *backButton;
    BOOL shown;
}

@property(nonatomic, retain)UILabel *activityLabel;
@property(nonatomic, retain)UILabel *viewTitleLabel;

- (void)setBackButton;
- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)msg;
- (void)showActivityIndicator;
- (void)hideActivityIndicator;
- (BOOL)handleError:(NSNotification*)notification;
- (void)addTitle;
- (void)openUrl:(NSString*)urlString;
- (void)autorize;
- (void)loadData;
- (void)signinFinished:(NSNotification*)notification;
@end
