//
//  TJsonHelper.m
//  treveller
//
//  Created by zlata on 29.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MResponceManager.h"
#import "ASIHTTPRequest.h"
#import "JSON.h"
#import "NSString+SBJSON.h"
#import "MLocationManager.h"
#import "MNetworkManager.h"

#import "MUser.h"
#import "MModel.h"

@interface MResponceManager (PrivateMethods)

+ (BOOL)parceErrorsFromString:(NSString*)jsonString error:(NSError**)error;
+ (NSString*)errorDescription:(int)code;
+ (NSArray*)newsCategories:(NSArray*)data;

@end

@implementation MResponceManager

+ (void)didFinishedRequest:(ASIHTTPRequest *)_request {
    NSString *responseString = [_request responseString];
    NSDictionary *info = _request.userInfo;
    int type = [[info valueForKey:@"requestType"] intValue];
       
   // NSLog(@"Responce: %@ request: %i", responseString, type);
    
    NSObject *requestObject = [info valueForKey:@"object"];
       
    NSDictionary *data = [responseString JSONValue];
    NSObject *object = nil;
    NSString *notificationName = nil;
    NSError *error = nil;
    
    [self parceErrorsFromString:responseString error:&error];
    
    switch (type) {
         case kSigninRequestType: {
             [MCurrentUser sharedInstance].sid = [data valueForKey:@"sessID"];
              [[MNetworkManager sharedInstance] registerPush];
            object = requestObject;
             notificationName = nSigninFinished;
         }
            break;
         case kUserDetailsRequestType: {
             MUser *user = (MUser*)requestObject;
             [user detailsFromDictionary:data];
             object = user;
             notificationName = nUserDetailsLoaded;
         }
            break;
        case kUpdateUserRequestType: {
            if (requestObject == nil) {
                return;
            }
            object = requestObject;
            notificationName = nUpdateUserFinished;
        }
           break;
        case kSearchUserRequestType: {
            MSearchResult *result = (MSearchResult*)requestObject;
            [result updateFromDictionary:data];
            object = result;
            notificationName = nSearchUserFinished;
        }
            break;
        case kFollowUserRequestType: {
             notificationName = nFollowUserFinished;
             object = requestObject;
        }
            break;
        case kFollowsRequestType: {
            MResult *result = (MResult*)requestObject;
            [result updateFromDictionary:data];
            object = result;
            notificationName = nFollowsLoaded;
        }
            break;
        case kSignupRequestType: {
            object = requestObject;
            notificationName = nSignupFinished;
        }
            break;
        case kRegisterRequestType: {
            object = requestObject;
            notificationName = nRegisterFinished;
        }
            break;
        case kUpdateUserImageRequestType: {
            notificationName = nUpdateUserImageFinished;
        }
            break;
        case kUploadUserImageRequestType: {
            notificationName = nUploadUserImageFinished;
        }
            break;
        case kSendMessageRequestType: {
            notificationName = nSendMessageFinished;
        }
            break;
        case kMessagesRequestType: {
            MThreadResult *result = (MThreadResult*)requestObject;
            [result updateFromDictionary:data];
            object = result;
            notificationName = nMessagesLoaded;
        }
            break;
        case kUserMessagesRequestType: {
            MMessagesResult *result = (MMessagesResult*)requestObject;
            [result updateFromDictionary:data];
            object = result;
            notificationName = nUserMessagesLoaded;
        }
            break;
        case kReadMessagesRequestType: {
            notificationName = nReadMessagesFinished;
        }
            break;
        case kReadMessageRequestType: {
            notificationName = nReadMessageFinished;
        }
            break;
        case kDeleteMessagesRequestType: {
            notificationName = nDeleteMessagesFinished;
        }
            break;
        case kNewsListRequestType: {
            MNewsResult *result = (MNewsResult*)requestObject;
            [result updateFromDictionary:data];
            object = result;
            notificationName = nNewsListLoaded;
        }
            break;
        case kNewsCategoryRequestType: {
            object = [self newsCategories:[responseString JSONValue]];
            notificationName = nNewsCategoryLoaded;
        }
            break;
       case kNewsRequestType: {
            MNews *news = (MNews*)requestObject;
            [news detailsFromDictionary:data];
            object = news;
            notificationName = nNewsLoaded;
        }
            break;
        case kEventListRequestType: {
            MEventsResult *result = (MEventsResult*)requestObject;
            [result updateFromDictionary:data];
            object = result;
            notificationName = nEventListLoaded;
        }
            break;
        case kEventRequestType: {
            MEvent *event = (MEvent*)requestObject;
            [event detailsFromDictionary:data];
            object = event;
            notificationName = nEventLoaded;
        }
            break;
        case kEventCoctailsRequestType: {
            NSMutableArray *result = [NSMutableArray array];
            NSArray *arr = [data valueForKey:@"cocktails"];
            for (NSDictionary *data in arr) {
                [result addObject:[MCoctail objectFromDictionary:data]];
            }
            object = result;
            notificationName = nEventCoctailsLoaded;
        }
            break;
        case kEventArtRequestType: {
            NSMutableArray *result = [NSMutableArray array];
            NSArray *arr = [data valueForKey:@"art"];
            for (NSString *url in arr) {
                [result addObject:url];
            }
            object = result;
            notificationName = nEventArtLoaded;
        }
            break;
        case kVKPostRequestType: {
            notificationName = nVKPosted;
        }
            break;
        case kCheckinRequestType: {
            notificationName = nCheckinFinished;
           object = requestObject;
        }
            break;
        case kCheckoutRequestType: {
            notificationName = nCheckoutFinished;
        }
            break;
        case kGuestsRequestType: {
            MGuestsResult *result = (MGuestsResult*)requestObject;
            [result updateFromDictionary:data];
            object = result;
            notificationName = nGuestsLoaded;
        }
            break;
       case kInvitesRequestType: {
            MInvitesResult *result = (MInvitesResult*)requestObject;
            [result updateFromDictionary:data];
            object = result;
            notificationName = nInvitesLoaded;
        }
            break;
        case kInviteRequestType: {
            notificationName = nInviteFinished;
        }
            break;
        case kReadNewsRequestType: {
            notificationName = nReadNewsFinished;
        }
            break;
       case kAcceptInviteRequestType: {
            notificationName = nAcceptInviteFinished;
        }
            break;
        case kDeclineInviteRequestType: {
            notificationName = nDeclineInviteFinished;
        }
            break;
        case kReadInvitesRequestType: {
            notificationName = nReadInvitesFinished;
        }
            break;
        case kManualRequestType: {
            notificationName = nManualLoaded;
            if ([data isKindOfClass:[NSArray class]]) {
                data = [(NSArray*)data objectAtIndex:0];
            }
            object = [data valueForKey:@"metaurl"];
        }
            break;
        case kInfoRequestType: {
            notificationName = nInfoLoaded;
            if ([data isKindOfClass:[NSArray class]]) {
                data = [(NSArray*)data objectAtIndex:0];
            }
            object = [data valueForKey:@"metaurl"];
        }
            break;
       default:
            break;
    }    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (error != nil) {
        [userInfo setValue:error forKey:@"error"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName 
                                                        object:object 
                                                      userInfo:userInfo];

}

+ (NSArray*)newsCategories:(NSArray *)data {
    NSMutableArray *result = [NSMutableArray array];
    for (NSDictionary *dictionary in data) {
        MNewsCategory *category = [MNewsCategory objectFromDictionary:dictionary];
        [result addObject:category];
    }
    return result;
}

+ (BOOL)parceErrorsFromString:(NSString*)jsonString error:(NSError**)error {
    //{"errorCode":6004}
	NSDictionary *dictionary = [jsonString JSONValue];
    if(dictionary != nil && [dictionary isKindOfClass:[NSDictionary class]]) {
        int responceCode = [[dictionary valueForKey:@"errorCode"] intValue];
        if (responceCode == 0) {
            return NO;
        }
		NSString *msg = [self errorDescription:responceCode];
        if (msg) {
            if (error != NULL)
                *error = [NSError errorWithDomain:@"" code:responceCode 
                                         userInfo:[NSDictionary 
                                                   dictionaryWithObject:msg 
                                                   forKey:NSLocalizedDescriptionKey]];
               
            return YES;
        }        
	}
    return NO;
}

+ (NSString*)errorDescription:(int)code {
    switch (code) {
        case 5001:
            return @"неправильное количество параметров метода";
            break;
        case 6001:
            return @"несуществующий идентификтор сессии";
            break;
        case 6002:
            return @"неправильный логин и/или пароль";
            break;
        case 6003:
            return @"неправильный адрес электронной почты";
            break;
        case 6004:
            return @"обновление несуществующего поля пользователя";
            break;
        case 6005:
            return @"ссылка на себя. пример: отправка сообщения себе";
            break;
        case 6006:
            return @"пользователь уже добавлен в друзья";
            break;
        case 6007:
            return @"такой пользователь уже зарегистрирован";
            break;
        case 6008:
            return @"аккаунт социальной сети с таким айди еще не зарегистрирован";
            break;
        case 6009:
            return @"аккаунт социальной сети с таким айди уже привязан к аккаунту";
            break;
        case 7001:
            return @"не передан файл";
            break;
        case 7002:
            return @"неправильный формат файла";
            break;
        case 7003:
            return @"слишком большой файл";
            break;
        default:
            return [NSString stringWithFormat:@"unknown error code %i", code];
            break;
    }
    return [NSString stringWithFormat:@"unknown error code %i", code];      
}

@end
