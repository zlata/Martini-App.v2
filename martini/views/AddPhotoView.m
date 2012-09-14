//
//  MSharingView.m
//  martini
//
//  Created by zlata samarskaya on 14.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AddPhotoView.h"

@implementation AddPhotoView

@synthesize makeButton, alboomButton;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (id)viewFromNib {
    NSArray *niblets = [[NSBundle mainBundle] loadNibNamed:@"AddPhotoView"   
                                                     owner:self
                                                   options:nil];
    
    for (id niblet in niblets) {
        if ([niblet isKindOfClass:[UIView class]]) {
            AddPhotoView *view = (AddPhotoView*)niblet;
//            [sharingView initComponents];
            if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                view.makeButton.enabled = NO;
            }
            return [[view retain] autorelease];
        }
    }
    
    return nil;    
}

- (IBAction)close:(id)sender {
    if (!visible) {
        return;
    }
    float diff = self.frame.size.height;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    CGRect rect = self.frame;
    rect.origin.y += diff;
    self.frame = rect;
    
    [UIView commitAnimations];
    visible = NO;
}

- (void)open {
    if (visible) {
        return;
    }
    float diff = self.frame.size.height;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    CGRect rect = self.frame;
    rect.origin.y -= diff;
    self.frame = rect;
    
    [UIView commitAnimations];
    visible = YES;
}


- (void)dealloc {
    [makeButton release];
    [alboomButton release];
    [closeButton release];

    [super dealloc];
}
@end

@implementation SendMessageView

@synthesize theme;
@synthesize message;
@synthesize sendButton;
@synthesize closeButton;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (id)viewFromNib {
    NSArray *niblets = [[NSBundle mainBundle] loadNibNamed:@"SendMessageView"   
                                                     owner:self
                                                   options:nil];
    
    for (id niblet in niblets) {
        if ([niblet isKindOfClass:[UIView class]]) {
            SendMessageView *view = (SendMessageView*)niblet;
            //            [sharingView initComponents];
            return [[view retain] autorelease];
        }
    }
    
    return nil;    
}

- (IBAction)close:(id)sender {
    if (!visible) {
        [self open];
        return;
    }
    float diff = self.frame.size.height - 63;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    CGRect rect = self.frame;
    rect.origin.y += diff;
    self.frame = rect;
    
    [UIView commitAnimations];
    visible = NO;
    closeButton.selected = NO;
}

- (void)open {
    if (visible) {
        [self close:nil];
        return;
    }
    message.text = @"";
    theme.text = @"";
    
    float diff = self.frame.size.height - 63;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    CGRect rect = self.frame;
    rect.origin.y -= diff;
    self.frame = rect;
    
    [UIView commitAnimations];
    visible = YES;
    closeButton.selected = YES;
}


- (void)dealloc {
    [closeButton release];
    [theme release];
    [message release];
    [sendButton release];
    [super dealloc];
}
@end

