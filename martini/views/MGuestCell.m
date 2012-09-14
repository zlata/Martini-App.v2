//
//  MGuestCell.m
//  martini
//
//  Created by zlata samarskaya on 26.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "MGuestCell.h"
#import "MModel.h"
#import "MUser.h"
#import "MUtils.h"

@implementation MGuestCell
@synthesize followImage;

- (void)loadModel:(MModel*)model {
    MUser *user = (MUser*)model;
    title.textColor = redTextColor;
    title.text = user.surname;
    name.textColor = redTextColor;
    name.text = user.name;
    
    //subtitle.text = user.status;
    if (user.imagePath != nil) {
        imgView.image = [UIImage imageWithContentsOfFile:user.imagePath];
    }
    [super loadModel:model];
}

- (void)setFollow {
    MUser *user = (MUser*)self.model;
    UIImage *fImage = nil;
    if (user.mutual) {
        fImage = [UIImage imageNamed:@"follow2.png"];
    } else {
        if (user.following) {
            fImage = [UIImage imageNamed:@"follow1.png"];
        } else {
            if (user.followMe)
                fImage = [UIImage imageNamed:@"follow3.png"];
        }
    }
    if (fImage == nil) {
        followImage.hidden = YES;
        return;
    }
    followImage.hidden = NO;
    followImage.image = fImage;   
}

+ (NSString*)nibName {
    return @"MGuestCell";
}

- (void)dealloc {
    [name release];
    [followImage release];
    [super dealloc];
}

@end

@implementation MEventCell

@synthesize mapButton;
@synthesize checkinButton;
@synthesize event = event_;

- (void)loadModel:(MModel*)model history:(BOOL)history {
    MEvent *event = (MEvent*)model;
    self.event = event;
    title.text = event.title;
    subtitle.text = event.desc;
    CGSize s = [event.desc sizeWithFont:subtitle.font 
                      constrainedToSize:CGSizeMake(subtitle.frame.size.width, 1000) 
                          lineBreakMode:UILineBreakModeWordWrap];
    CGRect rect = subtitle.frame;
    if (s.height < subtitle.frame.size.height) {
        rect.size.height = s.height;
    } else {
        rect.size.height = 41;       
    }
    subtitle.frame = rect;
    if (event.imagePath != nil) {
        imgView.image = [UIImage imageWithContentsOfFile:event.imagePath];
    }
    rect = self.frame;
    if (history) {
        rect.size.height = 76;
        pastView.hidden = YES;
        self.backgroundColor = [UIColor whiteColor];
        bottomView.hidden = YES;
        self.frame = rect;
        [super loadModel:model];
        return;
   }
    pastView.hidden = NO;
    if ([event actual]) {
        title.textColor = redTextColor;
        rect.size.height = 129;
        bottomView.hidden = NO;
        self.backgroundColor = [UIColor whiteColor];
        dateLabel.text = [MUtils dateString:event.date format:@"dd.MMMM.yyyy HH:mm"]; 
   } else {
        bottomView.hidden = YES;
        rect.size.height = 100;
        if ([event past]) {
            self.contentView.backgroundColor = [UIColor colorWithWhite:0.81 alpha:1];
           // pastView.hidden = NO;
            dateLabel.text = @"это мероприятие уже прошло";
        } else {
            self.contentView.backgroundColor = [UIColor colorWithRed:224/255.f 
                                                               green:211/255.f 
                                                                blue:127/255.f 
                                                               alpha:1];
            dateLabel.text = @"Вы далеко от мероприятия";//места проведения [MUtils dateString:event.date format:@"dd.MMMM.yyyy HH:mm"]; 
        }
    }
    if (DEBUG_EVENTS) {
        checkinButton.enabled = YES;
        return;

    }
    self.frame = rect;
    if ([event actual] && [MCurrentUser sharedInstance].event != nil) {
        if (self.event.databaseId == [MCurrentUser sharedInstance].event.databaseId) {
            checkinButton.enabled = YES;
            [checkinButton setTitle:[@"Check-Out" uppercaseString] forState:UIControlStateNormal];
        } else {
            checkinButton.enabled = NO;
            [checkinButton setTitle:[@"Check-In" uppercaseString] forState:UIControlStateNormal];
        }
    } else {
        if ([event actual]) {
            [checkinButton setTitle:[@"Check-In" uppercaseString] forState:UIControlStateNormal];
            checkinButton.enabled = YES;
            checkinButton.hidden = NO;
        }
    }
    [super loadModel:model];
}

- (void)awakeFromNib {
    
 //   self.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right_arrow.png"]] autorelease];
    [checkinButton.titleLabel setFont:[UIFont fontWithName:@"MartiniPro-Bold" size:15]];
    UIImage *img = stretchImage([UIImage imageNamed:@"button.png"]);
    [checkinButton setBackgroundImage:img forState:UIControlStateNormal];
}

+ (NSString*)nibName {
    return @"MEventCell";
}

- (void)dealloc {
    [mapButton release];
    [checkinButton release];
    [bottomView release];
    [pastView release];
    [event_ release];
    
    [super dealloc];
}

@end