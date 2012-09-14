//
//  TNetworkManager.m
//  treveller
//
//  Created by zlata on 29.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MNetworkManager.h"

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "MResponceManager.h"
#import "MLocationManager.h"

#import "MUtils.h"
#import "MUser.h"
#import "MModel.h"

@interface MNetworkManager ()

- (void)sendRequest:(ASIFormDataRequest*)_request type:(int)requestType info:(NSMutableDictionary*)info;

@end

static MNetworkManager *sharedInstance = nil;

@implementation MNetworkManager

#pragma mark -
#pragma mark Singletone Implementation

@synthesize queue = queue_;

+ (MNetworkManager*)sharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL] init];
	}
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedInstance] retain];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (oneway void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

#pragma mark -
#pragma mark Initilization

- (void)dealloc {
    
	[super dealloc];
}

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}

- (void)sendRequest:(ASIHTTPRequest*)_request
               type:(int)requestType 
               info:(NSMutableDictionary*)info {
    
    NSLog(@"%@", _request.url.absoluteString);
  
    if (info == nil) {
        info = [NSMutableDictionary dictionary];
    }
    [info setValue:[NSString stringWithFormat:@"%i", requestType] forKey:@"requestType"];
    
    _request.userInfo = info;
	[_request setDelegate:self];
	[_request startAsynchronous];	
}

#pragma mark -
#pragma mark Requests

- (void)signIn:(NSString*)login password:(NSString*)password {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kSigninMethod];
    [urlString appendFormat:@"&login=%@&password=%@", login, password];
    
 	ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    
     [self sendRequest:_request type:kSigninRequestType info:nil];        
}

- (void)userDetails:(MUser*)user {
    //http://{server_url}/index.php?c=user&m=get_userdata&sess_id=d4226aaf072012f1e85be22423d7c738
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kUserDetailsMethod];
    [urlString appendFormat:@"&sess_id=%@", [MCurrentUser sharedInstance].sid];
    if (user.databaseId != 0) {
        [urlString appendFormat:@"&user_id=%i", user.databaseId];
    }
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:user forKey:@"object"];   
 	ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    
    [self sendRequest:_request type:kUserDetailsRequestType info:info];        
}

- (void)updateUser:(NSDictionary*)data {
    //name, email, password, lat, lon, status_msg, private
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kUpdateUserMethod];
    [urlString appendFormat:@"&sess_id=%@", [MCurrentUser sharedInstance].sid];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:data forKey:@"object"];   
 	ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    for (NSString *key in [data allKeys]) {
        if ([key isEqualToString:@"surname"]) 
            continue;
        
        [_request setPostValue:[data valueForKey:key] forKey:key];
    }
    [self sendRequest:_request type:kUpdateUserRequestType info:info];        
}

- (void)updateUserLocation {
    if ([MCurrentUser sharedInstance].sid == nil || [MCurrentUser sharedInstance].hidden) {
        return;
    }
    //name, email, password, lat, lon, status_msg, private
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kUpdateUserMethod];
    [urlString appendFormat:@"&sess_id=%@", [MCurrentUser sharedInstance].sid];
   // NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:data forKey:@"object"];   
 	ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
   // for (NSString *key in [data allKeys]) {
    CLLocationCoordinate2D coordinate = [MLocationManager sharedInstance].currentLocation.coordinate;
    [_request setPostValue:[NSString stringWithFormat:@"%.02f", coordinate.latitude] forKey:@"lat"];
    [_request setPostValue:[NSString stringWithFormat:@"%.02f", coordinate.longitude] forKey:@"lon"];
    //}
    [self sendRequest:_request type:kUpdateUserRequestType info:nil];        
}

- (void)hideLocation {
    if ([MCurrentUser sharedInstance].sid == nil) {
        return;
    }
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kUpdateUserMethod];
    [urlString appendFormat:@"&sess_id=%@", [MCurrentUser sharedInstance].sid];
    // NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:data forKey:@"object"];   
 	ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    // for (NSString *key in [data allKeys]) {
 //   CLLocationCoordinate2D coordinate = [MLocationManager sharedInstance].currentLocation.coordinate;
    [_request setPostValue:@"0" forKey:@"lat"];
    [_request setPostValue:@"0" forKey:@"lon"];
    //}
    [self sendRequest:_request type:kUpdateUserRequestType info:nil];           
}

