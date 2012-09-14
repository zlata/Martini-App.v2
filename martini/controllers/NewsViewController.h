//
//  NewsViewController.h
//  martini
//
//  Created by zlata samarskaya on 14.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BaseSharingViewController.h"

@class MNews;

@interface NewsViewController : BaseSharingViewController {
    
    IBOutlet UIScrollView *scroll;
    IBOutlet UIView *newsView;
    IBOutlet UIImageView *imageView;
    IBOutlet UILabel *newsTitleLabel;
    IBOutlet UITextView *textLabel;
    
    MNews *news_;
}

@property (nonatomic, retain) MNews *news;

- (id)initWithNews:(MNews*)news;

@end
