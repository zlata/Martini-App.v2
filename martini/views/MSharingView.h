//
//  MSharingView.h
//  martini
//
//  Created by zlata samarskaya on 14.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSharingView : UIView {
    
    IBOutlet UIButton *expandButton;
}

@property(nonatomic, retain) IBOutlet UIButton *expandButton;
@property(nonatomic, retain) IBOutlet UIButton *vkButton;
@property(nonatomic, retain) IBOutlet UIButton *twitterButton;
@property(nonatomic, retain) IBOutlet UIButton *facebookButton;

//35
+ (id)viewFromNib;
- (IBAction)expand:(id)sender;

@end
