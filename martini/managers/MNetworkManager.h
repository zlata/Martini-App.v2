//
//  TNetworkManager.h
//  treveller
//
//  Created by zlata on 29.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

typedef enum {kFacebookNetwork = 1, kVKontakteNetwork, kTwitterNetwork} kSocialNetwork;

#import "ASIHTTPRequestDelegate.h"
#import <CoreLocation/CoreLocation.h>

#define kBaseUrl @"http://188.127.226.45/v2/index.php"
#define kSigninMethod @"?c=user&m=auth" 
#define kSigninVKMethod @"?c=user&m=auth_vk"   
#define kSigninFBMethod @"?c=user&m=auth_fb"   
#define kSigninTWMethod @"?c=user&m=auth_tw"   
#define kRegisterVKMethod @"?c=user&m=register_vk"   
#define kRegisterFBMethod @"?c=user&m=register_fb"   
#define kRegisterTWMethod @"?c=user&m=register_tw"   
#define kUserDetailsMethod @"?c=user&m=get_userdata" 
#define kUpdateUserMethod @"?c=user&m=update_userfield" 
#define kUpdateUserImageMethod @"?c=user&m=update_userimage" 
#define kUploadUserImageMethod @"?c=user&m=upload_userpic" 
#define kSearchUserMethod @"?c=user&m=search_user_with_name" 
#define kFollowUserMethod @"?c=user&m=add_follow" 
#define kFollowsMethod @"?c=user&m=get_follows" 
#define kSignupMethod @"?c=user&m=register"   
#define kSignupVKMethod @"?c=user&m=register_vk"   
#define kSignupFBMethod @"?c=user&m=register_fb"   
#define kSignupTWMethod @"?c=user&m=register_tw"   

#define kSendMessageMethod @"?c=user&m=send_message"   
#define kMessagesMethod @"?c=user&m=get_msg_threads"   
#define kEventMessagesMethod @"?c=user&m=get_event_messages"   
#define kUserMessagesMethod @"?c=user&m=get_msg_thread"   
#define kReadMessagesMethod @"?c=user&m=read_msg_thread"   
#define kReadMessageMethod @"?c=user&m=read_message"   
#define kDeleteMessagesMethod @"?c=user&m=delete_msg_thread"   

#define kNewsListMethod @"?c=user&m=get_news"   
#define kNewsMethod @"?c=user&m=news_entry"   
#define kNewsCategoryMethod @"?c=user&m=get_news_cat"   
#define kEventListMethod @"?c=user&m=get_events"   
#define kEventMethod @"?c=user&m=get_event"   
#define kEventCoctailsMethod @"?c=user&m=get_event_cocktails"   
#define kCheckinMethod @"?c=user&m=event_checkin"   
#define kCheckoutMethod @"?c=user&m=event_checkout"   
#define kGuestsMethod @"?c=user&m=event_guests"   
#define kFrendsMethod @"?c=user&m=event_guests"   
#define kAddFrendMethod @"?c=user&m=add_fiend"   
#define kInvitesMethod @"?c=user&m=get_bar_invites"   

#define kInviteMethod @"?c=user&m=bar_invite"   
#define kAcceptInviteMethod @"?c=user&m=bar_invite_accept"   
#define kDeclineInviteMethod @"?c=user&m=bar_invite_decline"   
#define kReadInvitesMethod @"?c=user&m=read_bar_invites"   
#define kEventArtMethod @"?c=user&m=get_event_art"

#define kManualMethod @"?c=user&m=app_meta&type=manual"   
#define kInfoMethod @"?c=user&m=app_meta&type=martini"
#define kRegisterPushMethod @"?c=user&m=register_device"

#define kReadNewsMethod @"?c=user&m=read_news"

//[{"metakey":"manual","metavalue":"\u0442\u0443\u0442 \u043c\u0430\u043d\u0443\u0430\u043b \u043f\u0440\u0438\u043b\u043e\u0436\u0435\u043d\u0438\u044f\n\u0442\u0435\u0441\u0442 \u043d\u043e\u0432\u044b\u0445 \u043f\u043e\u043b\u0435\u0439"}]

@class MUser;
@class MMessage;
@class MNews;
@class MEvent;
@class MInvite;

@class MSearchResult;
@class MThreadResult;
@class MMessagesResult;
@class MNewsResult;
@class MEventsResult;
@class MCoctailsResult;
@class MInvitesResult;
@class MGuestsResult;
@class MFollowsResult;

@interface MNetworkManager : NSObject <ASIHTTPRequestDelegate>{
    int deviceType;
    NSOperationQueue *queue_;
}

@property(nonatomic, retain)NSOperationQueue *queue;

+ (MNetworkManager*)sharedInstance;

- (void)signIn:(NSString*)login password:(NSString*)password;
- (void)signInWithNetwork:(kSocialNetwork)network userId:(NSString*)userId;
- (void)registerWithNetwork:(kSocialNetwork)network userId:(NSString*)userId 
                  userName:(NSString*)userName
                  userPhoto:(NSString*)userPhoto;
- (void)userDetails:(MUser*)user;
- (void)updateUser:(NSDictionary*)data;
- (void)updateUserLocation;
- (void)hideLocation;
- (void)updateUserImage:(UIImage*)image;
- (void)uploadUserImage:(UIImage*)image;
- (void)searchUser:(MSearchResult*)result;
- (void)followUser:(MUser*)user;
- (void)follows:(MFollowsResult*)result;
- (void)signUpWithLogin:(NSString*)login password:(NSString*)password;
- (void)signUpWithNetwork:(kSocialNetwork)network userId:(NSString*)userId;
- (void)sendMessage:(MMessage*)msg recipient:(MUser*)user event:(MEvent*)event;
- (void)eventMessages:(MMessagesResult*)result;
- (void)messages:(MThreadResult*)result;
- (void)messagesThread:(MMessagesResult*)result;
- (void)readMessages:(int)threadId;
- (void)readMessage:(MMessage*)message;
- (void)deleteMessages:(int)threadId;
- (void)news:(MNewsResult*)result;
- (void)newsCategory;
- (void)newsDetails:(MNews*)news;
- (void)readNews:(MNews*)news;
- (void)events:(MEventsResult*)result;
- (void)eventDetails:(MEvent*)event;
- (void)checkin:(MEvent*)event;
- (void)checkout:(MEvent*)event;
- (void)guests:(MGuestsResult*)result;
- (void)coctails:(MEvent*)event;
- (void)invites:(MInvitesResult*)result;
- (void)invite:(MInvite*)invite event:(MEvent*)event;
- (void)acceptInvite:(MInvite*)invite;
- (void)declineInvite:(MInvite*)invite;
- (void)readInvite:(NSString*)invites;
- (NSString*)stringForNetwork:(kSocialNetwork)netw;
- (int)idForNetwork:(NSString*)netw;
- (void)postVKUrl:(NSString*)url message:(NSString*)message;
- (void)art:(MEvent*)event;
- (void)manual;
- (void)info;
- (void)registerPush;
@end

@interface UploadOperation : NSOperation {
    UIImage *image_;
    NSNumber *placeId_;
    BOOL complete;
}

- (id)initWithImage:(UIImage*)image placeId:(NSNumber*)placeId;

@end
