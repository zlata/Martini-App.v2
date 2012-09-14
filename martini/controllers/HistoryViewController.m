//
//  HistoryViewController.m
//  martini
//
//  Created by zlata samarskaya on 27.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HistoryViewController.h"
#import "EventViewController.h"
#import "EventsViewController.m"

#import "MModel.h"
#import "MNetworkManager.h"
#import "MUtils.h"
#import "MGuestCell.h"

@implementation HistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        self.notificationName = nEventListLoaded;
        self.title = @"история мероприятий";
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadData {
    [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];

    MEventsResult *result = [[[MEventsResult alloc] init] autorelease];
    result.to = [MUtils yesterday];
    self.result = result;
    [[MNetworkManager sharedInstance] events:result]; 
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect rect = actionsView.frame;
    rect.origin.y = noActionsView.frame.origin.y;
    actionsView.frame = rect;
    
    self.viewTitleLabel.font = [UIFont fontWithName:self.viewTitleLabel.font.fontName size:22];
    [self loadData];
}

- (void)viewDidUnload {
    [noActionsView release];
    noActionsView = nil;
    [actionsView release];
    actionsView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - UITableView datasource

- (UITableViewCell*)tableView:(UITableView*)tableView_ cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    MEventCell *cell = (MEventCell*)[tableView_ dequeueReusableCellWithIdentifier:@"MEventCell"];
    if (cell == nil) {
        cell = [MEventCell viewFromNib];
    }
    
    MModel *model = [tableData_ objectAtIndex:indexPath.row];
    [cell loadModel:model history:YES];
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MEvent *event = [tableData_ objectAtIndex:indexPath.row];
    EventViewController *controller = [[[EventViewController alloc] init] autorelease];
    controller.event = event;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)dealloc {
    [noActionsView release];
    [actionsView release];
    
    [super dealloc];
}

- (IBAction)events:(id)sender {
    EventsViewController *controller = [[[EventsViewController alloc] init] autorelease];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Notifications

- (void)dataDidLoad:(NSNotification*)notification {
    if (![notification.object isKindOfClass:[MResult class]]) {
        return;
    }
    MEventsResult *res = [notification object];
    if (![res isEqual:self.result]) {
        return;
    }
    [super dataDidLoad:notification];
    self.warningView.hidden = YES;
    self.tableView.hidden = NO;
    
    if ([self.result.data count] == 0) {
        noActionsView.hidden = NO;
    } else {
        [self.view addSubview:actionsView];
    }
}

@end
