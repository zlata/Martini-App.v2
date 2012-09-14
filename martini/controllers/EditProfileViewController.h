//
//  SignupViewController.h
//  martini
//
//  Created by zlata samarskaya on 02.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FormViewController.h"

@class AddPhotoView;

@interface EditProfileViewController : FormViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    UITextField *name;
    UITextField *surname;
    UITextView *status;
   
    IBOutlet UIView *unimagedView;
    IBOutlet UIScrollView *unimagedScroll;
    IBOutlet UITextField *unimagedName;
    IBOutlet UITextField *unimagedSurname;
    IBOutlet UITextView *unimagedStatus;
    
    IBOutlet UIView *imagedView;
    IBOutlet UIScrollView *imagedScroll;
    IBOutlet UITextView *imagedStatus;
    IBOutlet UITextField *imagedName;
    IBOutlet UITextField *imagedSurname;
    IBOutlet UIImageView *imageView;
  
    AddPhotoView *addPhotoView;
    
    UIView *focusedView;
    BOOL imageUpdated_;
   // BOOL shown;
}

- (IBAction)changePhoto:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)addPhoto:(id)sender;

@end