- (void)updateUserImage:(UIImage*)image {
    NSString *urlString = [NSString stringWithFormat:@"%@%@&sess_id=%@", kBaseUrl, kUpdateUserImageMethod, [MCurrentUser sharedInstance].sid];
	ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    NSData *imageData = UIImageJPEGRepresentation(image, 90);
	[_request setData:imageData 
         withFileName:@"image.jpg"
       andContentType:@"image/jpeg" 
               forKey:@"userpic"];
    [self sendRequest:_request type:kUpdateUserImageRequestType info:nil];        
}

- (void)uploadUserImage:(UIImage*)image {
    NSString *urlString = [NSString stringWithFormat:@"%@%@&sess_id=%@", kBaseUrl, kUploadUserImageMethod, [MCurrentUser sharedInstance].sid];
	ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    NSData *imageData = UIImageJPEGRepresentation(image, 90);
	[_request setData:imageData 
         withFileName:@"image.jpg"
       andContentType:@"image/jpeg" 
               forKey:@"userpic"];
  //  [_request startSynchronous];        
    [self sendRequest:_request type:kUploadUserImageRequestType info:nil];        
}

- (void)searchUser:(MSearchResult*)result {
    //http://{server_url}/index.php?c=user&m=search_user_with_name&sess_id=d4226aaf072012f1e85be22423d7c738
    //Имя для поиска передается в $_POST['query'].
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kSearchUserMethod];
    [urlString appendFormat:@"&sess_id=%@", [MCurrentUser sharedInstance].sid];
    [urlString appendFormat:@"&page=%i", result.page + 1];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:result forKey:@"object"];   
 	
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    [_request setPostValue:result.searchString forKey:@"query"];
    
    [self sendRequest:_request type:kSearchUserRequestType info:info];        
}

- (void)followUser:(MUser*)user {
// http://{server_url}/index.php?c=user&m=add_follow&user_id=1&sess_id=d4226aaf072012f1e85be22423d7c738   
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kFollowUserMethod];
    [urlString appendFormat:@"&sess_id=%@&user_id=%i", [MCurrentUser sharedInstance].sid, user.databaseId];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:user forKey:@"object"];   
 	
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
     
    [self sendRequest:_request type:kFollowUserRequestType info:info];        
}

- (void)follows:(MFollowsResult*)result {
    //http://{server_url}/index.php?c=user&m=get_follows&sess_id=d4226aaf072012f1e85be22423d7c738
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kFollowsMethod];
    [urlString appendFormat:@"&sess_id=%@", [MCurrentUser sharedInstance].sid];
    [urlString appendFormat:@"&page=%i", result.page + 1];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:result forKey:@"object"];   
	
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    
    [self sendRequest:_request type:kFollowsRequestType info:info];        
}

- (void)signUpWithLogin:(NSString*)login password:(NSString*)password {
    //http://{server_url}/index.php?c=user&m=register&login=testuser&password=newPass
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kSignupMethod];
    [urlString appendFormat:@"&login=%@&password=%@", login, password];
    
 	ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    [self sendRequest:_request type:kSignupRequestType info:nil];    
}

- (void)signUpWithNetwork:(kSocialNetwork)network userId:(NSString*)userId {
//    http://{server_url}/index.php?c=user&m=register_vk&user_id=13981739
    NSString *url = nil;
    switch (network) {
        case kFacebookNetwork:
            url = kSignupFBMethod;
            break;
        case kVKontakteNetwork:
            url = kSignupVKMethod;
            break;
        case kTwitterNetwork:
            url = kSignupTWMethod;
            break;
        default:
            break;
    }
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, url];
    [urlString appendFormat:@"&user_id=%@", userId];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%i", network] forKey:@"object"];   
    
 	ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    [self sendRequest:_request type:kSignupRequestType info:info];    
}

- (void)signInWithNetwork:(kSocialNetwork)network userId:(NSString*)userId {
    NSString *url = nil;
    switch (network) {
        case kFacebookNetwork:
            url = kSigninFBMethod;
            break;
        case kVKontakteNetwork:
            url = kSigninVKMethod;
            break;
        case kTwitterNetwork:
            url = kSigninTWMethod;
            break;
        default:
            break;
    }
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, url];
    [urlString appendFormat:@"&user_id=%@", userId];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%i", network] forKey:@"object"];   
    
 	ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    [self sendRequest:_request type:kSigninRequestType info:info];    
}

