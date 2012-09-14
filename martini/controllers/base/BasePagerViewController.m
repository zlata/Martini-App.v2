//
//  BasePagerViewController.m
//  martini
//
//  Created by zlata samarskaya on 13.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BasePagerViewController.h"

#import "MModel.h"
#import "MFontLabel.h"
#import "MNetworkManager.h"

@implementation BasePagerViewController

@synthesize tableView;
@synthesize result = result_;
@synthesize notificationName = notificationName_;
@synthesize tableData = tableData_;
@synthesize warningView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.warningView = [WarningView viewFromNib];
    self.warningView.frame = self.tableView.frame;
    [self.view insertSubview:self.warningView belowSubview:tableView];
    self.warningView.hidden = YES;
    self.tableView.hidden = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataDidLoad:) name:self.notificationName object:nil];
}


- (void)viewDidUnload {
    [super viewDidUnload];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:self.notificationName object:nil];
}

- (void)dealloc {
    [tableView release];
    [result_ release];
    [tableData_ release];
    
    [super dealloc];
}

#pragma mark - UITableView datasource

- (int)tableView:(UITableView *)tableView_ numberOfRowsInSection:(NSInteger)section {
    return [tableData_ count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView_ cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
         cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                       reuseIdentifier:@"cell"] autorelease];
    }
    cell.textLabel.text = @"Overload this...";
    return cell;
}

#pragma mark - Notifications

- (void)dataDidLoad:(NSNotification*)notification {
    if (![notification.object isKindOfClass:[MResult class]]) {
        return;
    }
    [self performSelector:@selector(hideActivityIndicator) withObject:nil afterDelay:0];
   
    self.result = notification.object;
    self.tableData = self.result.data;
    self.warningView.hidden = [self.tableData count] > 0;
    self.tableView.hidden = [self.tableData count] == 0;
  
    [tableView reloadData];
}

@end
