//
//  SignupViewController.m
//  martini
//
//  Created by zlata samarskaya on 02.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EditProfileViewController.h"

#import "AddPhotoView.h"
#import "MAppDelegate.h"

#import "MUser.h"
#import "MUtils.h"

#import "MNetworkManager.h"

@implementation EditProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:@"EditProfileViewController" bundle:nibBundleOrNil];
    if (self) {
        //self.title = @"регистрация";
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
    //    self.title = @"регистрация";
    }
    return self;
}

- (void)initTextfields {
    self.textFields = [NSArray arrayWithObjects:name, surname, nil];//status, nil];
}

#pragma mark - View lifecycle

- (void)toggleViews:(BOOL)unimaged {
//    [formView removeFromSuperview];
    if (unimaged) {
//        [imagedView removeFromSuperview];
        unimagedView.hidden = NO;
        imagedView.hidden = YES;
       formView = unimagedView;
        self.title = @"моя информация";
        [self addTitle];
       // scroll = unimagedScroll;
        name = unimagedName;
        surname = unimagedSurname;
        status = unimagedStatus;
        self.textFields = [NSArray arrayWithObjects:name, surname, nil];//status, nil];
    } else {
        unimagedView.hidden = YES;
        imagedView.hidden = NO;
      // [self.navigationController setNavigationBarHidden:YES];
        formView = imagedView;
        //scroll = imagedScroll;
        name = imagedName;
        surname = imagedSurname;
        status = imagedStatus;
        self.textFields = [NSArray arrayWithObjects: name, surname, nil];
        if (imageView.image == nil) {
            imageView.image = [MCurrentUser sharedInstance].image;
        }
        CGRect rect = scroll.frame;
        rect.origin.y = 73;
        scroll.frame = rect;
        
        rect = formView.frame;
        rect.origin.y = 0;
        formView.frame = rect;
        
    }
    name.text = [MCurrentUser sharedInstance].user.name;
    surname.text = [MCurrentUser sharedInstance].user.surname;
    status.text = [MCurrentUser sharedInstance].user.status;

    //[scroll bringSubviewToFront:formView];
    [self.view bringSubviewToFront:addPhotoView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    formView = unimagedView;
//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//        addPhotoView.makeButton.hidden = YES;
//    }       
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(getDataFinished:) 
                                                 name:nUserDetailsLoaded 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(updateFinished:) 
                                                 name:nUpdateUserFinished 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(updateImageFinished:) 
                                                 name:nUpdateUserImageFinished 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(uploadFinished:) 
                                                 name:nUploadUserImageFinished 
                                               object:nil];
    
    addPhotoView = [[AddPhotoView viewFromNib] retain];
    CGRect rect = addPhotoView.frame;
    rect.origin.y = self.view.frame.size.height;
    addPhotoView.frame = rect;
    
    [addPhotoView.makeButton addTarget:self 
                                   action:@selector(makePhoto) 
                         forControlEvents:UIControlEventTouchUpInside];
    [addPhotoView.alboomButton addTarget:self 
                                  action:@selector(openPhotos) 
                        forControlEvents:UIControlEventTouchUpInside];
    
    [scroll addSubview:imagedView];
    [scroll addSubview:unimagedView];
    
    [self.view addSubview:addPhotoView];

    BOOL unimaged = [MCurrentUser sharedInstance].image == nil;
    [self toggleViews:unimaged];    
}

- (void)viewDidUnload {
    [imagedStatus release];
    imagedStatus = nil;
    [imagedName release];
    imagedName = nil;
    [imagedSurname release];
    imagedSurname = nil;
    [imageView release];
    imageView = nil;
    [unimagedName release];
    unimagedName = nil;
    [unimagedSurname release];
    unimagedSurname = nil;
    [unimagedStatus release];
    unimagedStatus = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nUpdateUserFinished object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nUpdateUserImageFinished object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nUploadUserImageFinished object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nUserDetailsLoaded object:nil];

    [super viewDidUnload];
}

- (void)dealloc {
    [imagedStatus release];
    [imagedName release];
    [imagedSurname release];
    [imageView release];
    [unimagedName release];
    [unimagedSurname release];
    [unimagedStatus release];
    [addPhotoView release];
    
    [super dealloc];
}

#pragma mark Notifications

- (void)getDataFinished:(NSNotification*)notification {
    MUser *user = (MUser*)[notification object];
    if ([MCurrentUser sharedInstance].user.databaseId != user.databaseId) {
        return;
    }
    
    if ([self handleError:notification]) {
        return;
    }
    
    //name.text = user.name;
}

- (void)updateFinished:(NSNotification*)notification {
    if ([self handleError:notification]) {
        return;
    }
    MUser *user = [MCurrentUser sharedInstance].user;
    NSDictionary *data = [notification object];
    NSString *str = [data valueForKey:@"name"];
    if (str) {
        user.name = str;
    }
    str = [data valueForKey:@"surname"];
    if (str) {
        user.surname = str;
    }
    str = [data valueForKey:@"status_msg"];
    if (str) {
        user.status = str;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:nUserDetailsLoaded object:user];
    
    if (!shown) {
        shown = YES;
        [self showAlertWithTitle:@"" andMessage:@"Профиль сохранен"];
    }
}

- (void)updateImageFinished:(NSNotification*)notification {
    if ([self handleError:notification]) {
        return;
    }
    
    [MUtils clearImage:[MCurrentUser sharedInstance].user.imagePath];
    [MCurrentUser sharedInstance].user.imagePath = nil;
    [MCurrentUser sharedInstance].user.imageUrl = nil;
    
    [[MNetworkManager sharedInstance] userDetails:[MCurrentUser sharedInstance].user];
//    [[NSNotificationCenter defaultCenter] postNotificationName:nUserDetailsLoaded 
//                                                        object:[MCurrentUser sharedInstance].user];
    if (!shown) {
        shown = YES;
        [self showAlertWithTitle:@"" andMessage:@"Профиль сохранен"];
    }
}

