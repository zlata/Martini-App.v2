//
//  EventViewController.m
//  martini
//
//  Created by zlata samarskaya on 30.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EventViewController.h"
#import "UserProfileViewController.h"
#import "CoctailsViewController.h"
#import "SendMessageViewController.h"
#import "ArtViewController.h"

#import "MNetworkManager.h"

#import "MModel.h"
#import "MUtils.h"
#import "MUser.h"

#import "NewsCell.h"
#import "MGuestCell.h"
#import "MFontLabel.h"
#import "AddPhotoView.h"
#import "MSharingView.h"
#import "LocationViewController.h"

@implementation EventViewController

@synthesize event = event_;
@synthesize coctail = coctail_;
@synthesize guestsResult = guestsResult_;
@synthesize messagesResult = messagesResult_;
@synthesize invitesResult = invitesResult_;
@synthesize titles = titles_;
@synthesize guests = guests_;

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
        self.notificationName = nGuestsLoaded;
        self.title = nil;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(inviteSent:) 
                                                 name:nInviteFinished
                                               object:nil];
    if ([MCurrentUser sharedInstance].event.databaseId == self.event.databaseId) 
        shouldUpdate = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    shouldUpdate = NO;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:nInviteFinished object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mapButton.hidden = !event_.actual;
    sharingView.expandButton.enabled = NO;
    titleLabel.text = self.event.title;
    CGSize s = [self.event.title sizeWithFont:titleLabel.font];
    if (s.width < titleLabel.frame.size.width) {
        [titleLabel sizeToFit];
        
        CGRect rect = deskLabel.frame;
        float offY = rect.origin.y;
        rect.origin.y = titleLabel.frame.size.height + titleLabel.frame.origin.y;
        rect.size.height += offY - rect.origin.y;
        deskLabel.frame = rect;
    }
    
    deskLabel.text = self.event.desc;
    [deskLabel setFont:[UIFont fontWithName:@"MartiniPro-Regular" size:13]];

    imgView.image = [UIImage imageWithContentsOfFile:self.event.imagePath];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(messagesLoaded:) 
                                                 name:nUserMessagesLoaded 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(invitesLoaded:) 
                                                 name:nInvitesLoaded 
                                               object:nil];
    [self.event addObserver:self forKeyPath:@"imagePath" 
                    options:NSKeyValueObservingOptionNew 
                    context:nil];
    self.guestsResult = [[[MGuestsResult alloc] init] autorelease];
    self.guestsResult.event = self.event;
    self.result = self.guestsResult;
    if ([MCurrentUser sharedInstance].event.databaseId == self.event.databaseId) {
        [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];
        
        [[MNetworkManager sharedInstance] guests:self.guestsResult];
    } else {
        sharingView.expandButton.enabled = YES;
        self.tableView.hidden = NO;
    }
}

- (void)viewDidUnload {
    [imgView release];
    imgView = nil;
    [titleLabel release];
    titleLabel = nil;
    [deskLabel release];
    deskLabel = nil;
    [invitesButton release];
    invitesButton = nil;
    [messagesButton release];
    messagesButton = nil;
    [guestsButton release];
    guestsButton = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nUserMessagesLoaded object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nInvitesLoaded object:nil];
    
    [mapButton release];
    mapButton = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    [imgView release];
    [titleLabel release];
    [deskLabel release];
    [invitesButton release];
    [messagesButton release];
    [guestsButton release];
    [guestsResult_ release];
    [invitesResult_ release];
    [messagesResult_ release];
    [titles_ release];
    [guests_ release];
    [coctail_ release];
    
    [mapButton release];
    [self.event removeObserver:self forKeyPath:@"imagePath"];
    [super dealloc];
}

#pragma mark - Messaging

- (void)showMessageView:(MUser*)user {
    SendMessageViewController *controller = [[[SendMessageViewController alloc] init] autorelease];
    controller.user = user;
    controller.event = self.event;
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController presentModalViewController:controller animated:YES];
}

