//
//  SendMessageViewController.h
//  martini
//
//  Created by zlata samarskaya on 11.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FormViewController.h"

@class SendMessageView;
@class MUser;
@class MEvent;

@interface SendMessageViewController : FormViewController {
    
    SendMessageView *messageView;  
    MUser *user_;
    MEvent *event_;
}

@property (retain, nonatomic) MUser *user;
@property (retain, nonatomic) MEvent *event;

@end
