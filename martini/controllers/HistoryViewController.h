//
//  HistoryViewController.h
//  martini
//
//  Created by zlata samarskaya on 27.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BasePagerViewController.h"

@interface HistoryViewController : BasePagerViewController {
    
    IBOutlet UIView *actionsView;
    IBOutlet UIView *noActionsView;
}

- (IBAction)events:(id)sender;

@end
