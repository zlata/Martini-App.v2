//
//  KeyboardToolbar.h
//  martini
//
//  Created by zlata samarskaya on 27.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

@interface KeyboardToolbar : UIView {
    UIView *selectedField;
}

@property(nonatomic, assign) UIView *selectedField;
@property (retain, nonatomic) IBOutlet UISegmentedControl *segment;

+ (id)viewFromNib;
- (IBAction)keyboardDone:(id)sender;
- (void)segmentStates:(int)currentIndex max:(int)maxIndex;

@end
