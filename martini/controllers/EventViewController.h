//
//  EventViewController.h
//  martini
//
//  Created by zlata samarskaya on 30.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BaseSharingViewController.h"

@class MEvent;
@class MCoctail;
@class MGuestsResult;
@class MMessagesResult;
@class MInvitesResult;

@interface EventViewController : BaseSharingViewController <UIActionSheetDelegate> {
    MEvent *event_;
    MCoctail *coctail_;
    
    IBOutlet UIImageView *imgView;
    IBOutlet UILabel *titleLabel;
    IBOutlet UITextView *deskLabel;
    
    IBOutlet UIButton *invitesButton;
    IBOutlet UIButton *messagesButton;
    IBOutlet UIButton *guestsButton;
    IBOutlet UIButton *mapButton;
    
    MGuestsResult *guestsResult_;
    MMessagesResult *messagesResult_;
    MInvitesResult *invitesResult_;
    
    NSMutableArray *titles_;
    NSMutableDictionary *guests_;
    
    int activeSegment_;
    
    BOOL shouldUpdate;
}

@property(nonatomic, retain) MEvent *event;
@property(nonatomic, retain) MCoctail *coctail;
@property(nonatomic, retain) MGuestsResult *guestsResult;
@property(nonatomic, retain) MMessagesResult *messagesResult;
@property(nonatomic, retain) MInvitesResult *invitesResult;
@property(nonatomic, retain) NSMutableArray *titles;
@property(nonatomic, retain) NSMutableDictionary *guests;

- (IBAction)guests:(id)sender;
- (IBAction)messages:(id)sender;
- (IBAction)invites:(id)sender;
- (IBAction)gallery:(id)sender;
- (IBAction)map:(id)sender;

@end