- (NSString*)stringForNetwork:(kSocialNetwork)netw {
    switch (netw) {
        case kFacebookNetwork:
            return @"fb";
            break;
        case kTwitterNetwork:
            return @"tw";
            break;
        case kVKontakteNetwork:
            return @"vk";
            break;
            
        default:
            break;
    }
    return nil;
}

- (int)idForNetwork:(NSString*)netw {
    if ([@"fb" isEqualToString:netw])
        return kFacebookNetwork;
    if ([@"tw" isEqualToString:netw])
        return kTwitterNetwork;
    if ([@"vk" isEqualToString:netw])
        return kVKontakteNetwork;
   
    return -1;   
}

- (void)registerWithNetwork:(kSocialNetwork)network 
                     userId:(NSString*)userId 
                     userName:(NSString*)userName 
                  userPhoto:(NSString*)userPhoto {
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:userId, @"userId",
                                [NSString stringWithFormat:@"%i", network], @"network",
                                nil];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *networkSet = [def valueForKey:@"network"];
    NSString *userIdSet = [def valueForKey:@"userId"];
    if ([networkSet isEqualToString:[self stringForNetwork:network]]) {
        if ([userId isEqualToString:userIdSet]) {
            [[MNetworkManager sharedInstance] signInWithNetwork:network userId:userId];
            return;
        }
    }
    NSString *url = nil;
    switch (network) {
        case kFacebookNetwork:
            url = kRegisterFBMethod;
            break;
        case kVKontakteNetwork:
            url = kRegisterVKMethod;
            break;
        case kTwitterNetwork:
            url = kRegisterTWMethod;
            break;
        default:
            break;
    }
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, url];
    if ([userPhoto length] > 0) {
        //   [_request setPostValue:userPhoto forKey:@"userpic"];
        [urlString appendFormat:@"&userpic=%@", [userPhoto stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    [urlString appendFormat:@"&user_id=%@", userId];
    [urlString appendFormat:@"&name=%@", [userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
   NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:dictionary forKey:@"object"];   
    
 	ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    [self sendRequest:_request type:kRegisterRequestType info:info];    
}

- (void)sendMessage:(MMessage*)msg recipient:(MUser*)user event:(MEvent*)event {
    //http://{server_url}/index.php?c=user&m=send_message&to_user_id=2&sess_id=d4226aaf072012f1e85be22423d7c738
    //Отправка сообщения пользователю по user_id. Текс сообщения передается в $_POST['text'].
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kSendMessageMethod];
    [urlString appendFormat:@"&sess_id=%@&to_user_id=%i", [MCurrentUser sharedInstance].sid, user.databaseId];
    if (event != nil) {
        [urlString appendFormat:@"&event_id=%i", event.databaseId];
    }
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    [_request setPostValue:msg.message forKey:@"text"];
    
    [self sendRequest:_request type:kSendMessageRequestType info:nil];        
}

//все ветки
- (void)messages:(MThreadResult*)result {
    //http://{server_url}/index.php?c=user&m=get_msg_threads&sess_id=d4226aaf072012f1e85be22423d7c738
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kMessagesMethod];
    [urlString appendFormat:@"&sess_id=%@", [MCurrentUser sharedInstance].sid];
    [urlString appendFormat:@"&page=%i", result.page + 1];
    if (result.from) 
        [urlString appendFormat:@"&from_date=%i", [result.from timeIntervalSince1970]];
    if (result.to)
        [urlString appendFormat:@"&to_date=%i", [result.to timeIntervalSince1970]];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:result forKey:@"object"];   
 	
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    
    [self sendRequest:_request type:kMessagesRequestType info:info];        
}

//сообщения к ивенту
- (void)eventMessages:(MMessagesResult*)result {
    //http://{server_url}/index.php?c=user&m=get_msg_threads&sess_id=d4226aaf072012f1e85be22423d7c738
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kEventMessagesMethod];
    [urlString appendFormat:@"&sess_id=%@", [MCurrentUser sharedInstance].sid];
    [urlString appendFormat:@"&event_id=%i", result.event.databaseId];
    [urlString appendFormat:@"&page=%i", result.page + 1];
    if (result.from) 
        [urlString appendFormat:@"&from_date=%i", [result.from timeIntervalSince1970]];
    if (result.to)
        [urlString appendFormat:@"&to_date=%i", [result.to timeIntervalSince1970]];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:result forKey:@"object"];   
 	
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    
    [self sendRequest:_request type:kUserMessagesRequestType info:info];        
}

