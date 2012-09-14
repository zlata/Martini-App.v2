//
//  CoctailViewController.m
//  martini
//
//  Created by zlata samarskaya on 11.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoctailViewController.h"
#import "EventViewController.h"

#import "MModel.h"
#import "MUser.h"
#import "MNetworkManager.h"

@implementation CoctailViewController

@synthesize coctail = coctail_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoctail:(MCoctail*)coctail {
    self = [super init];
    if (self) {
        self.coctail = coctail;
        self.title = coctail.name;
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
    
    [self.coctail addObserver:self forKeyPath:@"fullImagePath" 
                      options:NSKeyValueObservingOptionNew 
                      context:nil];
  
    imageView_.image = [UIImage imageWithContentsOfFile:self.coctail.fullImagePath];
    
    NSString *str = self.coctail.desc;
    CGSize size = CGSizeMake(receptLabel.frame.size.width, 1000);
    CGSize s = [str sizeWithFont:receptLabel.font 
               constrainedToSize:size 
                   lineBreakMode:UILineBreakModeWordWrap];
    
    CGRect rect = receptLabel.frame;
    rect.size.height = s.height;
    receptLabel.frame = rect;
    
    receptLabel.text = str;
    
    rect = inviteButton.frame;
    rect.origin.y = receptLabel.frame.size.height + receptLabel.frame.origin.y + 10;
    inviteButton.frame = rect;
    
    scroll.contentSize = CGSizeMake(scroll.frame.size.width, rect.size.height + rect.origin.y + 20);
}

- (void)addTitle {
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 31)] autorelease];
    label.font = [UIFont fontWithName:@"MartiniPro-Bold" size:23];
    label.text = [self.title uppercaseString];
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    [scroll addSubview:label]; 
    
    self.viewTitleLabel = label;
}

- (void)viewDidUnload {
    [imageView_ release];
    imageView_ = nil;
    [receptLabel release];
    receptLabel = nil;
    [scroll release];
    scroll = nil;
    [inviteButton release];
    inviteButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [imageView_ release];
    [receptLabel release];
    [coctail_ removeObserver:self forKeyPath:@"fullImagePath"];
    [coctail_ release];
    [scroll release];
    [inviteButton release];
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:@"fullImagePath"]) {
        imageView_.image = [UIImage imageWithContentsOfFile:self.coctail.fullImagePath];
    }
}

- (IBAction)invite:(id)sender {
    if ([MCurrentUser sharedInstance].sid == nil || [MCurrentUser sharedInstance].event == nil) {
        [self showAlertWithTitle:@"" andMessage:@"Вам необхдимо сделать Check-in на одно из мероприятий"];
        return;
    }
    EventViewController *controller = [[[EventViewController alloc] init] autorelease];
    controller.event = [MCurrentUser sharedInstance].event;
    controller.coctail = self.coctail;
    [self.navigationController pushViewController:controller animated:YES];
}


@end
