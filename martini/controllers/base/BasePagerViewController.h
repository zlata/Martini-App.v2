//
//  BasePagerViewController.h
//  martini
//
//  Created by zlata samarskaya on 13.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BaseViewController.h"

@class MResult;
@class WarningView;

@interface BasePagerViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate> {
    MResult *result_;
    NSArray *tableData_;
    NSString *notificationName_;
}

@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) MResult *result;
@property(nonatomic, retain) NSArray *tableData;
@property(nonatomic, retain) NSString *notificationName;
@property(retain, nonatomic) WarningView *warningView;

- (void)dataDidLoad:(NSNotification*)notification;

@end
