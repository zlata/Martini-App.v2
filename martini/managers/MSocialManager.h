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
#define kFacebookUsernameSettings @"user.fbname"
#define kFacebookPhotoSettings @"user.fbphoto"

#define kTwitterAuthTocken @"user.twtoken"
#define kTwittwrUsername @"user.twusername"
#define kTwPhotoSettings @"user.twPhoto"

#define kVKAccessUserId @"VKAccessUserId"
#define kVKAccessToken @"VKAccessToken"
#define kVKAccessTokenDate @"VKAccessTokenDate"
#define kVKUsernameSettings @"user.vkname"
#define kVKIdSettings @"user.vkID"
#define kVKPhotoSettings @"user.vkPhoto"

@protocol MSocialManagerDelegate <NSObject>

@optional

-(void)fbDidLogin;
-(void)fbDidNotLogin;
-(void)fbDidLogout;
-(void)fbDidPost;
-(void)fbGotUserData;
-(void)twDidLogin;
-(void)twDidNotLogin;
-(void)twDidLogout;
-(void)twDidPost;
-(void)vkDidLogin;
-(void)vkDidNotLogin;
-(void)vkDidLogout;
-(void)vkDidPost;
-(void)vkDidNotPost:(NSString*)errorMsg;
-(void)vkGotUserData;

@end

@class MImagedModel;

@interface MSocialManager : NSObject <FBRequestDelegate, FBSessionDelegate, FBDialogDelegate, TwitterDialogDelegate, TwitterLoginDialogDelegate, UIWebViewDelegate, UIAlertViewDelegate> {
    Facebook *facebook_;
    id<MSocialManagerDelegate>delegate_;                                       
    OAuth *oAuth_;
    UIWebView *vkWebView_;
    NSMutableDictionary *vkData_;
}

@property (nonatomic, retain) id<MSocialManagerDelegate> delegate;
@property (nonatomic, retain) OAuth *oAuth;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) UIWebView *vkWebView;
@property (nonatomic, retain) NSMutableDictionary *vkData;

+ (MSocialManager *)sharedInstance;

- (void)loginFb;
- (void)getFbData;
- (void)logoutFb;
- (void)postFb:(NSString*)imagePath title:(NSString*)title;

- (void)loginTw;
- (void)logoutTw;
- (void)postTw:(NSString*)imagePath title:(NSString*)title;

- (void)loginVk;
- (void)postVk:(NSString*)message withCaptcha:(BOOL)captcha;
- (void)getVkData;

- (NSString*)facebookToken;
- (void)setFacebookToken:(NSString*)token;
- (NSDate*)facebookExpire;
- (void)setFacebookExpire:(NSDate*)expire;
- (NSString*)fbUsername;
- (NSString*)fbId;
- (void)setFbId:(NSString*)username;
- (void)setFbUsername:(NSString*)username;
- (NSString*)fbPhoto;
- (void)setFbPhoto:(NSString*)username;

- (void)setTwitterAccessToken:(NSString*)data
					 usrename:(NSString*)username;

- (NSString*)twitterAccessToken;
- (NSString*)twitterUserName;
- (void)setTwitterPhoto:(NSString*)name;
- (NSString*)twitterPhoto;

- (NSString*)vkUsername;
- (void)setVkUsername:(NSString*)username;
- (NSString*)vkId;
- (void)setVkId:(NSString*)username;
- (NSString*)vkPhoto;
- (void)setVkPhoto:(NSString*)username;
- (void)logoutVk;

@end

