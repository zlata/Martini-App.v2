//
//  Constants.h
//  treveller
//
//  Created by zlata samarskaya on 27.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
// 

#define DEBUG_EVENTS 1

#define appDelegate (MAppDelegate*)[UIApplication sharedApplication].delegate
#define numberString(num) [NSString stringWithFormat:@"%@", num]
#define numberFromInt(num) [NSNumber numberWithInt:num]
#define stretchImage(img) [img stretchableImageWithLeftCapWidth:img.size.width / 2 topCapHeight:img.size.height / 2]
#define LS(str) NSLocalizedString(str, @"")
#define kUpdateTime (3 * 60)
#define maxDistance 1000
#define blueTextColor [UIColor colorWithRed:5/255.f green:112/255.f blue:167/255.f alpha:1]
#define grayTextColor [UIColor colorWithRed:64/255.f green:75/255.f blue:92/255.f alpha:1]
#define redTextColor [UIColor colorWithRed:212/255.f green:30/255.f blue:35/255.f alpha:1]

#define kServerUrl @"http://188.127.226.45"

//Notifications
#define nRequestFailed @"requestFailed"
#define nSigninFinished @"nSigninFinished"
#define nUserDetailsLoaded @"nUserDetailsLoaded"
#define nUpdateUserFinished @"nUpdateUserFinished" 
#define nUpdateUserImageFinished @"nUpdateUserImageFinished"
#define nUploadUserImageFinished @"nUploadUserImageFinished"
#define nSearchUserFinished @"nSearchUserFinished"
#define nFollowUserFinished @"nFollowUserFinished"
#define nFollowsLoaded @"nFollowsLoaded"
#define nSignupFinished @"nSignupFinished"
#define nSendMessageFinished @"nSendMessageFinished"
#define nMessagesLoaded @"nUserMessagesLoaded"
#define nUserMessagesLoaded @""
#define nReadMessagesFinished @"nReadMessagesFinished"
#define nReadMessageFinished @"nReadMessageFinished"
#define nDeleteMessagesFinished @"nDeleteMessagesFinished"

#define nNewsCategoryLoaded @"nNewsCategoryLoaded"   
#define nNewsListLoaded @"nNewsListLoaded"   
#define nNewsLoaded @"nNewsLoaded"   
#define nEventListLoaded @"nEventListLoaded"   
#define nEventLoaded @"nEventLoaded"   
#define nEventArtLoaded @"nEventArtLoaded"   
#define nEventCoctailsLoaded @"nEventCoctailsLoaded"   
#define nCheckinFinished @"nCheckinFinished"   
#define nCheckoutFinished @"nCheckoutFinished"   
#define nGuestsLoaded @"nGuestsLoaded"   
#define nFrendsLoaded @"nFrendsLoaded"   
#define nAddFrendFinished @"nAddFrendFinished"   
#define nInvitesLoaded @"nInvitesLoaded"   

#define nInviteFinished @"nInviteFinished"   
#define nAcceptInviteFinished @"nAcceptInviteFinished"   
#define nDeclineInviteFinished @"nDeclineInviteFinished"   
#define nReadInvitesFinished @"nReadInvitesFinished"   
#define nRegisterFinished @"nRegisterFinished"
#define nRegisterFinished @"nRegisterPushFinished"

#define nVKPosted @"nVKPosted"
#define nManualLoaded @"nManualLoaded"
#define nInfoLoaded @"nInfoLoaded"
#define nReadNewsFinished @"nReadNewsFinished"

typedef enum {
 kSigninRequestType = 100,
 kSigninVKRequestType,  
 kSigninFBRequestType,   
 kSigninTWRequestType,  
    kRegisterRequestType,
    kRegisterPushRequestType,
 kUserDetailsRequestType, 
 kUpdateUserRequestType, 
 kUpdateUserImageRequestType,
 kUploadUserImageRequestType,
 kSearchUserRequestType,
 kFollowUserRequestType, 
 kFollowsRequestType,
 kSignupRequestType, 
 kSignupVKRequestType, 
 kSignupFBRequestType,   
 kSignupTWRequestType,  
 kSendMessageRequestType, 
 kMessagesRequestType, 
 kUserMessagesRequestType,
 kReadMessagesRequestType, 
 kReadMessageRequestType, 
 kDeleteMessagesRequestType,
 kNewsListRequestType,   
 kNewsRequestType,  
    kNewsCategoryRequestType,  
 kEventListRequestType,   
 kEventRequestType,  
    kEventArtRequestType,  
 kEventCoctailsRequestType,  
 kCheckinRequestType,
 kCheckoutRequestType, 
 kGuestsRequestType, 
    kFrendsRequestType, 
    kAddFrendRequestType, 
 kInvitesRequestType,
 kInviteRequestType,   
 kAcceptInviteRequestType,   
 kDeclineInviteRequestType,  
 kReadInvitesRequestType,   
    kVKPostRequestType,   
    kManualRequestType,
    kInfoRequestType,
    kReadNewsRequestType
} kRequestType;
