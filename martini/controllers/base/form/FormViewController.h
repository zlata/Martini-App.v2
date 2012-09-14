//
//  FormViewController.h
//  Kinopoisk
//
//  Created by zlata samarskaya on 26.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BaseViewController.h"

@class KeyboardToolbar;
@class MAppDelegate;

@interface FormViewController : BaseViewController <UITextViewDelegate, UITextFieldDelegate>{
    IBOutlet UIScrollView *scroll;
    IBOutlet UIView *formView;

    KeyboardToolbar* keyboardToolbar_;
    UIView *currentField;
    NSArray *textFields;
    MAppDelegate *delegate;
}

@property(nonatomic,retain)KeyboardToolbar* keyboardToolbar;
@property(nonatomic,retain)NSArray *textFields;

- (void)didHideKeyboard;
- (void)didShowKeyboard:(UIView*)focusedView;
- (void)keyboardWillHide:(NSNotification*)notification;
- (void)keyboardWillShow:(NSNotification*)notification;
- (void)initTextfields;

@end