#pragma mark - UITableView datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (activeSegment_ || [self.tableData count] < 4) {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
    NSString *key = [self.titles objectAtIndex:section];
    NSArray *array = [self.guests valueForKey:key];
    return [array count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (activeSegment_ || [self.tableData count] < 4)
        return 1;
    return [self.titles count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (activeSegment_ || [self.tableData count] < 4)
        return nil;
    return self.titles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title 
			   atIndex:(NSInteger)index {

	return index;
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    if (activeSegment_ || [self.tableData count] < 4) return nil;
    return [self.titles objectAtIndex:section];
}

- (UITableViewCell*)tableView:(UITableView*)tableView_ cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    MBaseCell *cell = nil;
    switch (activeSegment_) {
        case 0:
            cell = (MGuestCell*)[tableView_ dequeueReusableCellWithIdentifier:@"MGuestCell"];
            if (cell == nil) {
                cell = [MGuestCell viewFromNib];
            }

            break;
        case 1:
            cell = (MessageCell*)[tableView_ dequeueReusableCellWithIdentifier:@"MessageCell"];
            if (cell == nil) {
                cell = [MessageCell viewFromNib];
            }
            
            break;
        case 2:
            cell = (InviteCell*)[tableView_ dequeueReusableCellWithIdentifier:@"InviteCell"];
            if (cell == nil) {
                cell = [InviteCell viewFromNib];
            }
            
            break;
            
        default:
            break;
    }
    if (activeSegment_ || [self.tableData count] < 4) {
        MModel *model = [tableData_ objectAtIndex:indexPath.row];
        [cell loadModel:model];
        return cell;
    }
    NSString *key = [self.titles objectAtIndex:indexPath.section];
    NSArray *array = [self.guests valueForKey:key];
    MModel *model = [array objectAtIndex:indexPath.row];
    [cell loadModel:model];

    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!activeSegment_) {
        if (self.coctail) {
            MInvite *invite = [[[MInvite alloc] init] autorelease];
            MUser *user = nil;
            if ([self.tableData count] < 4) {
                user = [self.tableData objectAtIndex:indexPath.row];
            } else {
                NSString *key = [self.titles objectAtIndex:indexPath.section];
                NSArray *array = [self.guests valueForKey:key];
                user = [array objectAtIndex:indexPath.row];           
            }
            invite.user = user;
            invite.coctail = self.coctail;
            
            [[MNetworkManager sharedInstance] invite:invite event:self.event];
        
            [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];
            return;
        }
        UserProfileViewController *controller = [[[UserProfileViewController alloc] init] autorelease];
        MUser *user = nil;
        if ([self.tableData count] < 4) {
            user = [self.tableData objectAtIndex:indexPath.row];
        } else {
            NSString *key = [self.titles objectAtIndex:indexPath.section];
            NSArray *array = [self.guests valueForKey:key];
            user = [array objectAtIndex:indexPath.row];           
        }
        controller.user = user;
        controller.event = self.event;
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
    if (activeSegment_ == 2) {
        MInvite *invite = [self.invitesResult.data objectAtIndex:indexPath.row];
        UIAlertView *tmpAlert = [[UIAlertView alloc] 
								 initWithTitle:invite.user.name message:@"" 
                                 delegate:self 
                                 cancelButtonTitle:@"отказаться" 
                                 otherButtonTitles:@"согласиться", nil];
		tmpAlert.tag = indexPath.row;
		[tmpAlert show];
		[tmpAlert release]; // ??
        return;
    }
    MMessage *message = [self.messagesResult.data objectAtIndex:indexPath.row];
//    MUser *user = [self.guestsResult.data objectAtIndex:indexPath.row];
    [self showMessageView:message.user];
//    [self showMessageView:user];
}

#pragma mark - Notifications

- (void)inviteSent:(NSNotification*)notification {
    if ([self handleError:notification]) {
        return;
    }
    [self showAlertWithTitle:@"" andMessage:@"Приглашение отправлено"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:@"imagePath"]) {
        imgView.image = [UIImage imageWithContentsOfFile:self.event.imagePath];
    }
}

- (void)updateGuests {
    if (!shouldUpdate) {
        return;
    }
    self.guestsResult.page = 0;
    NSLog(@"updateGuests");
    [[MNetworkManager sharedInstance] guests:self.guestsResult];    
}

