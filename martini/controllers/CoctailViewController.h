//
//  CoctailViewController.h
//  martini
//
//  Created by zlata samarskaya on 11.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseViewController.h"

@class MCoctail;

@interface CoctailViewController : BaseViewController {
    MCoctail *coctail_;
    IBOutlet UIScrollView *scroll;
    IBOutlet UIImageView *imageView_;
    IBOutlet UILabel *receptLabel;
    IBOutlet UIButton *inviteButton;
}

@property(nonatomic, retain) MCoctail *coctail;

- (id)initWithCoctail:(MCoctail*)coctail;
- (IBAction)invite:(id)sender;

@end
