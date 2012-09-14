//
//  AboutDevelopersViewController.m
//  VogueBrides
//
//  Created by zlata samarskaya on 4/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AboutDevelopersViewController.h"


@implementation AboutDevelopersViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
	
	titleLabel.text = @"О разработчиках";
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"developer.png"]];
	CGRect frame = imageView.frame;
	frame.origin.y = titleLabel.frame.size.height + titleLabel.frame.origin.y;
	imageView.frame = frame;
	[scroll addSubview:imageView];
	
	CGRect rect = contactView.frame;
	rect.origin.y = imageView.frame.size.height + imageView.frame.origin.y;
	contactView.frame = rect;
	
	contactLabel.textColor = blueTextColor;
	urlLabel.textColor = blueTextColor;
	mailLabel.textColor = blueTextColor;
	
	UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openPhoneUrl:)];
	[contactLabel addGestureRecognizer:tgr];
	[tgr release];
	tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openPhoneUrl:)];
	[contactImage addGestureRecognizer:tgr];
	[tgr release];
	tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openUrl:)];
	[urlLabel addGestureRecognizer:tgr];
	[tgr release];
	
	scroll.contentSize = CGSizeMake(scroll.frame.size.width, imageView.frame.size.height + contactView.frame.size.height + 50);
	[imageView release];
}



- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (void)openUrl:(UITapGestureRecognizer*)gesture {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", urlLabel.text]];
	[[UIApplication sharedApplication] openURL:url];
}

- (void)openPhoneUrl:(UITapGestureRecognizer*)gesture {
	NSString *phoneNum = [[contactLabel.text componentsSeparatedByCharactersInSet:
						   [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] 
						  componentsJoinedByString:@""];	
	if ([phoneNum length] == 0) {
		return;
	}
	NSString *phoneNumber = [@"tel://" stringByAppendingString:phoneNum];
	//NSLog(@"%@ %@",phoneNumber, [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:phoneNumber]] ? @"OPEN" : @"NO");
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

@end