- (void)loadSortedData {
    self.titles = [NSMutableArray array];
    self.guests = [NSDictionary dictionary];
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    for (MUser *user in self.tableData) {
        NSString *str = user.name;
 		NSString *firstLetter = [[str substringToIndex:1] uppercaseString];
        if (![self.titles containsObject:firstLetter]) {
            [self.titles addObject:firstLetter];
        }
        NSMutableArray *array = [data valueForKey:firstLetter];
        if (array == nil) {
            [data setValue:[NSMutableArray array] forKey:firstLetter];
            array = [data valueForKey:firstLetter];
        }
        [array addObject:user];
    }
    self.guests = data;
    self.titles = [[[self.titles sortedArrayUsingSelector:@selector(compare:)] mutableCopy] autorelease];
    
    [data release];
}

- (void)dataDidLoad:(NSNotification*)notification {
    if (![notification.object isKindOfClass:[MGuestsResult class]]) {
        return;
    }
    [self performSelector:@selector(hideActivityIndicator) withObject:nil afterDelay:0];
    
    self.guestsResult = notification.object;
    if (activeSegment_ != 0) {
        return;
    }
    self.result = self.guestsResult;
    NSArray *array = [self.result.data sortedArrayUsingSelector:@selector(compare:)];
    self.tableData = array;
    
    [self loadSortedData];
    
    sharingView.expandButton.enabled = YES;
    self.tableView.hidden = NO;
    [self.tableView reloadData];
    if ([self.tableData count] > 2) {
        CGSize s = self.tableView.contentSize;
        s.height += 50;
        self.tableView.contentSize = s;
        
    }
    [self performSelector:@selector(updateGuests) withObject:nil afterDelay:kUpdateTime];
}

- (void)updateMessages {
    if (!shouldUpdate) {
        return;
    }
    self.messagesResult.page = 0;
    [[MNetworkManager sharedInstance] messages:self.messagesResult];    
}

- (void)markMessagesRead {
    for (MMessage *message in self.messagesResult.data) {
        if ([message.status isEqualToString:@"new"]) {
            [[MNetworkManager sharedInstance] readMessage:message];
        }
    }
}

- (void)messagesLoaded:(NSNotification*)notification {
    if (![notification.object isKindOfClass:[MMessagesResult class]]) {
        return;
    }
    [self performSelector:@selector(hideActivityIndicator) withObject:nil afterDelay:0];
    
    self.messagesResult = notification.object;
    if (activeSegment_ != 1) {
        return;
    }
    self.result = self.messagesResult;
    self.tableData = self.result.data;
    
    [self.tableView reloadData];
    if ([self.tableData count] > 2) {
        CGSize s = self.tableView.contentSize;
        s.height += 50;
        self.tableView.contentSize = s;
        
    }
    [self markMessagesRead];
    [self performSelector:@selector(updateMessages) withObject:nil afterDelay:kUpdateTime];
}

- (void)updateInvites {
    if (!shouldUpdate) {
        return;
    }
    self.invitesResult.page = 0;
    [[MNetworkManager sharedInstance] invites:self.invitesResult];    
}

- (void)invitesLoaded:(NSNotification*)notification {
    if (![notification.object isKindOfClass:[MInvitesResult class]]) {
        return;
    }
    [self performSelector:@selector(hideActivityIndicator) withObject:nil afterDelay:0];
    
    self.invitesResult = notification.object;
    if (activeSegment_ != 2) {
        return;
    }
    self.result = self.invitesResult;
    self.tableData = self.result.data;
    
    [self.tableView reloadData];
    if ([self.tableData count] > 2) {
        CGSize s = self.tableView.contentSize;
        s.height += 50;
        self.tableView.contentSize = s;

    }
    NSMutableString *invateString = [NSMutableString string];
    for (MInvite *invite in self.invitesResult.replies) {
        if ([invite.status isEqualToString:@"new"])
            continue;
         if ([invite.status isEqualToString:@"accepted"]) {
            [self showAlertWithTitle:@"" andMessage:[NSString stringWithFormat:@"Пользователь %@ ответил согласием на Ваше приглашение", invite.user.name]];
        } else {
            [self showAlertWithTitle:@"" andMessage:[NSString stringWithFormat:@"Пользователь %@ ответил отказом на Ваше приглашение", invite.user.name]];
        }
        [invateString appendFormat:@"%i", invite.databaseId];
    }
    [[MNetworkManager sharedInstance] readInvite:invateString];
    [self performSelector:@selector(updateInvites) withObject:nil afterDelay:kUpdateTime];
}

