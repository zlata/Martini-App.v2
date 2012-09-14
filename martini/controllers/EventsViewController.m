//
//  EventsViewController.m
//  martini
//
//  Created by zlata samarskaya on 26.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EventsViewController.h"
#import "EventViewController.h"
#import "LocationViewController.h"
#import "ArtViewController.h"

#import "MNetworkManager.h"
#import "MGuestCell.h"
#import "MModel.h"
#import "MUtils.h"
#import "MUser.h"

@interface EventsViewController (PrivateMethods)
- (void)postFacebook;
- (void)postTwitter;
@end


@implementation EventsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.notificationName = nEventListLoaded;
        self.title = @"мероприятия";
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (id)init {
    self = [super init];
    if (self) {
        self.notificationName = nEventListLoaded;
        self.title = @"мероприятия";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.notificationName = nEventListLoaded;
        self.title = @"мероприятия";
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    shouldUpdate = NO;
    
    [MSocialManager sharedInstance].delegate = nil;
}

- (void)loadData {
    if (!shouldUpdate)
        return;
    [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];
   
    MEventsResult *result = [[[MEventsResult alloc] init] autorelease];
    self.result = result;
    [[MNetworkManager sharedInstance] events:result]; 
}                  

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(checkedIn:) 
                                                 name:nCheckinFinished
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(checkedOut:) 
                                                 name:nCheckoutFinished
                                               object:nil];

    mapButton.hidden = [MCurrentUser sharedInstance].event == nil;
    
    [self.view bringSubviewToFront:mapButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    shouldUpdate = YES;
    [MSocialManager sharedInstance].delegate = self;
    if ([MCurrentUser sharedInstance].sid != nil) {
        if([self.tableData count] == 0)
            [self loadData];
        else {
            [self performSelector:@selector(loadData) withObject:nil afterDelay:300];
        }
    } else {
        [self autorize];
    }
}

- (void)viewDidUnload {
    [mapButton release];
    mapButton = nil;
    [super viewDidUnload];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:nCheckinFinished object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nCheckoutFinished object:nil];
}

#pragma mark - UITableView datasource

- (UITableViewCell*)tableView:(UITableView*)tableView_ cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    MEventCell *cell = (MEventCell*)[tableView_ dequeueReusableCellWithIdentifier:@"MEventCell"];
    if (cell == nil) {
        cell = [MEventCell viewFromNib];
    }
    MEvent *event = [tableData_ objectAtIndex:indexPath.row];
    [cell loadModel:event history:NO];
    [cell.checkinButton addTarget:self 
                           action:@selector(checkin:) 
                 forControlEvents:UIControlEventTouchUpInside];
    [cell.mapButton addTarget:self 
                           action:@selector(map:) 
                 forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MEvent *event = [tableData_ objectAtIndex:indexPath.row];
    if (DEBUG_EVENTS) {
        return 129;
    }
    
    if ((event.distance > 0 && event.distance > maxDistance) || [event past]) {
            return 100;
        
       // return 76;
    }
    return 129;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MEvent *event = [tableData_ objectAtIndex:indexPath.row];
    BaseViewController *controller ;
    if (event.databaseId == [MCurrentUser sharedInstance].event.databaseId) {
        controller = [[[EventViewController alloc] init] autorelease];
        ((EventViewController*)controller).event = event;

    } else {
        controller = [[[ArtViewController alloc] initWithEvent:event] autorelease];
        //controller.event = event;
    }
     [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Actions

- (void)checkin:(id)sender {
    [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];
    MEventCell *cell = (MEventCell*)[[[sender superview] superview] superview];
    MEvent *event = cell.event;
    if ([MCurrentUser sharedInstance].event != nil) {
        [[MNetworkManager sharedInstance] checkout:event];
    } else {
        [[MNetworkManager sharedInstance] checkin:event];
    }
}

- (void)map:(id)sender {
    MEventCell *cell = (MEventCell*)[[[sender superview] superview] superview];
    MEvent *event = cell.event;

    LocationViewController *controller = [[[LocationViewController alloc] init] autorelease];
    controller.event = event;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)eventLocation:(id)sender {
    LocationViewController *controller = [[[LocationViewController alloc] init] autorelease];
    controller.events = self.tableData;//[MCurrentUser sharedInstance].event;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Notifications

- (void)checkedIn:(NSNotification*)notification {
    if ([self handleError:notification]) {
        return;
    }
    MEvent *event = [notification object];
    [MCurrentUser sharedInstance].event = event;
  //  mapButton.hidden = NO;
     [self.tableView reloadData];

    NSString *network = [[MCurrentUser sharedInstance] network];
    if ([network isEqualToString:@"tw"]) {
        [self postTwitter];
    }
    if ([network isEqualToString:@"fb"]) {
        [self postFacebook];
    }
}

- (void)checkedOut:(NSNotification*)notification {
    if ([self handleError:notification]) {
        return;
    }
   // mapButton.hidden = YES;
   [MCurrentUser sharedInstance].event = nil;
    [self.tableView reloadData];
}

- (void)dealloc {
    [mapButton release];
    [super dealloc];
}

- (void)postFacebook {
    CLLocationCoordinate2D coorinate = CLLocationCoordinate2DMake([MCurrentUser sharedInstance].event.lat, [MCurrentUser sharedInstance].event.lon);
	[[MSocialManager sharedInstance] postFb:[MUtils mapUrl:coorinate]
                                      title:[NSString stringWithFormat:@"Я на мероприятии %@", [MCurrentUser sharedInstance].event.title]];
}

- (void)postTwitter {    	
    CLLocationCoordinate2D coorinate = CLLocationCoordinate2DMake([MCurrentUser sharedInstance].event.lat, 
                                                                  [MCurrentUser sharedInstance].event.lon);
    [[MSocialManager sharedInstance] postTw:[MUtils mapUrl:coorinate]
                                      title:[NSString stringWithFormat:@"Я на мероприятии %@", [MCurrentUser sharedInstance].event.title]];
}

- (void)dataDidLoad:(NSNotification *)notification {
    MEventsResult *result = notification.object;
    if (![result isEqual:self.result]) {
        return;
    }
    [super dataDidLoad:notification];
    
    for (MEvent *event in self.tableData) {
        if (event.actual) {
            mapButton.hidden = NO;
            break;
        } 
    }
    
    [self performSelector:@selector(loadData) withObject:nil afterDelay:300];
}

@end
