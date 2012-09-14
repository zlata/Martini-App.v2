//
//  NewsCell.m
//  martini
//
//  Created by zlata samarskaya on 14.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "NewsCell.h"
#import "MModel.h"
#import "MUser.h"

@implementation NewsCell

- (void)loadModel:(MModel *)model {

    if ([model isMemberOfClass:[MNews class]]) {
        MNews *news = (MNews*)model;
         title.text = news.title;
       // category.text = news.category;
        subtitle.text = news.text;
        if (news.imagePath != nil) {
            imgView.image = [UIImage imageWithContentsOfFile:news.imagePath];
        }
        [super loadModel:model];
        if (!news.isNew) {
            //self.contentView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
            title.textColor = [UIColor darkTextColor];
       } else {
            title.textColor = redTextColor;
           //self.contentView.backgroundColor = [UIColor whiteColor];
        }
        return; 
    }

    if ([model isMemberOfClass:[MMessage class]]) {
        MMessage *message = (MMessage*)model;
        title.text = message.title;
        subtitle.text = message.message;
 
        if (message.imagePath != nil) {
            imgView.image = [UIImage imageWithContentsOfFile:message.imagePath];
        } else {
            imgView.image = [UIImage imageNamed:@"icon.png"];
        }
        [self selectCell:[message.status isEqualToString:@"new"]];
        [super loadModel:model];
        
        return;
    }
    if ([model isMemberOfClass:[MInvite class]]) {
        MInvite *invite = (MInvite*)model;
        title.text = [invite.user fullname];
        subtitle.text = @"";
        if (invite.imagePath != nil) {
            imgView.image = [UIImage imageWithContentsOfFile:invite.imagePath];
        } else {
            imgView.image = [UIImage imageNamed:@"icon.png"];
        }
        [self selectCell:[invite.status isEqualToString:@"new"]];
       
        [super loadModel:model];
        return;
    }
    if ([model isMemberOfClass:[MCoctail class]]) {
        MCoctail *coctail = (MCoctail*)model;
        title.textColor = redTextColor;
        title.text = coctail.name;
        CGRect frame = title.frame;
        frame.size.height = 66;
        title.frame = frame;
       // subtitle.text = coctail.desc;
        if (coctail.imagePath != nil) {
            imgView.image = [UIImage imageWithContentsOfFile:coctail.imagePath];
        }
        
        [super loadModel:model];
        return;
    }
}

+ (NSString*)nibName {
    return @"NewsCell";
}

- (void)selectCell:(BOOL)selected {
    UIColor *titleColor = selected ? redTextColor : grayTextColor;
    UIColor *borderColor = selected ? redTextColor : [UIColor lightGrayColor] ;
    
    title.textColor = titleColor;
    imgView.layer.borderColor = borderColor.CGColor;
}

@end

@implementation InviteCell

+ (NSString*)nibName {
    return @"InviteCell";
}

- (void)loadModel:(MModel *)model {
    MInvite *invite = (MInvite*)model;
    title.text = [NSString stringWithFormat:@"Приглашение в бар от %@", [invite.user fullname]];
    subtitle.text = @"";
    if (invite.imagePath != nil) {
        imgView.image = [UIImage imageWithContentsOfFile:invite.imagePath];
    } else {
        imgView.image = [UIImage imageNamed:@"icon.png"];
    }
    
    BOOL new = [invite.status isEqualToString:@"new"];
    UIColor *titleColor = new ? redTextColor : grayTextColor;
    
    title.textColor = titleColor;
    
    [super loadModel:model];
}

@end

@implementation MessageCell

+ (NSString*)nibName {
    return @"MessageCell";
}

- (void)loadModel:(MModel *)model {
    MMessage *message = (MMessage*)model;
    title.text = message.user.name;
    subtitle.text = message.message;
    
    if (message.imagePath != nil) {
        imgView.image = [UIImage imageWithContentsOfFile:message.imagePath];
    } else {
        imgView.image = [UIImage imageNamed:@"icon.png"];
    }
    BOOL new = [message.status isEqualToString:@"new"];
    UIColor *titleColor = new ? redTextColor : grayTextColor;
    
    title.textColor = redTextColor;
        subtitle.textColor = titleColor;
        subtitle.textColor =  grayTextColor;
   [super loadModel:model];
    
    return;
}

@end
