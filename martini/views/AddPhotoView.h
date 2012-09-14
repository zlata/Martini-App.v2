//
//  MSharingView.h
//  martini
//
//  Created by zlata samarskaya on 14.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddPhotoView : UIView {
    
    IBOutlet UIButton *closeButton;
    BOOL visible;
}

@property(nonatomic, retain) IBOutlet UIButton *alboomButton;
@property(nonatomic, retain) IBOutlet UIButton *makeButton;

//35
+ (id)viewFromNib;
- (IBAction)close:(id)sender;
- (void)open;

@end

@interface SendMessageView : UIView {
    BOOL visible;
}

@property (retain, nonatomic) IBOutlet UITextField *theme;
@property (retain, nonatomic) IBOutlet UITextView *message;
@property (retain, nonatomic) IBOutlet UIButton *sendButton;
@property (retain, nonatomic) IBOutlet UIButton *closeButton;

//35
+ (id)viewFromNib;
- (IBAction)close:(id)sender;
- (void)open;

@end
