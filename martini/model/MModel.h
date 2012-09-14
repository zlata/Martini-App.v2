//
//  MModel.h
//  martini
//
//  Created by zlata samarskaya on 12.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MModel : NSObject {
    int databaseId_;
}

@property(nonatomic, assign) int databaseId;

+ (id)objectFromDictionary:(NSDictionary*)dictionary;

@end

@interface MImagedModel : MModel {
    NSString *imagePath_;
    NSString *imageUrl_;
}

@property(nonatomic, retain) NSString *imagePath;
@property(nonatomic, retain) NSString *imageUrl;

@end

@interface MPhoto : MImagedModel 

- (void)lazyLoad;

@end

@class MUser;

@interface MMessageThread : MImagedModel {
//"user_id":"2","user_name":"fuckfuck","thread_id":"4","last_update":"1320842402","status":"read","new_messages":"0","total_msgs":"2","last_msg_text":"msgtex"
    MUser *recipient_;
    NSDate *lastUpdate_;
    NSString *status_;
    NSString *lastMessage_;

    int newMessages_;
    int messagesCount_;
}

@property(nonatomic, retain) MUser *recipient;
@property(nonatomic, retain) NSDate *lastUpdate;
@property(nonatomic, retain) NSString *status;
@property(nonatomic, retain) NSString *lastMessage;

@property(nonatomic, assign) int newMessages;
@property(nonatomic, assign) int messagesCount;

@end

@interface MMessage : MImagedModel {
    //{"id":"9","text":"test message","date":"1317301236","status":"new"}
    MMessageThread *thread_;
    NSDate *date_;
    NSString *status_;
    NSString *message_;
    NSString *title_;
    MUser *user_;
}

@property(nonatomic, retain) MUser *user;
@property(nonatomic, retain) MMessageThread *thread;
@property(nonatomic, retain) NSDate *date;
@property(nonatomic, retain) NSString *status;
@property(nonatomic, retain) NSString *message;
@property(nonatomic, retain) NSString *title;

@end

@interface MNewsCategory : MModel {
    NSString *title_;
    NSString *key_;
    int count_;
    
    BOOL hasNew_;
}

@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *key;
@property(nonatomic, assign) int count;
@property(nonatomic, assign) BOOL hasNew;

@end

@interface MNews : MImagedModel {
    NSString *title_;
    NSString *text_;
    NSDate *date_;
    NSString *category_;
    NSString *fullImageUrl_;
    NSString *fullImagePath_;
    
    BOOL isNew_;
}

@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *text;
@property(nonatomic, retain) NSString *fullImageUrl;
@property(nonatomic, retain) NSString *fullImagePath;
@property(nonatomic, retain) NSString *category;
@property(nonatomic, retain) NSDate *date;
@property(nonatomic, assign) BOOL isNew;

- (void)detailsFromDictionary:(NSDictionary*)dictionary;

@end

@interface MEvent : MImagedModel {
    NSString *title_;
    NSString *desc_;
    NSDate *date_;
    float lon_;
    float lat_;
    float distance_;
}

@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *desc;
@property(nonatomic, retain) NSDate *date;
@property(nonatomic, assign) float lon;
@property(nonatomic, assign) float lat;
@property(nonatomic, assign) float distance;

- (void)detailsFromDictionary:(NSDictionary*)dictionary;
- (BOOL)actual;
- (BOOL)past;

@end

@class MCoctail;

@interface MInvite : MImagedModel {
    MUser *user_;
    NSDate *date_;
    NSString *status_;
    BOOL recieved_;
    MCoctail *coctail_;
}

@property(nonatomic, retain) MUser *user;
@property(nonatomic, retain) NSDate *date;
@property(nonatomic, retain) NSString *status;
@property(nonatomic, retain) MCoctail *coctail;

@property(nonatomic, assign) BOOL recieved;

@end

@interface MCoctail : MImagedModel {
    NSString *name_;
    NSString *desc_;
    NSString *fullImageUrl_;
    NSString *fullImagePath_;
}

@property(nonatomic, retain) NSString *fullImageUrl;
@property(nonatomic, retain) NSString *fullImagePath;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *desc;

@end

@interface MResult : NSObject {
    NSArray *data_;
    int pages_;
    int page_;
}

@property(nonatomic, retain)NSArray *data;
@property(nonatomic, assign)int pages;
@property(nonatomic, assign)int page;

- (void)updateFromDictionary:(NSDictionary*)dictionary;

@end

@interface MFollowsResult : MResult {

    int count_;
}

@property(nonatomic, assign)int count;

@end

@interface MSearchResult : MResult {
    NSString *searchString_;
}

@property(nonatomic, retain)NSString *searchString;

@end

@interface MThreadResult : MResult {
    NSDate *from_;
    NSDate *to_;
}

@property(nonatomic, retain)NSDate *from;
@property(nonatomic, retain)NSDate *to;

@end

@interface MMessagesResult : MThreadResult {
    MMessageThread *thread_;
    MUser *user_;
    MEvent *event_;
}

@property(nonatomic, retain)MMessageThread *thread;
@property(nonatomic, retain)MUser *user;
@property(nonatomic, retain)MEvent *event;

@end

@interface MGuestsResult : MResult {
    MEvent *event_;
}

@property(nonatomic, retain) MEvent *event;

@end

@interface MInvitesResult : MThreadResult {
    MEvent *event_;
    int repliesPages_;
    NSArray *replies_;
    
    BOOL read_;
    BOOL onlyInvites_;
    BOOL onlyReplies_;
}

@property(nonatomic, assign) int repliesPages;
@property(nonatomic, retain) NSArray *replies;
@property(nonatomic, retain) MEvent *event;

@property(nonatomic, assign) BOOL read;
@property(nonatomic, assign) BOOL onlyInvites;
@property(nonatomic, assign) BOOL onlyReplies;

@end

@interface MNewsResult : MThreadResult {
    MNewsCategory *category_;
}

@property(nonatomic, retain)  MNewsCategory *category;

@end

@interface MEventsResult : MThreadResult {

}

@end