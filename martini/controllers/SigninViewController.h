//
//  RootViewController.h
//  martini
//
//  Created by zlata samarskaya on 02.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BaseViewController.h"

#import "OAuth.h"
#import "MSocialManager.h"

@class MFontLabel;

@interface SigninViewController : BaseViewController <MSocialManagerDelegate> {
    
    IBOutlet MFontLabel *tipLabel;
    BOOL shown_;
    IBOutlet UIButton *loginButton;
 //   Facebook *facebook;
 //   OAuth *oAuth;
 //   UIWebView *vkAuthWebView;
}

- (IBAction)facebook:(id)sender;
- (IBAction)twitter:(id)sender;
- (IBAction)vkontakte:(id)sender;
- (IBAction)registration:(id)sender;
- (IBAction)login:(id)sender;

@end
