//
//  BaseSharingViewController.h
//  martini
//
//  Created by zlata samarskaya on 14.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BasePagerViewController.h"
#import "MSocialManager.h"

@class MSharingView;

@interface BaseSharingViewController : BasePagerViewController <MSocialManagerDelegate>{
    MSharingView *sharingView;
}

- (void)postFacebook;
- (void)postTwitter;
- (void)postVK;

@end