//переписка с пользователем
- (void)messagesThread:(MMessagesResult*)result {
    //http://{server_url}/index.php?c=user&m=get_msg_thread&with_user_id=1&sess_id=d4226aaf072012f1e85be22423d7c738
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kUserMessagesMethod];
    [urlString appendFormat:@"&sess_id=%@", [MCurrentUser sharedInstance].sid];
    if (result.thread != nil) {
        [urlString appendFormat:@"&thread_id=%i", result.thread.databaseId];
    }
    if (result.user != nil) {
        [urlString appendFormat:@"&with_user_id=%i", result.user.databaseId];
    }
    [urlString appendFormat:@"&page=%i", result.page + 1];
    if (result.from) 
        [urlString appendFormat:@"&from_date=%i", [result.from timeIntervalSince1970]];
    if (result.to)
        [urlString appendFormat:@"&to_date=%i", [result.to timeIntervalSince1970]];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:result forKey:@"object"];   
 	
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    
    [self sendRequest:_request type:kUserMessagesRequestType info:info];        
}

- (void)readMessages:(int)threadId {
    //http://{server_url}/index.php?c=user&m=read_msg_thread&thread_id=1&sess_id=d4226aaf072012f1e85be22423d7c738

    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kReadMessagesMethod];
    [urlString appendFormat:@"&sess_id=%@", [MCurrentUser sharedInstance].sid];
    [urlString appendFormat:@"&thread_id=%i", threadId];
 	
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    
    [self sendRequest:_request type:kReadMessagesRequestType info:nil];        
}

- (void)readMessage:(MMessage*)message {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kReadMessageMethod];
    [urlString appendFormat:@"&sess_id=%@", [MCurrentUser sharedInstance].sid];
    [urlString appendFormat:@"&msg_id=%i", message.databaseId];
 	
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    
    [self sendRequest:_request type:kReadMessageRequestType info:nil];           
}

- (void)deleteMessages:(int)threadId {
    //http://{server_url}/index.php?c=user&m=delete_msg_thread&thread_id=1&sess_id=d4226aaf072012f1e85be22423d7c738
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kDeleteMessagesMethod];
    [urlString appendFormat:@"&sess_id=%@", [MCurrentUser sharedInstance].sid];
    [urlString appendFormat:@"&thread_id=%i", threadId];
 	
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    
    [self sendRequest:_request type:kDeleteMessagesRequestType info:nil];        
}

- (void)newsCategory {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kNewsCategoryMethod];
    if ([MCurrentUser sharedInstance].sid)
        [urlString appendFormat:@"&sess_id=%@", [MCurrentUser sharedInstance].sid];
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    
    [self sendRequest:_request type:kNewsCategoryRequestType info:nil];             
}

- (void)news:(MNewsResult*)result {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kNewsListMethod];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:result forKey:@"object"];   
    [urlString appendFormat:@"&page=%i", result.page + 1];
    if (result.from) 
        [urlString appendFormat:@"&from_date=%i", [result.from timeIntervalSince1970]];
    if (result.to)
        [urlString appendFormat:@"&to_date=%i", [result.to timeIntervalSince1970]];
	
    if (result.category)
        [urlString appendFormat:@"&cat=%@", result.category.key];

    if ([MCurrentUser sharedInstance].sid)
        [urlString appendFormat:@"&sess_id=%@", [MCurrentUser sharedInstance].sid];
    
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    
    [self sendRequest:_request type:kNewsListRequestType info:info];            
}

- (void)readNews:(MNews*)news {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@&news_id=%i&sess_id=%@", kBaseUrl, kReadNewsMethod, 
                                  news.databaseId, [MCurrentUser sharedInstance].sid];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:news forKey:@"object"];   
 	
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    [self sendRequest:_request type:kReadNewsRequestType info:info];              
}


- (void)newsDetails:(MNews*)news {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@&id=%i", kBaseUrl, kNewsMethod, 
                                  news.databaseId];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:news forKey:@"object"];   
 	
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    [self sendRequest:_request type:kNewsRequestType info:info];              
}

- (void)events:(MEventsResult*)result {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kEventListMethod];
    [urlString appendFormat:@"&sess_id=%@", [MCurrentUser sharedInstance].sid];
    [urlString appendFormat:@"&page=%i", result.page + 1];
    if (result.from) 
        [urlString appendFormat:@"&from_date=%i", [result.from timeIntervalSince1970]];
    if (result.to)
        [urlString appendFormat:@"&to_date=%i", abs([result.to timeIntervalSince1970])];

    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:result forKey:@"object"];   
 	
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
   
    [self sendRequest:_request type:kEventListRequestType info:info];        
   
}

