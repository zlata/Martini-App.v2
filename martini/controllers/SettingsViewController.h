//
//  SettingsViewController.h
//  martini
//
//  Created by zlata samarskaya on 03.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseViewController.h"

@interface SettingsViewController : BaseViewController {
    IBOutlet UISwitch *autologinSwitch;
    IBOutlet UISwitch *userHideSwitch;
    IBOutlet UISwitch *locationHideSwitch;
    IBOutlet UIButton *logoutButton;
}

- (IBAction)hideUser:(id)sender;
- (IBAction)hideLocation:(id)sender;
- (IBAction)autologin:(id)sender;
- (IBAction)logout:(id)sender;

@end
