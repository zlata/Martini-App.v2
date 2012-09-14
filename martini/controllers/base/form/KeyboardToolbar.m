//
//  KeyboardToolbar.m
//  martini
//
//  Created by zlata samarskaya on 27.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "KeyboardToolbar.h"

@implementation KeyboardToolbar

@synthesize segment, selectedField;

+ (id)viewFromNib {
    NSArray *niblets = [[NSBundle mainBundle] loadNibNamed:@"KeyboardToolbar"
                                                     owner:self
                                                   options:nil];
    
    for (id niblet in niblets) {
        if ([niblet isKindOfClass:[UIView class]]) {
            KeyboardToolbar *toolbar = [[niblet retain] autorelease];
            [toolbar.segment setMomentary:YES];
            return toolbar;
        }
    }
    
    return nil;
}

- (IBAction)keyboardDone:(id)sender {
    if ([selectedField isKindOfClass:[UITextField class]]
        || [selectedField isKindOfClass:[UITextView class]]) {
        [selectedField resignFirstResponder];
    }
}

- (void)segmentStates:(int)currentIndex max:(int)maxIndex {
    [segment setEnabled:(currentIndex - 1 >= 0) forSegmentAtIndex:0];
    [segment setEnabled:(currentIndex + 1 < maxIndex) forSegmentAtIndex:1];
}

- (void)dealloc {
    [segment release];
    [super dealloc];
}

@end
