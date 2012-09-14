//
//  CoctailsViewController.h
//  martini
//
//  Created by zlata samarskaya on 05.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BasePagerViewController.h"

@class MUser;
@class MEvent;
@class MInvite;

@interface CoctailsViewController : BasePagerViewController {
    
    MUser *user_;
    MEvent *event_;
    MInvite *invite_;
}

@property (nonatomic, retain) MUser *user;
@property (nonatomic, retain) MEvent *event;
@property (nonatomic, retain) MInvite *invite;

@end