- (void)eventDetails:(MEvent*)event {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@&id=%i", kBaseUrl, kEventMethod, 
                                  event.databaseId];
    [urlString appendFormat:@"&sess_id=%@", [MCurrentUser sharedInstance].sid];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:event forKey:@"object"];   
 	
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    [self sendRequest:_request type:kEventRequestType info:info];              

}

- (void)checkin:(MEvent*)event {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@&id=%i", kBaseUrl, kCheckinMethod, 
                                  event.databaseId];
    [urlString appendFormat:@"&sess_id=%@", [MCurrentUser sharedInstance].sid];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:event forKey:@"object"];   
 	
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    [self sendRequest:_request type:kCheckinRequestType info:info];                  
}

- (void)checkout:(MEvent*)event {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kCheckoutMethod];
    [urlString appendFormat:@"&sess_id=%@", [MCurrentUser sharedInstance].sid];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:event forKey:@"object"];   
 	
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    [self sendRequest:_request type:kCheckoutRequestType info:info];                  
}

- (void)guests:(MGuestsResult*)result {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kGuestsMethod];
    [urlString appendFormat:@"&sess_id=%@", [MCurrentUser sharedInstance].sid];
    [urlString appendFormat:@"&id=%i", result.event.databaseId];
    [urlString appendFormat:@"&page=%i", result.page + 1];
 
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:result forKey:@"object"];   
 	
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    
    [self sendRequest:_request type:kGuestsRequestType info:info];         
}

- (void)coctails:(MEvent*)event {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kEventCoctailsMethod];
    [urlString appendFormat:@"&sess_id=%@", [MCurrentUser sharedInstance].sid];
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    if (event != nil) {
        [urlString appendFormat:@"&event_id=%i", event.databaseId];
        [info setValue:event forKey:@"object"]; 
    } 	
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    [self sendRequest:_request type:kEventCoctailsRequestType info:info];                    
}

- (void)art:(MEvent*)event {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kEventArtMethod];
    [urlString appendFormat:@"&sess_id=%@", [MCurrentUser sharedInstance].sid];
    [urlString appendFormat:@"&id=%i", event.databaseId];
 
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setValue:event forKey:@"object"]; 
     	
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    [self sendRequest:_request type:kEventArtRequestType info:info];                    
}

- (void)invites:(MInvitesResult*)result {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kInvitesMethod];
    [urlString appendFormat:@"&sess_id=%@&event_id=%i", [MCurrentUser sharedInstance].sid, result.event.databaseId];
    [urlString appendFormat:@"&page=%i", result.page + 1];
    if (result.from) 
        [urlString appendFormat:@"&from_date=%i", [result.from timeIntervalSince1970]];
    if (result.to)
        [urlString appendFormat:@"&to_date=%i", [result.to timeIntervalSince1970]];
    if (result.read)
        [urlString appendFormat:@"&show_read=1"];
    if (result.onlyInvites)
        [urlString appendFormat:@"&invites_only=1"];
    if (result.onlyReplies)
        [urlString appendFormat:@"&replies_only=1"];
   
     NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:result forKey:@"object"];   
 	
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    
    [self sendRequest:_request type:kInvitesRequestType info:info];        
}

- (void)invite:(MInvite*)invite event:(MEvent*)event {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kInviteMethod];
    [urlString appendFormat:@"&sess_id=%@&event_id=%i", [MCurrentUser sharedInstance].sid, event.databaseId];
    [urlString appendFormat:@"&user_id=%i&drink_id=%i", invite.user.databaseId, invite.coctail.databaseId];
    
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:invite forKey:@"object"];   
 	
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    
    [self sendRequest:_request type:kInviteRequestType info:info];        

}

- (void)acceptInvite:(MInvite*)invite {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kAcceptInviteMethod];
    [urlString appendFormat:@"&sess_id=%@", [MCurrentUser sharedInstance].sid];
    [urlString appendFormat:@"&invite_id=%i&drink_id=%i", invite.databaseId, invite.coctail.databaseId];
    
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:invite forKey:@"object"];   
 	
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    
    [self sendRequest:_request type:kAcceptInviteRequestType info:info];        
}

