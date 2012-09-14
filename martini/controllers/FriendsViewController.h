//
//  FriendsViewController.h
//  martini
//
//  Created by zlata samarskaya on 26.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BasePagerViewController.h"

@interface FriendsViewController : BasePagerViewController {
    
    IBOutlet UIView *noFriendsView;
    IBOutlet UILabel *countLabel;
    IBOutlet UIButton *mapButton;
    IBOutlet UIView *friendsView;
}

- (IBAction)events:(id)sender;
- (IBAction)map:(id)sender;

@end
