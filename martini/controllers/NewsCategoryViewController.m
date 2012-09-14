//
//  MoreViewController.m
//  martini
//
//  Created by zlata samarskaya on 03.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewsCategoryViewController.h"
#import "NewsListViewController.h"

#import "MModel.h"
#import "MUser.h"
#import "MUtils.h"
#import "MNetworkManager.h"

#import "MAppDelegate.h"

@implementation NewsCategoryViewController

@synthesize news = news_;
@synthesize event = event_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
       // self.title = @"новости";
        self.notificationName = nNewsCategoryLoaded;
    }
    return self;
}

- (void)didReceiveMemoryWarning  {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadData {
    MEventsResult *result = [[[MEventsResult alloc] init] autorelease];
    self.result = result;
    [[MNetworkManager sharedInstance] events:result]; 

    if (shouldReload) {
        [[MNetworkManager sharedInstance] newsCategory];
    }
}                  

- (void)autorize {
    if ([[MCurrentUser sharedInstance] authorizedLocal]) {
        shouldReload = YES;
        [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];
        [[MNetworkManager sharedInstance] signIn:[MCurrentUser sharedInstance].user.login 
                                        password:[MCurrentUser sharedInstance].password];
        return;
        
    }
    if ([[MCurrentUser sharedInstance] authorizedNetwork]) {
        [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        NSString *network = [def valueForKey:@"network"];
        NSString *userId = [def valueForKey:@"userId"];
        [[MNetworkManager sharedInstance] signInWithNetwork:[[MNetworkManager sharedInstance] idForNetwork:network] 
                                                     userId:userId];
        shouldReload = YES;
        return;
    }
    [[MNetworkManager sharedInstance] newsCategory];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MSocialManager sharedInstance].delegate = self;
    
    if ([MCurrentUser sharedInstance].event != nil) {
        self.event = [MCurrentUser sharedInstance].event;
       // checkInButton.hidden = NO;
        [checkInButton setTitle:[@"Check-Out" uppercaseString] forState:UIControlStateNormal];
    }
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadData) object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [checkInButton.titleLabel setFont:[UIFont fontWithName:@"MartiniPro-Bold" size:15]];
    UIImage *img = stretchImage([UIImage imageNamed:@"red_button.png"]);
    [checkInButton setBackgroundImage:img forState:UIControlStateNormal];

    [self showActivityIndicator];
    //[[MNetworkManager sharedInstance] newsCategory];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(eventsLoaded:) 
                                                 name:nEventListLoaded
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(checkedIn:) 
                                                 name:nCheckinFinished
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(checkedOut:) 
                                                 name:nCheckoutFinished
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newsRead:) name:nReadNewsFinished
                                               object:nil];
}

- (void)viewDidUnload {
    [checkInButton release];
    checkInButton = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:nEventListLoaded object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nCheckinFinished object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nCheckoutFinished object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nReadNewsFinished object:nil];

    [super viewDidUnload];
}

- (void)dealloc {
    [news_ release];
    
    [checkInButton release];
    [super dealloc];
}

#pragma mark - UITableView datasource

- (UIView*)accessoryViewForCategory:(MNewsCategory*)category {
    if (category.count == 0) {
        return [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right_arrow.png"]] autorelease];
    }
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 50)] autorelease];
    label.textColor = category.hasNew ? [UIColor redColor] : [UIColor darkGrayColor];
    label.font = [UIFont fontWithName:@"MartiniPro-Bold" size:18];
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.text = [NSString stringWithFormat:@"%i", category.count];
    
    return label;
}

- (UITableViewCell*)tableView:(UITableView*)tableView_ cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:@"NewsCell"];
    MNewsCategory *category =  [tableData_ objectAtIndex:indexPath.row];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NewsCell"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
      //  cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right_arrow.png"]] autorelease];
    }
    cell.accessoryView = [self accessoryViewForCategory:category];
    cell.textLabel.font = [UIFont fontWithName:@"MartiniPro-Bold" size:18];
    cell.textLabel.text = category.title;
    UIImageView *newView = (UIImageView*)[cell viewWithTag:1111];
    if (category.hasNew) {
        [cell.textLabel sizeToFit];
        if (newView == nil) {
            newView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new_button.png"]] autorelease];
            newView.tag = 1111;
            CGRect frame = newView.frame;
            frame.origin.x = cell.textLabel.frame.origin.x + cell.textLabel.frame.size.width + 10;
            frame.origin.y = cell.textLabel.frame.origin.y + 5;
            newView.frame = frame;
            
            [cell.contentView addSubview:newView];
        }
       newView.hidden = NO;
   } else {
       if (newView) {
           newView.hidden = YES;
       }
   }
    
    return cell;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableData_ count];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MNewsCategory *category = [tableData_ objectAtIndex:indexPath.row];
    NewsListViewController *controller = [[[NewsListViewController alloc] initWithCategory:category] autorelease];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Actions

- (void)checkin:(id)sender {
    if (self.event == nil) {
        MAppDelegate *delegate = appDelegate;
        delegate.tabbarController.selectedIndex = 2;
        return;
    }
    [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];
    MEvent *event = self.event;
    if ([MCurrentUser sharedInstance].event != nil) {
        [[MNetworkManager sharedInstance] checkout:event];
    } else {
        [[MNetworkManager sharedInstance] checkin:event];
    }
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

#pragma mark - Notifications

- (void)dataDidLoad:(NSNotification*)notification {
    if ([self handleError:notification]) {
        return;
    }
    self.tableData = notification.object;
    [self.tableView reloadData];
    self.tableView.hidden = NO;
}

- (void)checkedIn:(NSNotification*)notification {
    if ([self handleError:notification]) {
        return;
    }
    MEvent *event = [notification object];
    [MCurrentUser sharedInstance].event = event;
    
    [checkInButton setTitle:[@"Check-Out" uppercaseString] forState:UIControlStateNormal];
    
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
    
    [MCurrentUser sharedInstance].event = nil;
    [checkInButton setTitle:[@"Check-In" uppercaseString] forState:UIControlStateNormal];
}

- (void)eventsLoaded:(NSNotification *)notification {
 
    MEventsResult *result = notification.object;
    if (![result isEqual:self.result]) {
        return;
    }
    shouldReload = NO;

 //   [super dataDidLoad:notification];
    
    self.result = notification.object;
    if ([MCurrentUser sharedInstance].event != nil) {
        self.event = [MCurrentUser sharedInstance].event;
        //checkInButton.hidden = NO;
        [checkInButton setTitle:[@"Check-Out" uppercaseString] forState:UIControlStateNormal];
        return;
    }
    for (MEvent *event in self.result.data) {
        if (event.actual) {
            self.event = event;
            //checkInButton.hidden = NO;
            [checkInButton setTitle:[@"Check-In" uppercaseString] forState:UIControlStateNormal];
            break;
        } 
    }
//    if (self.event == nil) {
//        checkInButton.hidden = YES;
//    }
    [self performSelector:@selector(loadData) withObject:nil afterDelay:300];
}

- (void)newsRead:(NSNotification*)notification {
    if ([self handleError:notification]) {
        return;
    }

    [[MNetworkManager sharedInstance] newsCategory];
}

@end
