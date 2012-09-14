//
//  UserProfileViewController.h
//  martini
//
//  Created by zlata samarskaya on 26.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewController.h"

@class SendMessageView;
@class MEvent;

@interface UserProfileViewController : ProfileViewController {
    SendMessageView *messageView;
    
    IBOutlet UIButton *locationButton;
    IBOutlet UIButton *userProfileButton;
    IBOutlet UIButton *keyButton;
    IBOutlet UIButton *followButton;

    IBOutlet UIButton *inviteButton;
    IBOutlet UIButton *messagesButton;
    MEvent *event_;
}

@property (nonatomic, retain) MEvent *event;

- (IBAction)location:(id)sender;
- (IBAction)key:(id)sender;
- (IBAction)userProfile:(id)sender;
- (IBAction)follow:(id)sender;
- (IBAction)bar:(id)sender;
- (IBAction)messages:(id)sender;

@end