- (void)declineInvite:(MInvite*)invite {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kDeclineInviteMethod];
    [urlString appendFormat:@"&sess_id=%@&invite_id=%i", [MCurrentUser sharedInstance].sid, invite.databaseId];
    
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:invite forKey:@"object"];   
 	
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    
    [self sendRequest:_request type:kDeclineInviteRequestType info:info];            
}

- (void)readInvite:(NSString*)invites {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kReadInvitesMethod];
    [urlString appendFormat:@"&sess_id=%@&invite_ids=%@", [MCurrentUser sharedInstance].sid, invites];
     	
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    
    [self sendRequest:_request type:kReadInvitesRequestType info:nil];                
}

- (void)manual {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kManualMethod];
    
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    
    [self sendRequest:_request type:kManualRequestType info:nil];                
  
}

- (void)info {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kInfoMethod];
    
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    
    [self sendRequest:_request type:kInfoRequestType info:nil];                
    
}

- (void)registerPush {
    NSString *token = [MSettings pushToken];
    if ([token length] == 0) {
        return;
    }
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", kBaseUrl, kRegisterPushMethod];
    [urlString appendFormat:@"&token=%@", token];
    if ([MCurrentUser sharedInstance].sid) {
        [urlString appendFormat:@"&sess_id=%@", [MCurrentUser sharedInstance].sid];
    }
    
    ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    
    [self sendRequest:_request type:kRegisterPushRequestType info:nil];                   
}

- (void)postVKUrl:(NSString*)url message:(NSString*)message {
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [_request setPostValue:message forKey:@"message"];
    _request.delegate = self;

    [self sendRequest:_request type:kVKPostRequestType info:nil];                
}

- (void)uploadPhotos:(NSArray*)images 
       descriptionId:(NSNumber*)descriptionId {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    for (UIImage *image in images) {
        UploadOperation *opertion = [[UploadOperation alloc] initWithImage:image 
                                                                   placeId:descriptionId];
        [queue_ addOperation:opertion];
        [opertion release];
    }
    [queue_ waitUntilAllOperationsAreFinished];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:nUpdateUserImageFinished 
                                                        object:nil];
}

//observe quequed operations perfomance
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object 
                        change:(NSDictionary *)change context:(void *)context {
    if (object == queue_&& [keyPath isEqualToString:@"operations"]) {
        if ([queue_.operations count] == 0) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:nUpdateUserImageFinished object:nil];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object 
                               change:change context:context];
    }
}


#pragma mark - Response

- (void)manageRequest:(ASIHTTPRequest *)_request {
    //return;
}

#pragma mark - ASIHTTPRequestDelegate Methods

- (void)requestFinished:(ASIHTTPRequest *)_request {
    
    [MResponceManager didFinishedRequest:_request];
 
    [_request cancel];
	[_request release];
}

- (void)requestFailed:(ASIHTTPRequest *)_request {
	
	NSLog(@"failed %@", _request.url);
    NSDictionary *info = _request.userInfo;
    NSDictionary *userInfo = nil;
    userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[_request error], @"error",
                [info valueForKey:@"requestType"], @"requestType", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:nRequestFailed 
                                                        object:self userInfo:userInfo];
    
	[_request cancel];
	[_request release];
}

@end

@implementation UploadOperation

-(void)dealloc {
    [placeId_ release];
    [image_ release];
    
    [super dealloc];
}

- (id)initWithImage:(UIImage *)image placeId:(NSNumber *)placeId {
    self = [super init];
    if (self) {
        image_ = [image retain];
        placeId_ = [placeId retain];
    }
    return self;
}

- (void)main {
    NSString *urlString = [NSString stringWithFormat:@"%@%@", kBaseUrl, kUpdateUserImageMethod];
	ASIFormDataRequest *_request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]] retain];
    NSData *imageData = UIImageJPEGRepresentation(image_, 90);
	[_request setData:imageData 
         withFileName:@"image.jpg"
       andContentType:@"image/jpeg" 
               forKey:@"image"];
    //_request.delegate = self;
    [_request setPostValue:placeId_ forKey:@"did"];
    [_request startSynchronous];
    NSError *error = [_request error];
    if (!error) {
        NSString *response = [_request responseString];
        NSLog(@"upload request finished: %@", response);
    } else {
        NSLog(@"failed upload request %@", [error localizedDescription]);
    }
 	[_request cancel];
	[_request release];
   
}

@end