#pragma mark - Actions

- (IBAction)guests:(id)sender {
    if (activeSegment_ == 0) {
        return;
    }
    activeSegment_ = 0;
    guestsButton.selected = YES;
    messagesButton.selected = NO;
    invitesButton.selected = NO;
    
    self.result = guestsResult_;
    self.tableData = self.result.data;
    [self.tableView reloadData];
}

- (IBAction)messages:(id)sender {
    if (activeSegment_ == 1) {
        return;
    }
    activeSegment_ = 1;
    guestsButton.selected = NO;
    messagesButton.selected = YES;
    invitesButton.selected = NO;
    
    if (!shouldUpdate) {
        return;
    }
    if (self.messagesResult == nil) {
        self.messagesResult = [[[MMessagesResult alloc] init] autorelease];
        self.messagesResult.event = self.event; 
        
        [[MNetworkManager sharedInstance] eventMessages:self.messagesResult];
    } 
    self.result = messagesResult_;
    self.tableData = self.result.data;
    [self.tableView reloadData];
}

- (IBAction)invites:(id)sender {
    if (activeSegment_ == 2) {
        return;
    }
    activeSegment_ = 2;
    guestsButton.selected = NO;
    messagesButton.selected = NO;
    invitesButton.selected = YES;
    
    if (!shouldUpdate) {
        return;
    }
    if (self.invitesResult == nil) {
        self.invitesResult = [[[MInvitesResult alloc] init] autorelease];
        self.invitesResult.event = self.event;
         
        [[MNetworkManager sharedInstance] invites:self.invitesResult];
    } 
    self.result = invitesResult_;
    self.tableData = self.result.data;
    [self.tableView reloadData];
}

- (IBAction)gallery:(id)sender {
    ArtViewController *controller = [[[ArtViewController alloc] initWithEvent:self.event] autorelease];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)map:(id)sender {
    LocationViewController *controller = [[[LocationViewController alloc] init] autorelease];
    controller.event = self.event;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    int index = alertView.tag;
    MInvite *invite = [self.invitesResult.data objectAtIndex:index];
    
    NSMutableArray *arr = [NSMutableArray array];
    for (MInvite *inv in self.invitesResult.data) {
        if (![inv isEqual:invite]) {
            [arr addObject:inv];
        }
    }
    self.invitesResult.data = arr;
    self.result = invitesResult_;
    self.tableData = self.result.data;
    [self.tableView reloadData];
    
    if (buttonIndex == alertView.cancelButtonIndex) {
         [[MNetworkManager sharedInstance] declineInvite:invite];
        return;
    } 
        CoctailsViewController *controller = [[[CoctailsViewController alloc] init] autorelease];
        controller.user = invite.user;
        controller.invite = invite;
        [self.navigationController pushViewController:controller animated:YES];
       // [[MNetworkManager sharedInstance] acceptInvite:invite];
    
}

#pragma mark - sharing

- (void)postFacebook {
    
	[[MSocialManager sharedInstance] postFb:[kServerUrl stringByAppendingString:self.event.imageUrl]
                                      title:[NSString stringWithFormat:@"Я на мероприятии %@", self.event.title]];
}

- (void)postTwitter {    	
	[[MSocialManager sharedInstance] postTw:self.event.imagePath
                                      title:[NSString stringWithFormat:@"Я на мероприятии %@", self.event.title]];
}

- (void)postVK {
    [self performSelector:@selector(showActivityIndicator)];
    [[MSocialManager sharedInstance] postVk:[NSString stringWithFormat:@"Я на мероприятии %@", self.event.title] withCaptcha:NO];
}

@end
