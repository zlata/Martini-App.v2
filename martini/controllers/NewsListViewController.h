//
//  NewsListViewController.h
//  martini
//
//  Created by zlata samarskaya on 13.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BasePagerViewController.h"

@class MNewsCategory;

@interface NewsListViewController : BasePagerViewController {
    MNewsCategory *category_;
}

@property(nonatomic, retain) MNewsCategory *category;

- (id)initWithCategory:(MNewsCategory*)category;

@end