- (void)uploadFinished:(NSNotification*)notification {
    if ([self handleError:notification]) {
        return;
    }
    if (imageUpdated_) {
        [self updateImageFinished:notification];
        return;
    }
    [MCurrentUser sharedInstance].user.imagePath = nil;
    [[MNetworkManager sharedInstance] userDetails:[MCurrentUser sharedInstance].user];
//    [[NSNotificationCenter defaultCenter] postNotificationName:nUserDetailsLoaded 
//                                                        object:[MCurrentUser sharedInstance].user];
    
    [self toggleViews:NO];
}

//#pragma mark Keyboard
//
//- (void)didShowKeyboard:(UIView*)focused {
//    focusedView = focused;
//    CGSize size = scroll.frame.size;
//    size.height += 210;
//    scroll.contentSize = size;
//    int viewOffset = focusedView.frame.origin.y + focusedView.frame.size.height + scroll.frame.origin.y + 73;
//    int offset = viewOffset - (self.view.frame.size.height - 210);
//    if(offset > 0) {
//        [UIView beginAnimations:@"scroll" context:nil];
//        [UIView setAnimationDuration:0.3];
//        
//        scroll.contentOffset = CGPointMake(0, offset);
//        
//        [UIView commitAnimations];
//    }
//}
//
//- (void)didHideKeyboard {
//    focusedView = nil;
//    [UIView beginAnimations:@"scroll" context:nil];
//    [UIView setAnimationDuration:0.3];
//    
//    scroll.contentSize = scroll.frame.size;
//    
//    [UIView commitAnimations];
//}
//
//#pragma mark UITextViewDelegate
//
//- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
//    [self didShowKeyboard:textView];
//    
//    return YES;   
//}
//
//#pragma mark UITextFieldDelegate
//
//- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
//    [self didShowKeyboard:textField];
//    
//    return YES;
//}
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    [textField resignFirstResponder];
//    int next = textField.tag + 1;
//    UITextField *field = (UITextField*)[scroll viewWithTag:next];
//    if (field) {
//        [field becomeFirstResponder];
//    } else 
//        [self didHideKeyboard];
//    
//    return YES;
//}
//
#pragma mark Actions

- (IBAction)changePhoto:(id)sender {
    [focusedView resignFirstResponder];
    [addPhotoView open];
}

- (IBAction)save:(id)sender {
    shown = NO;
    [focusedView resignFirstResponder];
    [self didHideKeyboard];
    if ([MCurrentUser sharedInstance].image == nil && imageView.image != nil) {
        [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];
        [[MNetworkManager sharedInstance] uploadUserImage:imageView.image];
    } else {
        if (imageView.image && ![[MCurrentUser sharedInstance].image isEqual:imageView.image]) {
            imageUpdated_ = YES;
            [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];
            [[MNetworkManager sharedInstance] uploadUserImage:imageView.image];
        }
    }
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    MUser *user = [MCurrentUser sharedInstance].user;
    if (![name.text isEqualToString:user.name]) {
        [data setValue:name.text forKey:@"name"];
    }
    if ([surname.text length] > 0 && ![surname.text isEqualToString:user.surname]) {
        [data setValue:surname.text forKey:@"surname"];
        [data setValue:name.text forKey:@"name"];
   }
    if ([status.text length] > 0  && ![status.text isEqualToString:user.status]) {
        [data setValue:status.text forKey:@"status_msg"];
    }
    if ([[data allKeys] count] > 0) {
        [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];
        [[MNetworkManager sharedInstance] updateUser:data];
    }
}

- (IBAction)addPhoto:(id)sender {
    [focusedView resignFirstResponder];
    [addPhotoView open];    
}

- (void)makePhoto {
    [self performSelector:@selector(showPicker:) 
               withObject:[NSNumber numberWithInt:UIImagePickerControllerSourceTypeCamera]];

}

- (void)openPhotos {
    [self performSelector:@selector(showPicker:) 
               withObject:[NSNumber numberWithInt:UIImagePickerControllerSourceTypeSavedPhotosAlbum]];
    
}

#pragma mark image picker methods

- (void)showPicker:(NSNumber*)type_ {
    [addPhotoView close:nil];
    
	UIImagePickerController *imgPicker = [[[UIImagePickerController alloc] init] autorelease];
	imgPicker.delegate = self;
	imgPicker.sourceType = [type_ intValue];
	[delegate.tabbarController  presentModalViewController:imgPicker animated:YES];
}

- (void) temporarilyHideStatusBar {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self performSelector:@selector(showStatusBar) withObject:nil afterDelay:0];
}

- (void) showStatusBar {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)imagePickerController:(UIImagePickerController*)picker 
		didFinishPickingMediaWithInfo:(NSDictionary*)info {
	
    UIImage *img = [info valueForKey:UIImagePickerControllerOriginalImage];
    img = [MUtils resizeImage:img maxSide:320];
    imageView.image = img;
//    imageView.backgroundColor = [UIColor blackColor];
 	[delegate.tabbarController dismissModalViewControllerAnimated:NO];
    [self temporarilyHideStatusBar];
    if (imagedView.hidden) {
        [self toggleViews:NO];
    }
   //[self performSelector:@selector(toggleAnimated) withObject:nil afterDelay:0.9];
}//

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker  dismissModalViewControllerAnimated:YES];
}

@end
