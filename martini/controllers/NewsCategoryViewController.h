//
//  MoreViewController.h
//  martini
//
//  Created by zlata samarskaya on 03.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BasePagerViewController.h"
#import "MSocialManager.h"

@class MEvent;

@interface NewsCategoryViewController : BasePagerViewController <UITableViewDataSource, UITableViewDelegate, MSocialManagerDelegate> {
    NSDictionary *news_;
    IBOutlet UIButton *checkInButton;
    MEvent *event_;
    
    BOOL shouldReload;
}

@property(nonatomic, retain) NSDictionary* news;
@property(nonatomic, retain) MEvent *event;

- (IBAction)checkin:(id)sender;

@end
