//
//  MGuestCell.h
//  martini
//
//  Created by zlata samarskaya on 26.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MFontLabel.h"

@interface MGuestCell : MBaseCell {
    
    IBOutlet UILabel *name;
}
@property (retain, nonatomic) IBOutlet UIImageView *followImage;

- (void)setFollow;

@end

@class MEvent;

@interface MEventCell : MBaseCell {

    IBOutlet UIView *bottomView;
    IBOutlet UIView *accView;
    IBOutlet UIView *pastView;
    IBOutlet UILabel *dateLabel;
    MEvent *event_;
}

@property (retain, nonatomic) IBOutlet UIButton *mapButton;
@property (retain, nonatomic) IBOutlet UIButton *checkinButton;
@property (retain, nonatomic) IBOutlet MEvent *event;

- (void)loadModel:(MModel*)model history:(BOOL)history;

@end