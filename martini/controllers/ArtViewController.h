//
//  ArtViewController.h
//  martini
//
//  Created by zlata samarskaya on 24.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseSharingViewController.h"

@class MEvent;
@class MArtView;

@interface ArtViewController : BaseSharingViewController {
    MEvent *event_;
    
    IBOutlet UIScrollView *scroll;
    IBOutlet UIButton *saveButton;
    MArtView *artView;
    IBOutlet UILabel *descriptionLabel;
}

- (IBAction)save:(id)sender;
- (id)initWithEvent:(MEvent*)event;

@property(nonatomic, retain) MEvent *event;

@end
