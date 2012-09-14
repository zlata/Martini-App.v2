//
//  CoctailsViewController.m
//  martini
//
//  Created by zlata samarskaya on 05.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoctailsViewController.h"
#import "CoctailViewController.h"

#import "MModel.h"
#import "MUser.h"
#import "MNetworkManager.h"

#import "NewsCell.h"

@implementation CoctailsViewController

@synthesize user = user_;
@synthesize event = event_;
@synthesize invite = invite_;

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

- (id)init {
    self = [super init];
    if (self) {
        self.notificationName = nEventCoctailsLoaded;
        self.title = nil;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.notificationName = nEventCoctailsLoaded;
        self.title = nil;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    if ([self.tableData count] == 0) {
        if ([MCurrentUser sharedInstance].sid != nil) {
           [self loadData];
        } else {
            [self autorize];
        }
 //   }
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(inviteSent:) 
                                                 name:nInviteFinished
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];    

    [[NSNotificationCenter defaultCenter] removeObserver:self name:nInviteFinished object:nil];
}

- (void)loadData {
    [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];
    [[MNetworkManager sharedInstance] coctails:self.event]; 
}

- (void)viewDidLoad {
    if (self.invite != nil || self.user != nil) { 
        self.title = @"вьбраты коктейлы";
    } else {
        self.tableView.frame = CGRectMake(0, 73, self.view.frame.size.width, self.view.frame.size.height - 73);
    }
    
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(inviteAccepted:) 
                                                 name:nAcceptInviteFinished
                                               object:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:nAcceptInviteFinished object:nil];
}

#pragma mark - UITableView datasource

- (UITableViewCell*)tableView:(UITableView*)tableView_ cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    NewsCell *cell = (NewsCell*)[tableView_ dequeueReusableCellWithIdentifier:@"NewsCell"];
    if (cell == nil) {
        cell = [NewsCell viewFromNib];
    }

    MModel *model = [self.tableData objectAtIndex:indexPath.row];
    [cell loadModel:model];

    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MCoctail *coctail = [tableData_ objectAtIndex:indexPath.row];
    if (self.invite == nil && self.user == nil) {
        CoctailViewController *controller = [[[CoctailViewController alloc] initWithCoctail:coctail] autorelease];
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
    if (self.invite == nil) {
        self.invite = [[[MInvite alloc] init] autorelease];
        self.invite.user = self.user;
        self.invite.coctail = coctail;
        
        [[MNetworkManager sharedInstance] invite:self.invite event:self.event];
    } else {
        self.invite.coctail = coctail;        
        [[MNetworkManager sharedInstance] acceptInvite:self.invite];        
    }
    
    [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];
}

#pragma mark - Notifications

- (void)dataDidLoad:(NSNotification*)notification {
    if ([self handleError:notification]) {
        return;
    }
    self.tableData = notification.object;
    self.warningView.hidden = [self.tableData count] > 0;
    self.tableView.hidden = [self.tableData count] == 0;
    [self.tableView reloadData];
}

- (void)inviteSent:(NSNotification*)notification {
    if ([self handleError:notification]) {
        return;
    }
   // [self showAlertWithTitle:@"" andMessage:@"Приглашение отправлено"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)inviteAccepted:(NSNotification*)notification {
    if ([self handleError:notification]) {
        return;
    }
    // [self showAlertWithTitle:@"" andMessage:@"Приглашение отправлено"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    [event_ release];
    [user_ release];
    [invite_ release];
    
    [super dealloc];
}

@end
