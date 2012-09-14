//
//  MSharingView.m
//  martini
//
//  Created by zlata samarskaya on 14.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MSharingView.h"

@implementation MSharingView

@synthesize facebookButton, vkButton, twitterButton, expandButton;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (id)viewFromNib {
    NSArray *niblets = [[NSBundle mainBundle] loadNibNamed:@"MSharingView"   
                                                     owner:self
                                                   options:nil];
    
    for (id niblet in niblets) {
        if ([niblet isKindOfClass:[UIView class]]) {
            MSharingView *sharingView = (MSharingView*)niblet;
//            [sharingView initComponents];
            return [[sharingView retain] autorelease];
        }
    }
    
    return nil;    
}

- (IBAction)expand:(id)sender {
    BOOL expand = !expandButton.selected;
    float diff = self.frame.size.height - 42;
    float offsetY = expand ? - diff : diff; 
    expandButton.selected = expand;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    CGRect rect = self.frame;
    rect.origin.y += offsetY;
    self.frame = rect;
    
    [UIView commitAnimations];
}

- (void)dealloc {
    [facebookButton release];
    [twitterButton release];
    [vkButton release];
    [expandButton release];

    [super dealloc];
}
@end
