//
//  SignupViewController.h
//  martini
//
//  Created by zlata samarskaya on 02.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FormViewController.h"

@interface SignupViewController : FormViewController {
    
    IBOutlet UITextField *email;
    IBOutlet UITextField *pass;
    IBOutlet UITextField *passRemind;
    
  //  UITextField *focusedField;
}
- (IBAction)signup:(id)sender;

@end
