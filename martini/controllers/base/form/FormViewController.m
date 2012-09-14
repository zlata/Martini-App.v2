//
//  FormViewController.m
//  Kinopoisk
//
//  Created by zlata samarskaya on 26.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FormViewController.h"
#import "SigninViewController.h"
#import "ProfileViewController.h"

#import "KeyboardToolbar.h"
#import "MAppDelegate.h"

static float keyboardHeight_;

@implementation FormViewController

@synthesize keyboardToolbar = keyboardToolbar_;
@synthesize textFields;

- (void)dealloc {
    [scroll release];
    [formView release];
    [keyboardToolbar_ release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
      
    delegate = appDelegate;
    [self initTextfields];

    if (scroll) {
        [scroll addSubview:formView];
        scroll.contentSize = formView.frame.size;
    }
}

- (void)viewDidUnload {
    [scroll release];
    scroll = nil;
    [formView release];
    formView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self isMemberOfClass:[ProfileViewController class]]) {
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if ([self isMemberOfClass:[ProfileViewController class]]) {
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)initTextfields {    
    NSAssert(0, @"Should be overloaded", @"");    
}

#pragma mark - Keyboard Appearance

- (void)segmentChanged {
    int index = self.keyboardToolbar.segment.selectedSegmentIndex;
    int tag = currentField.tag;
    if (index == 1) {
        tag++;
    } else {
        tag--;
    }
    if (tag >= [textFields count]) {
        return;
    }
    [self.keyboardToolbar segmentStates:tag max:[textFields count]];
    //[self.keyboardToolbar.segment setSelectedSegmentIndex:UISegmentedControlNoSegment];
    UITextField *next = (UITextField*)[textFields objectAtIndex:tag];
    [next becomeFirstResponder];        
}

- (void)keyboardWillShow:(NSNotification*)notification {
    if (self.keyboardToolbar == nil) {
        self.keyboardToolbar = [KeyboardToolbar viewFromNib];
        CGRect frame = self.keyboardToolbar.frame;
        frame.origin.y = self.view.frame.size.height;
        self.keyboardToolbar.frame = frame;
        [self.view addSubview:keyboardToolbar_];
        [self.keyboardToolbar.segment addTarget:self
                                         action:@selector(segmentChanged)
                               forControlEvents:UIControlEventValueChanged];
    }
    int tag = currentField.tag;
    [self.view bringSubviewToFront:self.keyboardToolbar];
    [self.keyboardToolbar segmentStates:tag max:[self.textFields count]];
    self.keyboardToolbar.selectedField = currentField;
    
    BOOL first = keyboardHeight_ == 0;
    
    NSDictionary * userInfo = [notification userInfo];  
    //CGPoint keyboardCenterBeforeAnimation;  
    CGRect keyboardBeforeAnimationFrame;
    [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardBeforeAnimationFrame];  
    keyboardBeforeAnimationFrame = [delegate.window convertRect:keyboardBeforeAnimationFrame toView:self.view];
    CGRect keyboardAfterAnimationFrame;
    [[userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardAfterAnimationFrame];  
    keyboardAfterAnimationFrame = [delegate.window convertRect:keyboardAfterAnimationFrame toView:self.view];
    CGSize keyboardSize = keyboardAfterAnimationFrame.size;  
    keyboardHeight_ = keyboardSize.height;
    
    double animationDuration;  
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];  
    int animationType;  
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationType];  
    
    CGRect frame = self.keyboardToolbar.frame;
    float toolbarHeight =  self.keyboardToolbar.frame.size.height;
    frame.origin.y = keyboardBeforeAnimationFrame.origin.y - toolbarHeight;//frame.size.height - toolbarHeight;
    frame.size.width = keyboardSize.width;
    frame.origin.x = 0;
    self.keyboardToolbar.frame = frame;  
    
    [UIView beginAnimations:nil context:nil];  
    [UIView setAnimationDuration:animationDuration];  
    [UIView setAnimationCurve:animationType];  
    
    frame.origin.y = keyboardAfterAnimationFrame.origin.y - toolbarHeight;//keyboardSize.size.height;
    self.keyboardToolbar.frame = frame;  
    
    [UIView commitAnimations];
    
    if (first) {
        [self didShowKeyboard:currentField];
    }
}

