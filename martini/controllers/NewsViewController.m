//
//  NewsViewController.m
//  martini
//
//  Created by zlata samarskaya on 14.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NewsViewController.h"

#import "MSharingView.h"

#import "MNetworkManager.h"
#import "MModel.h"
#import "MUser.h"

@interface NewsViewController (PrivateMethods)
- (void)loadContent;
@end

@implementation NewsViewController

@synthesize news = news_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNews:(MNews *)news {
    self = [super init];
    if (self) {
        self.news = news;
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
    //[[MSocialManager sharedInstance].facebook logout:[MSocialManager sharedInstance]];
    [scroll addSubview:newsView];
    newsTitleLabel.textColor = [UIColor redColor];
     
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataDidLoad:) name:nNewsLoaded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newsRead:) name:nReadNewsFinished
                                               object:nil];
    
    [self.news addObserver:self forKeyPath:@"fullImagePath" options:NSKeyValueObservingOptionNew context:nil];
    [self performSelector:@selector(showActivityIndicator)];
    [self loadContent];
    sharingView.expandButton.enabled = NO;
    if ([MCurrentUser sharedInstance].sid != nil) {
        [[MNetworkManager sharedInstance] readNews:self.news];
    }
    [[MNetworkManager sharedInstance] newsDetails:self.news];
}

- (void)viewDidUnload {
    [scroll release];
    scroll = nil;
    [newsView release];
    newsView = nil;
    [imageView release];
    imageView = nil;
    [newsTitleLabel release];
    newsTitleLabel = nil;
    [textLabel release];
    textLabel = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nNewsLoaded object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nReadNewsFinished object:nil];

    [super viewDidUnload];
}

- (void)enableScroll {
    scroll.contentOffset = CGPointZero;
    scroll.scrollEnabled = YES;  
    textLabel.hidden = NO;
    newsTitleLabel.hidden = NO;
}

- (void)loadContent {
    scroll.scrollEnabled = NO;    
    imageView.image = [UIImage imageWithContentsOfFile:self.news.fullImagePath];
    
    newsTitleLabel.text = self.news.title;
    NSString *str = self.news.text;
    CGSize size = CGSizeMake(textLabel.frame.size.width, 1500);
    CGSize s = [str sizeWithFont:textLabel.font 
               constrainedToSize:size 
                   lineBreakMode:UILineBreakModeWordWrap];
    s.height += 30;
    textLabel.text = str;
    [textLabel setFont:[UIFont fontWithName:@"MartiniPro-Regular" size:16]];
    
    CGRect rect = textLabel.frame;
    rect.size.height = s.height;
    textLabel.frame = rect;
    
    rect = newsView.frame;
    rect.size.height = textLabel.frame.origin.y + textLabel.frame.size.height;
    newsView.frame = rect;
    
    CGSize content = newsView.frame.size;
    content.height += 30;
    scroll.contentSize = content;
    [self performSelector:@selector(enableScroll) withObject:nil afterDelay:0.2];
   
    [self.view bringSubviewToFront:scroll];
    [self.view bringSubviewToFront:sharingView];
}

- (void)dealloc {
    [scroll release];
    [newsView release];
    [imageView release];
    [newsTitleLabel release];
    [textLabel release];
    [self.news removeObserver:self forKeyPath:@"fullImagePath"];
    [news_ release];
   
    [super dealloc];
}

#pragma mark - Notifications

//
- (void)newsRead:(NSNotification*)notification {
    if ([self handleError:notification]) {
        return;
    }
    self.news.isNew = NO;
}

- (void)dataDidLoad:(NSNotification*)notification {
    if (![notification.object isKindOfClass:[MNews class]]) {
        return;
    }
    [self performSelector:@selector(hideActivityIndicator)];
    sharingView.expandButton.enabled = YES;
    self.news = notification.object;
   // [self loadContent];
}

- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"fullImagePath"]) {
        UIImage *img = [UIImage imageWithContentsOfFile:self.news.fullImagePath];
        if (img != nil) {
            imageView.image = img;
        }        
    }
}

#pragma mark - sharing

- (void)postFacebook {
    
	[[MSocialManager sharedInstance] postFb:[kServerUrl stringByAppendingString:self.news.imageUrl]
                                      title:self.news.title];
}

- (void)postTwitter {    	
	[[MSocialManager sharedInstance] postTw:self.news.imagePath
                                      title:self.news.title];
}

- (void)postVK {
    [self performSelector:@selector(showActivityIndicator)];
    [[MSocialManager sharedInstance] postVk:self.news.title withCaptcha:NO];
}

@end
