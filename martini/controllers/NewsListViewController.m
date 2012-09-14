//
//  NewsListViewController.m
//  martini
//
//  Created by zlata samarskaya on 13.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NewsListViewController.h"
#import "NewsViewController.h"

#import "MModel.h"
#import "MUser.h"
#import "NewsCell.h"
#import "MNetworkManager.h"

@implementation NewsListViewController

@synthesize category = category_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.notificationName = nNewsListLoaded;
    }
    return self;
}

- (id)initWithCategory:(MNewsCategory*)category {
    self = [super init];
    if (self) {
        self.notificationName = nNewsListLoaded;
        self.category = category;
       // self.news = news;
        self.title = category.title;
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
        self.notificationName = nNewsListLoaded;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.notificationName = nNewsListLoaded;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
     
    self.tableView.hidden = YES;
    [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];
    MNewsResult *result = [[[MNewsResult alloc] init] autorelease];
    result.category = self.category;
    [[MNetworkManager sharedInstance] news:result];
    self.result = result;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newsRead:) name:nReadNewsFinished
                                               object:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:nReadNewsFinished object:nil];
}

#pragma mark - UITableView datasource

- (UITableViewCell*)tableView:(UITableView*)tableView_ cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    NewsCell *cell = (NewsCell*)[tableView_ dequeueReusableCellWithIdentifier:@"NewsCell"];
    if (cell == nil) {
        cell = [NewsCell viewFromNib];
    }
    MNews *news = [tableData_ objectAtIndex:indexPath.row];
    [cell loadModel:news];
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MNews *news = [tableData_ objectAtIndex:indexPath.row];
    NewsViewController *controller = [[[NewsViewController alloc] initWithNews:news] autorelease];
    
    [self.navigationController pushViewController:controller animated:YES];
}


- (void)newsRead:(NSNotification*)notification {
    if ([self handleError:notification]) {
        return;
    }
    [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:2];
}

- (void)dataDidLoad:(NSNotification*)notification {
    if ([self handleError:notification]) {
        return;
    }
    self.result = notification.object;
    self.tableData = self.result.data;
    self.warningView.hidden = [self.tableData count] > 0;
    self.tableView.hidden = [self.tableData count] == 0;
    [self.tableView reloadData];
    
}

- (void)dealloc {
    [category_ release];
    
    [super dealloc];
}

@end
