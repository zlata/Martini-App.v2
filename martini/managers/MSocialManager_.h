//
//  TFacebookManager.h
//  treveller
//
//  Created by Oleg Lobachev on 05.10.10.
//  Copyright 2010 aironik. All rights reserved.
//

#import "FBConnect.h"
#import "TwitterLoginPopupDelegate.h"
#import "TwitterLoginUiFeedback.h"
#import "OAuth.h"
#import "OAuth+UserDefaults.h"
#import "OAuthConsumerCredentials.h"
#import "TwitterDialog.h"

#define kTwitterApiKey @"shKbRL9FzxIxWOdzBcfpA"
#define kTwitterApiSecret @"kmQl2J61epCSd4UK9uqn6Hs6EVeCYx3pM8uRllLlaNM"

#define kFacebookAppID @"175810705813249"
#define kVkontakteAppID @"2645358"

#define kFacebookIdSettings @"user.fid"
#define kFacebookTokenSettings @"user.ftoken"
#define kFacebookExpireSettings @"user.fexpire"

#define kTwitterAuthTocken @"user.twtoken"
#define kTwittwrUsername @"user.twusername"

#define kVKAccessUserId @"VKAccessUserId"
#define kVKAccessToken @"VKAccessToken"
#define kVKAccessTokenDate @"VKAccessTokenDate"

@protocol MSocialManagerDelegate <NSObject>

@optional

-(void)fbDidLogin;
-(void)fbDidNotLogin;
-(void)fbDidLogout;
-(void)fbDidPost;
-(void)twDidLogin;
-(void)twDidNotLogin;
-(void)twDidLogout;
-(void)twDidPost;
-(void)vkDidLogin;
-(void)vkDidNotLogin;
-(void)vkDidLogout;
-(void)vkDidPost;

@end

@class MImagedModel;

@interface MSocialManager : NSObject <FBRequestDelegate, FBSessionDelegate, FBDialogDelegate, TwitterDialogDelegate, TwitterLoginDialogDelegate, UIWebViewDelegate> {
    Facebook *facebook_;
    id<MSocialManagerDelegate>delegate_;                                       
    OAuth *oAuth_;
    UIWebView *vkWebView_;
}

@property (nonatomic, retain) id<MSocialManagerDelegate> delegate;
@property (nonatomic, retain) OAuth *oAuth;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) UIWebView *vkWebView;

+ (MSocialManager *)sharedInstance;
- (void)loginFb;
- (void)getFbData;
- (void)logoutFb;
- (void)postFb:(NSString*)imagePath title:(NSString*)title;
- (void)loginTw;
- (void)logoutTw;
- (void)postTw:(NSString*)imagePath title:(NSString*)title;
- (void)loginVk;
- (void)postVk:(NSString*)message;

- (NSString*)facebookToken;
- (void)setFacebookToken:(NSString*)token;
- (NSDate*)facebookExpire;
- (void)setFacebookExpire:(NSDate*)expire;
- (void)setTwitterAccessToken:(NSString*)data
					 usrename:(NSString*)username;

- (NSString*)twitterAccessToken;
- (NSString*)twitterUserName;

@end