- (void)keyboardWillHide:(NSNotification*)notification {
    NSDictionary * userInfo = [notification userInfo];  
    double animationDuration;  
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];  
    int animationType;  
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationType];  
    CGRect keyboardAfterAnimationFrame;
    [[userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardAfterAnimationFrame];  
    keyboardAfterAnimationFrame = [delegate.window convertRect:keyboardAfterAnimationFrame toView:self.view];
    [UIView beginAnimations:nil context:nil];  
    [UIView setAnimationDuration:animationDuration];  
    [UIView setAnimationCurve:animationType];  
    
    CGRect frame = self.keyboardToolbar.frame;
    frame.origin.y = keyboardAfterAnimationFrame.origin.y;//frame.size.height - toolbarHeight;
    self.keyboardToolbar.frame = frame;  
    
    [UIView commitAnimations]; 
    
    [self textFieldShouldReturn:(UITextField*)currentField];
}

- (void)didShowKeyboard:(UIView*)focusedView {
    CGSize size = formView == nil ? self.view.frame.size : formView.frame.size;
    size.height += keyboardHeight_ + self.keyboardToolbar.frame.size.height;
    scroll.contentSize = size;
    int viewOffset = focusedView.frame.origin.y;
    if ([focusedView isKindOfClass:[UITextField class]]) {
        viewOffset += focusedView.frame.size.height + 10;
    }
    if ([focusedView isKindOfClass:[UITextView class]]) {
        viewOffset += 20;
    }
    UIView *superView = [focusedView superview];
    while (YES) {
        viewOffset += superView.frame.origin.y;
        superView = [superView superview];
        if ([superView isEqual:formView] || [superView isEqual:scroll]) {
             break;
        }
    }
    if (scroll.frame.origin.y > 0) {
        viewOffset += scroll.frame.origin.y;
    }
    int offset =  viewOffset - (self.view.frame.size.height - keyboardHeight_ - self.keyboardToolbar.frame.size.height);
    if(offset > 0) {
        [UIView beginAnimations:@"scroll" context:nil];
        [UIView setAnimationDuration:0.3];
        
        scroll.contentOffset = CGPointMake(0, offset);
        
        [UIView commitAnimations];
    }
}

- (void)didHideKeyboard {
    [UIView beginAnimations:@"scroll" context:nil];
    [UIView setAnimationDuration:0.3];
    
    scroll.contentSize = formView == nil ? self.view.frame.size : formView.frame.size;
    
    [UIView commitAnimations];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
    currentField = textField;
    self.keyboardToolbar.selectedField = currentField;
    // int tag = [self.textFields indexOfObject:currentField];
    int tag = currentField.tag;
    [self.keyboardToolbar segmentStates:tag max:[textFields count]];
    if (keyboardHeight_ != 0) {
        [self didShowKeyboard:currentField];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self didHideKeyboard];
    return YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    currentField = textView;
    self.keyboardToolbar.selectedField = currentField;
    int tag = currentField.tag;
    [self.keyboardToolbar segmentStates:tag max:[textFields count]];
    if (keyboardHeight_ != 0) {
        [self didShowKeyboard:currentField];
    }
    
    return YES;
}

#pragma mark - Rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (self.keyboardToolbar == nil) {
        return;
    }
    // [self textFieldShouldReturn:currentField];
}

- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration {
    CGSize size = self.view.frame.size;
    if (self.keyboardToolbar.frame.origin.y == size.height) {
        return;
    }
    [UIView beginAnimations:nil context:nil];  
    [UIView setAnimationDuration:0.1];  
    
    CGRect frame = self.keyboardToolbar.frame;
    frame.origin.y = size.height;//frame.size.height - toolbarHeight;
    self.keyboardToolbar.frame = frame;  
    
    [UIView commitAnimations]; 
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    keyboardHeight_ = 0;
}

@end
