//
//  MessagesViewController.h
//  martini
//
//  Created by zlata samarskaya on 28.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BasePagerViewController.h"

@class MUser;

@interface MessagesViewController : BasePagerViewController {
    MUser *user_;
}

@property(nonatomic, retain) MUser *user;

@end
