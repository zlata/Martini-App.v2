//
//  EventsViewController.h
//  martini
//
//  Created by zlata samarskaya on 26.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BasePagerViewController.h"
#import "MSocialManager.h"

@interface EventsViewController : BasePagerViewController <MSocialManagerDelegate> {
    
    IBOutlet UIButton *mapButton;
    BOOL shouldUpdate;
}

- (IBAction)eventLocation:(id)sender;

@end
