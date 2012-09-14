//
//  SignupViewController.m
//  martini
//
//  Created by zlata samarskaya on 02.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SignupViewController.h"

#import "MUser.h"
#import "MUtils.h"

#import "MNetworkManager.h"

@implementation SignupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:@"SignupViewController" bundle:nibBundleOrNil];
    if (self) {
        self.title = @"регистрация";
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = @"регистрация";
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(signupFinished:) 
                                                 name:nSignupFinished 
                                               object:nil];
}

- (void)initTextfields {
    self.textFields = [NSArray arrayWithObjects:email, pass, passRemind, nil];    
}

- (void)viewDidUnload {
    [email release];
    email = nil;
    [pass release];
    pass = nil;
    [passRemind release];
    passRemind = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:nSignupFinished object:nil];

    [super viewDidUnload];
}

- (void)dealloc {
    [email release];
    [pass release];
    [passRemind release];
 
    [super dealloc];
}

- (BOOL)valid {
    if ([email.text length] == 0) {
        [self showAlertWithTitle:@"" andMessage:@"Введите логин, пожалуйста"];
        return NO;
    }  
    if ([email.text length] < 5) {
        [self showAlertWithTitle:@"" andMessage:@"Логин должен содержать не менее 5 символов"];
        return NO;
    }  
    if (![MUtils alphaNumericValid:email.text minLength:1 maxLength:15]) {
        [self showAlertWithTitle:@"" andMessage:@"Логин может содержать только символы 0-9a-zA-Z_"];
        return NO;
    }  
    if ([pass.text length] == 0) {
        [self showAlertWithTitle:@"" andMessage:@"Введите пароль, пожалуйста"];
        return NO;
    }  
    if (![MUtils alphaNumericValid:pass.text minLength:1 maxLength:15]) {
        [self showAlertWithTitle:@"" andMessage:@"Пароль может содержать только символы 0-9a-zA-Z_"];
        return NO;
    }  
    if (![pass.text isEqualToString:passRemind.text]) {
        [self showAlertWithTitle:@"" andMessage:@"Повтор пароля введен неправильно"];
        return NO;
    }  
    return YES;
}

#pragma mark Notifications

- (void)signupFinished:(NSNotification*)notification {
    if ([super handleError:notification]) {
        return;
    }
    [MCurrentUser sharedInstance].user.email = email.text;
    [MCurrentUser sharedInstance].user.login = email.text;
    [MCurrentUser sharedInstance].user.name = email.text;
    [MCurrentUser sharedInstance].password = pass.text;
    [[MCurrentUser sharedInstance] saveUserData];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Actions

- (IBAction)signup:(id)sender {
    if(![self valid]) {
        return;
    }
    [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];
    
    [[MNetworkManager sharedInstance] signUpWithLogin:email.text password:pass.text];
}

/*
- (void)didShowKeyboard:(UIView*)focusedView {
    CGSize size = scroll.frame.size;
    size.height += 210;
    scroll.contentSize = size;
    int viewOffset = focusedView.frame.origin.y + focusedView.frame.size.height + scroll.frame.origin.y;
    int offset = viewOffset - (self.view.frame.size.height - 210);
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
    
    scroll.contentSize = scroll.frame.size;
    
    [UIView commitAnimations];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
    [self didShowKeyboard:textField];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    int next = textField.tag + 1;
    UITextField *field = [scroll viewWithTag:next];
    if (field) {
        [field becomeFirstResponder];
    } else 
        [self didHideKeyboard];
    
    return YES;
}*/

@end
