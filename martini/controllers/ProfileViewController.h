//
//  ProfileViewController.h
//  martini
//
//  Created by zlata samarskaya on 14.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FormViewController.h"

@class MUser;

@interface ProfileViewController : FormViewController {
    
    IBOutlet UIImageView *avatar;
    IBOutlet UILabel *surnameLabel;
    IBOutlet UILabel *status;
    IBOutlet UIImageView *statusimage;
    IBOutlet UILabel *nameLabel;
    IBOutlet UIButton *twButton;
    IBOutlet UIButton *vkButton;
    IBOutlet UIButton *fbButton;
    
    MUser *user_;
}

@property (nonatomic, retain) MUser *user;

- (IBAction)friends:(id)sender;
- (IBAction)history:(id)sender;
- (IBAction)profile:(id)sender;
- (IBAction)showFb:(id)sender;
- (IBAction)showTw:(id)sender;
- (IBAction)showVk:(id)sender;

- (void)loadViewData;

@end
