//
//  ArtViewController.m
//  martini
//
//  Created by zlata samarskaya on 24.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ArtViewController.h"

#import "MNetworkManager.h"
#import "MModel.h"
#import "MArtView.h"
#import "MSharingView.h"

@implementation ArtViewController

@synthesize event = event_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithEvent:(MEvent*)event {
    self = [super init];
    if (self) {
        self.event = event;
        self.title = event.title;
        self.notificationName = nEventArtLoaded;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)addTitle {
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(10, 74, 300, 50)] autorelease];
    label.font = [UIFont fontWithName:@"MartiniPro-Bold" size:23];
    label.numberOfLines = 2;
    label.minimumFontSize = 17;
    label.text = [self.title uppercaseString];
    label.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:label]; 
    
    self.viewTitleLabel = label;
    CGSize s = [label.text sizeWithFont:label.font];
    if (s.width < label.frame.size.width) {
        CGRect rect = label.frame;
        rect.size.height = 31;
        label.frame = rect;
    }
    s = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(label.frame.size.width, 1000)];
    int f = label.font.pointSize;
    while (s.height > label.frame.size.height) {
        f--;
        label.font = [UIFont fontWithName:@"MartiniPro-Bold" size:f];      
        s = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(label.frame.size.width, 1000)];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    sharingView.expandButton.enabled = NO;
    [[MNetworkManager sharedInstance] art:self.event];
    CGSize s = [self.event.desc sizeWithFont:descriptionLabel.font 
                           constrainedToSize:CGSizeMake(descriptionLabel.frame.size.width, 1000) 
                               lineBreakMode:UILineBreakModeWordWrap];
    CGRect rect = descriptionLabel.frame;
    rect.size.height = s.height;
    descriptionLabel.frame = rect;
    descriptionLabel.text = self.event.desc;
    
    scroll.contentSize = CGSizeMake(scroll.frame.size.width, rect.size.height + rect.origin.y + 50);
}

- (void)viewDidUnload {
    [scroll release];
    scroll = nil;
    [saveButton release];
    saveButton = nil;
    [descriptionLabel release];
    descriptionLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [scroll release];
    [saveButton release];
    [event_ release];
    [artView release];
    [descriptionLabel release];
    [super dealloc];
}

- (IBAction)save:(id)sender {
    [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];
	UIImage *image = [artView currentImage];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image: didFinishSavingWithError: contextInfo:), nil);
}

- (void)dataDidLoad:(NSNotification *)notification {
    if ([self handleError:notification]) {
        return;
    }
    self.tableData = notification.object;
    if ([self.tableData count] == 0) {
        return;
    }
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:[self.tableData count]];
    for (NSString *str in self.tableData) {
        MPhoto *photo = [[[MPhoto alloc] init] autorelease];
        photo.imageUrl = str;
        [photos addObject:photo];
    }
    if (artView == nil) {
        artView = [[MArtView viewFromNib] retain];
        artView.frame = CGRectMake(0, 0, 320, 255);
    }
    artView.photos = photos;
    [artView.saveButton addTarget:self 
                           action:@selector(save:) 
                 forControlEvents:UIControlEventTouchUpInside];
    
    [scroll addSubview:artView];

    [self.view bringSubviewToFront:sharingView];
    sharingView.expandButton.enabled = YES;
//    [self.tableView reloadData];    
}

#pragma mark - sharing

- (void)postFacebook {
    
	[[MSocialManager sharedInstance] postFb:[kServerUrl stringByAppendingString:[artView currentImageUrl]]
                                      title:self.event.title];
}

- (void)postTwitter {    	
	[[MSocialManager sharedInstance] postTw:[artView currentImageUrl]
                                      title:self.event.title];
}

- (void)postVK {
    [self performSelector:@selector(showActivityIndicator)];
    [[MSocialManager sharedInstance] postVk:self.event.title withCaptcha:NO];
}

- (void) image:(UIImage*)image 
didFinishSavingWithError:(NSError*)error 
   contextInfo:(void *) contextInfo {
    [self performSelector:@selector(hideActivityIndicator) withObject:nil afterDelay:0];
	
	[self showAlertWithTitle:@"" andMessage:@"Изображение сохранено в альбом"];
}

@end
