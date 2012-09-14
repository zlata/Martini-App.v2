//
//  MessagesViewController.m
//  martini
//
//  Created by zlata samarskaya on 28.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessagesViewController.h"
#import "SendMessageViewController.h"

#import "MNetworkManager.h"
#import "MModel.h"
#import "MUser.h"

#import "NewsCell.h"

@implementation MessagesViewController

@synthesize user = user_;

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
        self.notificationName = nUserMessagesLoaded;
    }
    return self;
}

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    self.title = [NSString stringWithFormat:@"переписка с %@", [self.user fullname]];
    [super viewDidLoad];

    [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];
    MMessagesResult *result = [[[MMessagesResult alloc] init] autorelease];
    result.user = self.user;
    [[MNetworkManager sharedInstance] messagesThread:result];
    self.result = result;
}


- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
    [user_ release];
    
    [super dealloc];
}

- (void)markMessagesRead {
    for (MMessage *message in self.tableData) {
        if ([message.status isEqualToString:@"new"]) {
            [[MNetworkManager sharedInstance] readMessage:message];
        }
    }
}

#pragma mark - UITableView datasource

- (UITableViewCell*)tableView:(UITableView*)tableView_ cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    MessageCell *cell  = (MessageCell*)[tableView_ dequeueReusableCellWithIdentifier:@"MessageCell"];
    if (cell == nil) {
        cell = [MessageCell viewFromNib];
    }
    
    MModel *model = [tableData_ objectAtIndex:indexPath.row];
    [cell loadModel:model];
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    SendMessageViewController *controller = [[[SendMessageViewController alloc] init] autorelease];
    controller.user = self.user;
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController presentModalViewController:controller animated:YES];
}

#pragma mark - Notifications

- (void)dataDidLoad:(NSNotification*)notification {
    if (![notification.object isKindOfClass:[MResult class]]) {
        return;
    }
    [super dataDidLoad:notification];
    self.warningView.hidden = [self.result.data count] > 0;
    self.tableView.hidden = [self.result.data count] == 0;
    [self markMessagesRead];
}

@end
