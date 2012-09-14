//
//  FriendsViewController.m
//  martini
//
//  Created by zlata samarskaya on 26.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FriendsViewController.h"
#import "EventsViewController.h"
#import "UserProfileViewController.h"
#import "LocationViewController.h"

#import "MNetworkManager.h"
#import "MGuestCell.h"
#import "MUser.h"
#import "MUtils.h"

@implementation FriendsViewController

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
        self.notificationName = nFollowsLoaded;
        self.title = @"Мои друзыя";
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
    
    CGRect rect = friendsView.frame;
    rect.origin.y = 113;
    friendsView.frame = rect;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([self.tableData count] == 0) {
        [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];
        MFollowsResult *result = [[[MFollowsResult alloc] init] autorelease];
        [[MNetworkManager sharedInstance] follows:result];
        self.result = result;
    }
}

- (void)viewDidUnload {
    [friendsView release];
    friendsView = nil;
    [countLabel release];
    countLabel = nil;
    [noFriendsView release];
    noFriendsView = nil;
    [mapButton release];
    mapButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [friendsView release];
    [countLabel release];
    [noFriendsView release];
    [mapButton release];
    [super dealloc];
}

#pragma mark - UITableView datasource

- (UITableViewCell*)tableView:(UITableView*)tableView_ cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    MGuestCell *cell = (MGuestCell*)[tableView_ dequeueReusableCellWithIdentifier:@"MGuestCell"];
    if (cell == nil) {
        cell = [MGuestCell viewFromNib];
    }
    MUser *user = [tableData_ objectAtIndex:indexPath.row];
    [cell loadModel:user];
    [cell setFollow];
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MUser *user = [tableData_ objectAtIndex:indexPath.row];
    UserProfileViewController *controller = [[[UserProfileViewController alloc] init] autorelease];
    controller.user = user;
    controller.event = [MCurrentUser sharedInstance].event;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Actions

- (IBAction)events:(id)sender {
    EventsViewController *controller = [[[EventsViewController alloc] init] autorelease];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)map:(id)sender {
    LocationViewController *controller = [[[LocationViewController alloc] init] autorelease];
    controller.result = (MFollowsResult*)self.result;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Notifications

- (void)dataDidLoad:(NSNotification*)notification {
    if (![notification.object isKindOfClass:[MResult class]]) {
        return;
    }
    [super dataDidLoad:notification];
    self.warningView.hidden = YES;
    self.tableView.hidden = NO;
   
    if ([self.result.data count] == 0) {
        noFriendsView.hidden = NO;
    } else {
        mapButton.enabled = YES;
        int count = ((MFollowsResult*)self.result).count;
        countLabel.text = [[NSString stringWithFormat:@"%i %@", count, [MUtils friendsStringForValue:count]] uppercaseString];
        [self.view addSubview:friendsView];
    }
}

@end
